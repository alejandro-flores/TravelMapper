//
//  TMMapViewController.m
//  Travel Mapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/7/16.
//  Copyright © 2016 Alejandro Flores. All rights reserved.
//

#import "TMMapViewController.h"
#import "Travel+CoreDataClass.h"
#import "TMTravelTableViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
@import CoreData;

@interface TMMapViewController () <GMSAutocompleteResultsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *GMapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPlacemark *selectedPin;
@property (strong, nonatomic) NSMutableArray *travelsArray;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation TMMapViewController
#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self locationManagerSetup];
    [self addAutoCompleteSearchBar];
    
    self.tabBarController.delegate = self;
    _managedObjectCtx = [self getManagedObjectContext];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_GMapView clear];
    [self redrawTravelMarkers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - GMSAutocompleteResultsViewControllerDelegate
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didAutocompleteWithPlace:(GMSPlace *)place {
    _searchController.active = NO;
    
    // Drops a Marker on the Place selected from the list. Stores new Travel.
    GMSMarker *marker = [GMSMarker markerWithPosition:[place coordinate]];
    marker.title = [place name];
    marker.snippet = [place formattedAddress];
    [_GMapView animateToLocation:[place coordinate]];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = _GMapView;
    
    [self storeTravel:place];
    
    NSLog(@"TMAPVC -- Place name %@", place.name);
    NSLog(@"TMAPVC -- Place address %@", place.formattedAddress);
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"TMAPVC -- Error Autocompleting: %@", [error localizedDescription]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager requestLocation];
        [_locationManager startUpdatingLocation];
        _GMapView.myLocationEnabled = YES;
        _GMapView.settings.myLocationButton = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations firstObject];
    _GMapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:0.0 bearing:0.0 viewingAngle:0.0];
    [_GMapView animateToLocation:location.coordinate];
    [_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"TMAPVC -- LocationManager failed with error: %@", [error localizedDescription]);
}

#pragma mark - Map Utils
/**
 *  Allows the user to change the Map Type to either standard,
 *  satellite or hybrid.
 *
 *  @param sender UISegmentedControl object sending the action.
 */
- (IBAction)changeMapType:(UISegmentedControl *)sender {
    NSInteger index = [self.mapTypeSegmentedControl selectedSegmentIndex];
    switch (index) {
        case 0: _GMapView.mapType = kGMSTypeNormal;     break;
        case 1: _GMapView.mapType = kGMSTypeSatellite;  break;
        case 2: _GMapView.mapType = kGMSTypeHybrid;     break;
        default: break;
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *navController = (UINavigationController *)viewController;
    if ([navController.topViewController isKindOfClass:[TMTravelTableViewController class]]) {
        TMTravelTableViewController *tvc = (TMTravelTableViewController *)navController.topViewController;
        [tvc setManagedObjectCtx:_managedObjectCtx]; // Injects the ManagedObjectContext
    }
    return YES;
}

/**
 * Sets up the CLLocationManager to request and start location tracking
 */
#pragma mark - Helper Methods
- (void)locationManagerSetup {
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestLocation];
    [_locationManager requestWhenInUseAuthorization];
}

/**
 * Redraws the Travel Markers on the map from the data stored in the Travel entity
 * when reopening the app.
 */
- (void)redrawTravelMarkers {
    [self fetchTravels];
    
    for (Travel *travel in _travelsArray) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[travel valueForKey:@"latitude"] doubleValue],
                                                                  [[travel valueForKey:@"longitude"] doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:coord];
        marker.title = [travel valueForKey:@"cityName"];
        marker.snippet = [travel valueForKey:@"formattedAddress"];
        marker.map = _GMapView;
    }
}

/**
 * Used to fetch the Blades from the Persistent Data Store and store them in the bladesArray
 */
- (void)fetchTravels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Travel"];
    _travelsArray = [[_managedObjectCtx executeFetchRequest:fetchRequest error:nil]mutableCopy];
}

#pragma mark - Core Data
/**
 *  Allows user to persist Blade objects by grabbing the ManagedObjectContext
 *
 *  @return NSManagedObjectContext object.
 */
- (NSManagedObjectContext *)getManagedObjectContext {
    NSManagedObjectContext *ctx = nil;
    id delegate = [[UIApplication sharedApplication]delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)])
        ctx = [delegate managedObjectContext];
    
    return ctx;
}

- (void)storeTravel:(GMSPlace *)place {
    Travel *newTravel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel"
                                                      inManagedObjectContext:_managedObjectCtx];
    [newTravel setValue:place.name forKey:@"cityName"];
    [newTravel setValue:place.formattedAddress forKey:@"formattedAddress"];
    [newTravel setValue:place.placeID forKey:@"placeId"];
    [newTravel setValue:[NSNumber numberWithDouble:place.coordinate.latitude] forKey:@"latitude"];
    [newTravel setValue:[NSNumber numberWithDouble:place.coordinate.longitude] forKey:@"longitude"];
    [newTravel setValue:[NSDate date] forKey:@"dateVisited"];
    [newTravel setValue:@"N/A" forKey:@"travelType"];
    
    //Store the New Blade to Persistent Store
    NSError *travelSaveError = nil;
    if (![_managedObjectCtx save:&travelSaveError])
        NSLog(@"TMAPVC -- Error Saving New Travel: %@", [travelSaveError localizedDescription]);
    NSLog(@"TMAPVC -- Saved New Travel");
}

#pragma mark - Autocomplete
- (void)addAutoCompleteSearchBar {
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc]init];
    _resultsViewController.delegate = self;
    
    _searchController = [[UISearchController alloc]initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    
    // Put the search bar in the nav bar
    [_searchController.searchBar sizeToFit];
    self.navigationItem.titleView = _searchController.searchBar;
    
    // When UISearchController presents the result view, present it in
    // this view controller, not one further up the chain
    self.definesPresentationContext = YES;
    
    // Prevent the nav bar from being hidden when searching
    _searchController.hidesNavigationBarDuringPresentation = NO;
}

@end

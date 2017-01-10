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
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "TMTravelDetailsViewController.h"
#import <CWStatusBarNotification/CWStatusBarNotification.h>
@import CoreData;

@interface TMMapViewController () <GMSAutocompleteResultsViewControllerDelegate, TMTravelDetailsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *GMapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPlacemark *selectedPin;
@property (strong, nonatomic) NSMutableArray *travelsArray;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) GMSMarker *marker;

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
    [self redrawTravelMarkers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - GMSAutocompleteResultsViewControllerDelegate
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didAutocompleteWithPlace:(GMSPlace *)place {
    _searchController.active = NO;
    [_GMapView animateToLocation:[place coordinate]];
    
    _place = place;
    
    // Present TMTravelDetailsViewController Modally to gather Trip Details
    [self performSegueWithIdentifier:@"toTravelDetailsVC" sender:nil];
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

#pragma mark - TMTravelDetailsViewControllerDelegate
- (void)didStoreTravel:(TMTravelDetailsViewController *)controller {
    // Display Sucess Notification
    UIColor *greenColor = [UIColor colorWithRed:72.0 / 255.0 green:194.0 / 255.0 blue:31.0 / 255.0 alpha:1.0f];
    [self showNotificationWithMessage:@"Saved New Travel" andBackgroundColor:greenColor];
}

- (void)willDropMarker:(TMTravelDetailsViewController *)controller {
    // Drops a Marker on the Place selected from the list.
    _marker = [GMSMarker markerWithPosition:[_place coordinate]];
    _marker.title = [_place name];
    _marker.snippet = [_place formattedAddress];
    _marker.appearAnimation = kGMSMarkerAnimationPop ;
    _marker.map = _GMapView;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toTravelDetailsVC"]) {
        TMTravelDetailsViewController *travelDetailsVC = [segue destinationViewController];
        travelDetailsVC.delegate = self;
        [travelDetailsVC setManagedObjectCtx:_managedObjectCtx];
        [travelDetailsVC setPlace:_place];
    }
}

- (IBAction)unwindToRedrawMarkers:(UIStoryboardSegue *)segue {
    // After dismissing TMTravelDetailsViewControllers reload markers from Model.
    // If cancel is clicked on TMTravelDetailsViewController, the marker just dropped
    // on the map is not kept, since the Travel record was discarded.
    [self redrawTravelMarkers];
    [self showNotificationWithMessage:@"Cancelled Operation" andBackgroundColor:[UIColor redColor]];
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
    [_GMapView clear];
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
 * Displays a CWStatusBarNotification when a new marker is either added or
 * discarded from the map.

 * @param message String to display on the CWStatusBarNotification.
 * @param color background color of the CWStatusBarNotification.
 */
- (void)showNotificationWithMessage:(NSString *)message andBackgroundColor:(UIColor *)color {
    CWStatusBarNotification *notification = [CWStatusBarNotification new];
    notification.notificationLabelBackgroundColor = color;
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationStyle = CWNotificationStyleStatusBarNotification;
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleLeft;
    [notification displayNotificationWithMessage:message forDuration:1.5f];
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

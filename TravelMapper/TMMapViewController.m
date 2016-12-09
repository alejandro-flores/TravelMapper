//
//  TMMapViewController.m
//  Travel Mapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/7/16.
//  Copyright © 2016 Alejandro Flores. All rights reserved.
//

#import "TMMapViewController.h"
#import "TMLocationSearchTableViewController.h"
#import "Travel+CoreDataClass.h"
#import "TMTravelTableViewController.h"
@import CoreData;

@interface TMMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchController *resultSearchController;
@property (strong, nonatomic) MKPlacemark *selectedPin;
@property (strong, nonatomic) NSMutableArray *travelsArray;
@end

@implementation TMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    _managedObjectCtx = [self getManagedObjectContext];
    
    [self.mapTypeSegmentedControl setSelectedSegmentIndex:0];
    [self locationManagerSetup];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    TMLocationSearchTableViewController *locationSearchTable = [storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTable"];
    _resultSearchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTable];
    _resultSearchController.searchResultsUpdater = locationSearchTable;
    
    UISearchBar *searchBar = _resultSearchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Search for places";
    self.navigationItem.titleView = _resultSearchController.searchBar;
    
    _resultSearchController.hidesNavigationBarDuringPresentation = NO;
    _resultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    
    locationSearchTable.mapView = _mapView;
    
    locationSearchTable.handleMapSearchDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
        [_locationManager requestLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"MAPVC - Location: %@", [locations firstObject]);
    CLLocation *location = [locations firstObject];
    MKCoordinateSpan span = MKCoordinateSpanMake(100, 100); // 1 degree = 111km
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    
    [_mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"MAPVC - LocationManager failed with error: %@", error);
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
        case 0: self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1: self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2: self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (void)dropPinZoomIn:(MKPlacemark *)placemark {
    _selectedPin = placemark;
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = placemark.coordinate;
    annotation.title = placemark.name;
    annotation.subtitle = [NSString stringWithFormat:@"%@, %@",
                           (placemark.locality == nil ? @"" : placemark.locality),
                           (placemark.administrativeArea == nil ? @"" : placemark.country)
                           ];
    [_mapView addAnnotation:annotation];
    MKCoordinateSpan span = MKCoordinateSpanMake(100, 100);
    MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
    [_mapView setRegion:region animated:true];
    
    // Stores the annotation as a Travel Core Data entity
    Travel *newTravel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel" inManagedObjectContext:_managedObjectCtx];
    NSString *cityName = [NSString stringWithFormat:@"%@", annotation.title];
    NSString *countryName = [NSString stringWithFormat:@"%@", annotation.subtitle];
    NSNumber *latitude = [NSNumber numberWithFloat:placemark.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat:placemark.coordinate.longitude];
    NSDate *date = [NSDate date]; // Get Today's date for now.
    NSString *travelType = @"Temp"; // Temp for now
    
    [newTravel setValue:cityName forKey:@"cityName"];
    [newTravel setValue:countryName forKey:@"countryName"];
    [newTravel setValue:latitude forKey:@"latitude"];
    [newTravel setValue:longitude forKey:@"longitude"];
    [newTravel setValue:date forKey:@"dateVisited"];
    [newTravel setValue:travelType forKey:@"travelType"];
    
    //Store the New Blade to Persistent Store
    NSError *error = nil;
    if (![_managedObjectCtx save:&error])
        NSLog(@"MAIN -- Error Saving New Travel: %@", [error localizedDescription]);
    NSLog(@"MAIN -- Saved New Travel");
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        //return nil so map view draws "blue dot" for standard user location
        return nil;
    }
    
    static NSString *reuseId = @"pin";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        pinView.tintColor = [UIColor orangeColor];
    } else {
        pinView.annotation = annotation;
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"car"]
                      forState:UIControlStateNormal];
    [button addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
    pinView.leftCalloutAccessoryView = button;
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return pinView;
}

- (void)getDirections {
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:_selectedPin];
    [mapItem openInMapsWithLaunchOptions:(@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving})];
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

- (void)redrawTravels {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
        [_mapView addAnnotation:annotation];
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

@end

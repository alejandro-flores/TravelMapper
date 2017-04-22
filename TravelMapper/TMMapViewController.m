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
#import "TMMapSettingsTableViewController.h"
#import "SWRevealViewController.h"
#import "TMCacheManager.h"

@import CoreData;

@interface TMMapViewController () <GMSAutocompleteResultsViewControllerDelegate, TMTravelDetailsViewControllerDelegate, TMMapSettingsTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *GMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (strong, nonatomic) UIImage *vacationImage, *homeImage, *schoolImage, *workImage;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *resultsViewController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableArray *travelsArray;
@property (strong, nonatomic) MKPlacemark *selectedPin;
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) GMSMarker *marker;

@end

@implementation TMMapViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Disable Autolayout warnings
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    [self initMarkerIcons];
    [self setMapSettingsDelegate];
    [self menuViewRevealSetup];
    [self locationManagerSetup];
    [self addAutoCompleteSearchBar];
    
    self.tabBarController.delegate = self;
    _managedObjectCtx = [self getManagedObjectContext];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self redrawTravelMarkers];
    [self changeMapTypeFromSettings];
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager requestLocation];
        [_locationManager startUpdatingLocation];
        _GMapView.myLocationEnabled = YES;
        _GMapView.settings.myLocationButton = YES;
        _GMapView.settings.compassButton = YES;
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

- (void)willDropMarker:(TMTravelDetailsViewController *)controller forTravelType:(NSString *)travelType {
    // Drops a Marker on the Place selected from the list.
    _marker = [GMSMarker markerWithPosition:[_place coordinate]];
    _marker.title = [_place name];
    _marker.snippet = [_place formattedAddress];
    _marker.appearAnimation = kGMSMarkerAnimationPop;
    [self setMarkerIcon:_marker forTravelType:travelType];
    _marker.map = _GMapView;
}

#pragma mark - TMMapSettingsTableViewControllerDelegate
- (void)willChangeMapType:(TMMapSettingsTableViewController *)controller mapType:(GMSMapViewType)mapType {
    _GMapView.mapType = mapType;
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
    [[TMCacheManager sharedInstance] removeCachedImageForKey:_place.placeID];
    [self redrawTravelMarkers];
    [self showNotificationWithMessage:@"Cancelled Operation" andBackgroundColor:[UIColor redColor]];
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

/**
 * Used to fetch the Blades from the Persistent Data Store and store them in the bladesArray
 */
- (void)fetchTravels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Travel"];
    _travelsArray = [[_managedObjectCtx executeFetchRequest:fetchRequest error:nil]mutableCopy];
}

#pragma mark - Helper Methods
/**
 * Sets up the CLLocationManager to request and start location tracking
 */
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
        // NSString *travelType = [NSString stringWithFormat:@"%@", [travel valueForKey:@"travelType"]];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[travel valueForKey:@"latitude"] doubleValue],
                                                                  [[travel valueForKey:@"longitude"] doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:coord];
        marker.title = [travel valueForKey:@"cityName"];
        marker.snippet = [travel valueForKey:@"formattedAddress"];
        // TODO: Find suitable icons for the different travel types.
        //[self setMarkerIcon:marker forTravelType:travelType];
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
    [notification displayNotificationWithMessage:message forDuration:1.0f];
}

/**
 * Configures the menu bar button responsible for revealing the settings view.
 */
- (void)menuViewRevealSetup {
    SWRevealViewController *revealController = [self revealViewController];
    if (revealController) {
        _menuBarButton.tintColor = [UIColor lightGrayColor];
        [_menuBarButton setTarget:self.revealViewController];
        [_menuBarButton setAction:@selector(revealToggleAnimated:)];
        [revealController tapGestureRecognizer];
        [revealController panGestureRecognizer];
        [revealController setRearViewRevealWidth:([revealController rearViewRevealWidth] * 0.75f)]; // 75% of its original width.
    }
}

/**
 * Gets a reference of the Map Settings View Controller and sets itself as its delegate.
 */
- (void)setMapSettingsDelegate {
    UINavigationController *rearNavController = (UINavigationController *)self.revealViewController.rearViewController;
    if ([rearNavController.topViewController isKindOfClass:[TMMapSettingsTableViewController class]]) {
        TMMapSettingsTableViewController *mapSettingsTVC = (TMMapSettingsTableViewController *)rearNavController.topViewController;
        mapSettingsTVC.delegate = self;
    }
}

/**
 * Sets the marker's icon to our own image based on the Travel Type entered for the Travel.

 @param marker The marker displayed on the map.
 @param travelType Travel Type chosen when the Travel was created (Home, Vacation, Work).
 */
- (void)setMarkerIcon:(GMSMarker *)marker forTravelType:(NSString *)travelType {
    if ([travelType  isEqualToString: @"Vacation"])     marker.icon = _homeImage;
    else if ([travelType isEqualToString:@"Home"])      marker.icon = _vacationImage;
    else if ([travelType isEqualToString:@"School"])    marker.icon = _schoolImage;
    else if ([travelType isEqualToString:@"Work"])      marker.icon = _workImage;
}

/**
 * Initializes the marker icon images to be reused when adding/redrawing
 * the markers on the map.
 */
- (void)initMarkerIcons {
    _vacationImage  = [UIImage imageNamed:@"ic_beach_access.png"];
    _homeImage      = [UIImage imageNamed:@"ic_home.png"];
    _schoolImage    = [UIImage imageNamed:@"school.png"];
    _workImage      = [UIImage imageNamed:@"ic_work.png"];
}

/**
 * Loads the correct map type in viewDidLoad according to the map type chosen in the Settings Menu.
 */
- (void)changeMapTypeFromSettings {
    _GMapView.mapType = ([[_userDefaults stringForKey:@"mapType"] isEqualToString:@"satellite"] ? kGMSTypeNormal : kGMSTypeHybrid);
}

@end

//
//  TMMapViewController.m
//  Travel Mapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/7/16.
//  Copyright © 2016 Alejandro Flores. All rights reserved.
//

#import "TMMapViewController.h"
#import "TMLocationSearchTableViewController.h"

@interface TMMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchController *resultSearchController;
@property (strong, nonatomic) MKPlacemark *selectedPin;
@end

@implementation TMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapTypeSegmentedControl setSelectedSegmentIndex:0];
    //_mapView.delegate = self;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)dropPinZoomIn:(MKPlacemark *)placemark
{
    // cache the pin
    _selectedPin = placemark;
    // clear existing pins
    [_mapView removeAnnotations:(_mapView.annotations)];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = placemark.coordinate;
    annotation.title = placemark.name;
    annotation.subtitle = [NSString stringWithFormat:@"%@ %@",
                           (placemark.locality == nil ? @"" : placemark.locality),
                           (placemark.administrativeArea == nil ? @"" : placemark.administrativeArea)
                           ];
    [_mapView addAnnotation:annotation];
    MKCoordinateSpan span = MKCoordinateSpanMake(100, 100);
    MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
    [_mapView setRegion:region animated:true];
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end

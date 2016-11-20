//
//  TMMapViewController.m
//  Travel Mapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/7/16.
//  Copyright © 2016 Alejandro Flores. All rights reserved.
//

#import "TMMapViewController.h"
@import MapKit;

@interface TMMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;
@end

@implementation TMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapTypeSegmentedControl setSelectedSegmentIndex:0];
    _mapView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

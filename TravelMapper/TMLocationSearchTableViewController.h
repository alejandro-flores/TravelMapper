//
//  TMLocationSearchTableViewController.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/11/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMMapViewController.h"
@import MapKit;

@interface TMLocationSearchTableViewController : UITableViewController <UISearchResultsUpdating>

@property MKMapView *mapView;
@property id <HandleMapSearch>handleMapSearchDelegate;

@end

//
//  TMMapSettingsTableViewController.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/10/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

/******************** TMTravelDetailsViewControllerDelegate *******************/
@class TMMapSettingsTableViewController;
@protocol TMMapSettingsTableViewControllerDelegate <NSObject>
@required

- (void)willChangeMapType:(TMMapSettingsTableViewController *)controller mapType:(GMSMapViewType)mapType;

@end
/*********************************************************************/

@interface TMMapSettingsTableViewController : UITableViewController

@property(weak, nonatomic) id<TMMapSettingsTableViewControllerDelegate> delegate;

@end

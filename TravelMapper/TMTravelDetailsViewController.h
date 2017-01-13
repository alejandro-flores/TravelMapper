//
//  TMTravelDetailsViewController.h
//  TravelMapper
//
//  Created by Guests on 12/24/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

/******************** TMTravelDetailsViewControllerDelegate *******************/
@class TMTravelDetailsViewController;
@protocol TMTravelDetailsViewControllerDelegate <NSObject>
@required

- (void)didStoreTravel:(TMTravelDetailsViewController *)controller;
- (void)willDropMarker:(TMTravelDetailsViewController *)controller forTravelType:(NSString *)travelType;

@end
/*********************************************************************/

@interface TMTravelDetailsViewController : UIViewController

@property(weak, nonatomic) id<TMTravelDetailsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectCtx;
@property (strong, nonatomic) GMSPlace *place;

@end

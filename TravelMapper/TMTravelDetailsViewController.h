//
//  TMTravelDetailsViewController.h
//  TravelMapper
//
//  Created by Guests on 12/24/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@interface TMTravelDetailsViewController : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectCtx;
@property (strong, nonatomic) GMSPlace *place;
@end

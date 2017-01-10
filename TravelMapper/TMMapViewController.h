//
//  TMMapViewController.h
//  Travel Mapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/7/16.
//  Copyright © 2016 Alejandro Flores. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface TMMapViewController : UIViewController <CLLocationManagerDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectCtx;

@end

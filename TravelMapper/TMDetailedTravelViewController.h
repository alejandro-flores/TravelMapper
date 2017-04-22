//
//  TMDetailedTravelViewController.h
//  TravelMapper
//
//  Created by Guests on 12/25/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMDetailedTravelViewController : UIViewController

@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *cityFormattedAddress;
@property (strong, nonatomic) NSString *travelType;
@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *weatherDescription;
@property (strong, nonatomic) NSString *iconFileName;
@property (strong, nonatomic) NSString *currentTemp;
@property (strong, nonatomic) NSString *lowTemp;
@property (strong, nonatomic) NSString *highTemp;
@property (strong, nonatomic) NSString *currentTime;
@property (assign, nonatomic) BOOL isDay;

@end

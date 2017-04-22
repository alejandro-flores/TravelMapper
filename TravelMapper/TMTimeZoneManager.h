//
//  TMTimeZoneManager.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/31/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTimeZoneManager : NSObject

- (instancetype)init;

- (NSString *)getCurrentTime;
- (NSString *)getTimeZone;
- (void)queryCurrentTimeForLatitude:(NSString *)latitude longitude:(NSString *)longitude;
- (BOOL)isDay;

@end

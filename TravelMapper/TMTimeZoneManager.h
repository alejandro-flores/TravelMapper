//
//  TMTimeZoneManager.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/31/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTimeZoneManager : NSObject

@property (strong, nonatomic) NSString *latitude, *longitude;

- (instancetype)initWithLatitude:(NSString *)latitude longitude:(NSString *)longitude;

- (NSString *)getCurrentTime;
- (BOOL)isDay;

@end

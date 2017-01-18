//
//  LocalWeather.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/13/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalWeather : NSObject

@property (assign, nonatomic) NSString *latitude, *longitude, *currentWeather, *temperatureUnits, *finalWeather;

- (instancetype)initWithLatitude:(NSString *)latitude longitude:(NSString *)longitude temperatureUnits:(NSString *)temperatureUnits;
- (NSString *)getCurrentWeatherCelsius;
- (NSString *)getCurrentWeatherFahrenheit;
@end

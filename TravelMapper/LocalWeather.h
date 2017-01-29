//
//  LocalWeather.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/13/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalWeather : NSObject

@property (assign, nonatomic) NSString *latitude, *longitude, *currentWeather;

- (instancetype)initWithLatitude:(NSString *)latitude longitude:(NSString *)longitude;

- (float)getCurrentWeatherTemp;
- (float)getDailyForecastMinTemp;
- (float)getDailyForecastMaxTemp;
- (NSString *)getCurrentWeatherIconFileName;
- (NSString *)getCurrentWeatherDescription;
- (NSString *)kelvinToFahrenheit:(float)K;
- (NSString *)kelvinToCelsius:(float)K;

@end

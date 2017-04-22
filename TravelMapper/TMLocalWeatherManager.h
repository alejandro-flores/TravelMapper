//
//  TMLocalWeatherManager.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/31/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMLocalWeatherManager : NSObject

@property (assign, nonatomic) NSString *currentWeather;

- (instancetype)init;
- (void)queryWeather:(NSString *)latitude longitude:(NSString *)longitude;
- (float)getCurrentWeatherTemp;
- (float)getDailyForecastMinTemp;
- (float)getDailyForecastMaxTemp;
- (NSString *)getCurrentWeatherIconFileName;
- (NSString *)getCurrentWeatherDescription;
- (NSString *)kelvinToFahrenheit:(float)K;
- (NSString *)kelvinToCelsius:(float)K;

@end

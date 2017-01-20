
//
//  LocalWeather.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/13/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "LocalWeather.h"
static const NSString *API_KEY = @"***REMOVED***";   // openweather API Key

@implementation LocalWeather

float tempKelvin, minTempKelvin, maxTempKelvin;
NSString *description, *iconFileName;

- (instancetype)initWithLatitude:(NSString *)latitude longitude:(NSString *)longitude {
    if (self = [super init]) {
        _latitude = latitude;
        _longitude = longitude;
    }
    
    [self queryWeather];
    
    return self;
}

- (void)queryWeather {
    NSString *stringURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&appid=%@", _latitude, _longitude, API_KEY];
    NSString *escapedURL = [stringURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:escapedURL] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    
    //NSLog(@"DEBUG - WEATHER: %@", [results objectForKey:@"weather"]);
    
    iconFileName = [NSString stringWithFormat:@"%@", [[[results objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
    description = [NSString stringWithFormat:@"%@", [[[results objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"]];
    tempKelvin = [[[results objectForKey:@"main"] valueForKey:@"temp"] floatValue];
    minTempKelvin = [[[results objectForKey:@"main"] valueForKey:@"temp_min"] floatValue];
    maxTempKelvin = [[[results objectForKey:@"main"] valueForKey:@"temp_max"] floatValue];
}

- (NSString *)getCurrentWeatherIconFileName {
    return iconFileName;
}

- (float)getCurrentWeatherTemp {
    return tempKelvin;
}

- (float)getCurrentWeatherMinTemp {
    return minTempKelvin;
}

- (float)getCurrentWeatherMaxTemp {
    return maxTempKelvin;
}

- (NSString *)getCurrentWeatherDescription {
    return description;
}

- (NSString *)kelvinToCelsius:(float)K {
    static const float ZERO_KELVIN = 273.15;
    
    return [NSString stringWithFormat:@"%.f°", (K - ZERO_KELVIN)];
}

- (NSString *)kelvinToFahrenheit:(float)K {
    static const float ZERO_KELVIN = -459.67;
    
    return [NSString stringWithFormat:@"%.f°", ((300 * K * (9/5)) - ZERO_KELVIN)];
}

@end

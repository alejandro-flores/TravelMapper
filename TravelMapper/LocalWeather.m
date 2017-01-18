
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
NSString *description;

- (instancetype)initWithLatitude:(NSString *)latitude longitude:(NSString *)longitude temperatureUnits:(NSString *)temperatureUnits {
    if (self = [super init]) {
        _latitude = latitude;
        _longitude = longitude;
        _temperatureUnits = temperatureUnits;
    }
    
    return self;
}

- (void)queryWeather {
    // Desired Format: Light Snow. Temperature: -5C. Low: -10C Max: 0C
    
    NSString *stringURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&appid=%@", _latitude, _longitude, API_KEY];
    NSString *escapedURL = [stringURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:escapedURL] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    
    description = [NSString stringWithFormat:@"%@",[[[results objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"description"]];
    tempKelvin = [[[results objectForKey:@"main"] valueForKey:@"temp"] floatValue];
    minTempKelvin = [[[results objectForKey:@"main"] valueForKey:@"temp_min"] floatValue];
    maxTempKelvin = [[[results objectForKey:@"main"] valueForKey:@"temp_max"] floatValue];
}

- (NSString *)getCurrentWeatherCelsius {
    [self queryWeather];
    return [NSString stringWithFormat:@"%@. Temperature: %@°C. High: %@°C, Low: %@°C",
            [self capitalizeFirstLetter:description],
            [self kelvinToCelsius:tempKelvin],
            [self kelvinToCelsius:maxTempKelvin],
            [self kelvinToCelsius:minTempKelvin]];
}

- (NSString *)getCurrentWeatherFahrenheit {
    [self queryWeather];
    return [NSString stringWithFormat:@"%@. Temperature: %@°F. High: %@°F, Low: %@°F",
            [self capitalizeFirstLetter:description],
            [self kelvinToFahrenheit:tempKelvin],
            [self kelvinToFahrenheit:maxTempKelvin],
            [self kelvinToFahrenheit:minTempKelvin]];
}

- (NSString *)kelvinToCelsius:(float)K {
    static const float ZERO_KELVIN = 273.15;
    
    return [NSString stringWithFormat:@"%.1f", (K - ZERO_KELVIN)];
}

- (NSString *)kelvinToFahrenheit:(float)K {
    static const float ZERO_KELVIN = -459.67;
    
    return [NSString stringWithFormat:@"%.1f", ((300 * K * (9/5)) - ZERO_KELVIN)];
}

- (NSString *)capitalizeFirstLetter:(NSString *)string {
    // Create a locale where diacritic marks are not considered important, e.g. US English */
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    // Get first char */
    NSString *firstChar = [string substringToIndex:1];
    // Remove any diacritic mark */
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    
    // Create the new string */
    return [[folded uppercaseString] stringByAppendingString:[string substringFromIndex:1]];
}

@end

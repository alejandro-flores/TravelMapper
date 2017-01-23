
//
//  LocalWeather.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/13/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "LocalWeather.h"

@implementation LocalWeather
static const NSString *API_KEY = @"***REMOVED***";   // OpenWeather API Key
NSString *currentForecastStringURL; // URL to query the current weather data API.
NSString *dailyForecastStringURL;   // URL to query the daily forecast data API.
NSString *iconFileName;             // Icon name corresponding to the current weather condition.
NSString *description;              // Current weather short description.
float currTempKelvin;               // Current temperature in Kelvin (from the current weather API).
float minTempKelvin;                // Forecasted daily minimum temperature in Kelvin (from the daily forecast API).
float maxTempKelvin;                // Forecasted daily maximum temperature in Kelvin (from the daily forecast API).


- (instancetype)initWithLatitude:(NSString *)latitude longitude:(NSString *)longitude {
    if (self = [super init]) {
        _latitude = latitude;
        _longitude = longitude;
        currentForecastStringURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&appid=%@", _latitude, _longitude, API_KEY];
        dailyForecastStringURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%@&lon=%@&appid=%@", _latitude, _longitude, API_KEY];
    }
    [self queryWeather];
    
    return self;
}

/**
 * Escapes a URL String using the stringByAddingPercentEncodingWithAllowedCharacters
 * method in NSString.

 * @param stringURL the NSString urlString to escape.
 * @return the escaped NSString with the correct encodings.
 */
- (NSString *)escapeURL:(NSString *)stringURL {
    return [stringURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}


/**
 * Creates a NSData object with the contents of the escaped URL String.

 * @param stringURL escaped URL.
 * @return NSData object with the contents of the given URL.
 */
- (NSData *)createJSONDataObject:(NSString *)stringURL {
    NSString *escapedURL = [self escapeURL:stringURL];
    
    return [[NSString stringWithContentsOfURL:[NSURL URLWithString:escapedURL] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
}


/**
 * Queries both the current weather data API and the daily forecast API to get the necesary weather data.
 * The reason why I make an addditional call to the daily forecast API is to reflect the expected daily 
 * minimum and maximum temperatures which the current weather data API doesn't list.
 */
- (void)queryWeather {
    NSData *currentForecastJSONData = [self createJSONDataObject:currentForecastStringURL];
    NSData *dailyForecastJSONData = [self createJSONDataObject:dailyForecastStringURL];
    NSError *error = nil;
    
    // Response JSON Object
    NSDictionary *currentWeaterJSONResults = currentForecastJSONData ? [NSJSONSerialization JSONObjectWithData:currentForecastJSONData options:0 error:&error] : nil;
    NSDictionary *dailyWeatherJSONResults = currentForecastJSONData ? [NSJSONSerialization JSONObjectWithData:dailyForecastJSONData options:0 error:&error] : nil;
    
    // Parse necessary data from the JSON Objects.
    iconFileName = [NSString stringWithFormat:@"%@", [[[currentWeaterJSONResults objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
    description = [NSString stringWithFormat:@"%@", [[[currentWeaterJSONResults objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"]];
    currTempKelvin = [[[currentWeaterJSONResults objectForKey:@"main"] valueForKey:@"temp"] floatValue];
    minTempKelvin = [[[[[dailyWeatherJSONResults objectForKey:@"list"] objectAtIndex:0] objectForKey:@"temp"] objectForKey:@"min"] floatValue];
    maxTempKelvin = [[[[[dailyWeatherJSONResults objectForKey:@"list"] objectAtIndex:0] objectForKey:@"temp"] objectForKey:@"max"] floatValue];
}


/**
 * Returns the icon name corresponding to the current weather condition.
 * This icon name will be used to display the correct weather icon corresponding
 * to the current weather condition.

 * @return NSString with the name of the icon.
 */
- (NSString *)getCurrentWeatherIconFileName {
    return iconFileName;
}


/**
 * Returns the current weather temperature at the time of the call.

 * @return current temperature in Kelvin.
 */
- (float)getCurrentWeatherTemp {
    return currTempKelvin;
}


/**
 * Returs the daily reported minimum temperature.

 * @return daily mininmum temperature in Kelvin.
 */
- (float)getDailyForecastMinTemp {
    return minTempKelvin;
}


/**
 * Returns the daily reported maximum temperature.

 * @return daily minimum temperature in Kelvin.
 */
- (float)getDailyForecastMaxTemp {
    return maxTempKelvin;
}


/**
 * Returns a short description of the current weather condition.
 
 * @return NSString with the weather description.
 */
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

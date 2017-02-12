//
//  TMTimeZoneManager.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/31/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMTimeZoneManager.h"
#import "TMAPIHelper.h"

@implementation TMTimeZoneManager

TMAPIHelper *apiHelper; // API helper class.
NSString *stringURL;    // URL to query current time from api.geonames.org.
NSString *currentTime;  // Current Time.
NSString *timeZone;     // Current Location Time Zone.
NSString *sunrise;      // Time when sun rises.
NSString *sunset;       // Time when sun sets.

- (instancetype)initWithLatitude:(NSString *)latitude longitude:(NSString *)longitude {
    if (self = [super init]) {
        _latitude = latitude;
        _longitude = longitude;
        
        stringURL = [NSString stringWithFormat:@"http://api.geonames.org/timezoneJSON?lat=%@&lng=%@&username=aflores", latitude, longitude];
        apiHelper = [TMAPIHelper new];
    }
    [self queryCurrentTime];
    
    return self;
}

/**
 * Makes a call tp api.geonames.org to get a JSON object with the time zone information for the
 * given latitude and longitude coordinates. Then it parses the currentTime and also the rawOffset
 * to get a representation of the current time + the time zone.
 */
- (void)queryCurrentTime {
    NSError *error = nil;
    
    // Response JSON Object
    NSDictionary *currentTimeJSONResults = [apiHelper createJSONDataObject:stringURL] ? [NSJSONSerialization JSONObjectWithData:[apiHelper createJSONDataObject:stringURL] options:0 error:&error] : nil;
    
    currentTime = [NSString stringWithFormat:@"%@h", [[[currentTimeJSONResults valueForKey:@"time"] componentsSeparatedByString:@" "] lastObject]];
    sunrise = [NSString stringWithFormat:@"%@", [[[currentTimeJSONResults valueForKey:@"sunrise"] componentsSeparatedByString:@" "] lastObject]];
    sunset = [NSString stringWithFormat:@"%@", [[[currentTimeJSONResults valueForKey:@"sunset"] componentsSeparatedByString:@" "] lastObject]];
    [self formatTimeZone:[NSString stringWithFormat:@"%@", [currentTimeJSONResults valueForKey:@"rawOffset"]]];
}

/**
 * Takes the parsed rawOffset and determines what the final timezone representation will
 * look like.

 @param parsedTimeZone rawOffset rawOffset from the JSON object.
 */
- (void)formatTimeZone:(NSString *)rawOffset {
    if ([rawOffset containsString:@"-"])
        // When parsed offset is preceded by a negative sign.
        timeZone = [NSString stringWithFormat:@"UTC%@", rawOffset];
    else if ([rawOffset containsString:@"+"])
        // When parsed offset is preceded by a positive sign.
        timeZone = [NSString stringWithFormat:@"UTC+%@", rawOffset];
    else if ([rawOffset containsString:@"0"])
        // When parsed offset is equal to 0.
        timeZone = @"UTC";
    else {
        // When parsed offset is preceded by neither a negative or positive sign.
        timeZone = [NSString stringWithFormat:@"UTC+%@", rawOffset];
    }
}

/**
 * Returns a string representation of the current time plus the formatted timezone.

 @return current time plus timezone.
 */
- (NSString *)getCurrentTime {
    return [NSString stringWithFormat:@"Time: %@ %@", currentTime, timeZone];
}

/**
 * Compares the current time with the sunrise/sunset times to determine if it's day or night.

 @return true if it's day, false otherwise.
 */
- (BOOL)isDay {
    BOOL isDay = true;
    if ([currentTime floatValue] >= [sunset floatValue] || [currentTime floatValue] <= [sunrise floatValue]) {
        isDay = false;
    }

    return isDay;
}

@end

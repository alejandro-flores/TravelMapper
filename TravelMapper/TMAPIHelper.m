
//
//  TMAPIHelper.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/31/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMAPIHelper.h"

@implementation TMAPIHelper

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
    return [[NSString stringWithContentsOfURL:[NSURL URLWithString:[self escapeURL:stringURL]]
                                     encoding:NSUTF8StringEncoding
                                        error:nil]
            dataUsingEncoding:NSUTF8StringEncoding];
}

@end

//
//  TMAPIHelper.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/31/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMAPIHelper : NSObject

- (NSString *)escapeURL:(NSString *)stringURL;
- (NSData *)createJSONDataObject:(NSString *)stringURL;

@end

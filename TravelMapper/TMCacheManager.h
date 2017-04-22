//
//  TMCacheManager.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 2/20/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlaces/GooglePlaces.h>

@interface TMCacheManager : NSObject

+ (TMCacheManager *)sharedInstance;
#pragma mark - City Image
- (void)cacheCityImage:(GMSPlacePhotoMetadata *)image forKey:(NSString *)placeID;
-(GMSPlacePhotoMetadata *)getCachedImageForKey:(NSString *)placeID;
- (void)removeCachedImageForKey:(NSString *)placeID;

@end

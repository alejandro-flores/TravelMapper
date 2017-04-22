//
//  TMCacheManager.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 2/20/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMCacheManager.h"

static TMCacheManager *sharedInstance;

@interface TMCacheManager()
@property (strong, nonatomic) NSCache *cache;
@end

@implementation TMCacheManager

+ (TMCacheManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TMCacheManager alloc]init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    
    return self;
}

#pragma mark - City Image
- (void)cacheCityImage:(GMSPlacePhotoMetadata *)image forKey:(NSString *)placeID {
    [_cache setObject:image forKey:placeID];
}

- (GMSPlacePhotoMetadata *)getCachedImageForKey:(NSIndexPath *)indexPath {
    return [_cache objectForKey:indexPath];
}

- (void)removeCachedImageForKey:(NSString *)placeID {
    [_cache removeObjectForKey:placeID];
}

@end

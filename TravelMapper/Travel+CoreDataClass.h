//
//  Travel+CoreDataClass.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 12/16/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Travel : NSManagedObject

// Public API
+ (void)loadFirstPhotoForPlace:(NSString *)placeID imageView:(UIImageView *)imageView attributionLabel:(UILabel *)attributionLabel;
+ (void)loadImageForMetadata:(GMSPlacePhotoMetadata *)photoMetadata imageView:(UIImageView *)imageView attributionLabel:(UILabel *)attributionLabel;

@end

NS_ASSUME_NONNULL_END

#import "Travel+CoreDataProperties.h"

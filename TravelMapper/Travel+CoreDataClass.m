//
//  Travel+CoreDataClass.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 12/16/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "Travel+CoreDataClass.h"
#import "TMCacheManager.h"

@implementation Travel

#pragma mark - Fetch Place Photo
+ (void)loadFirstPhotoForPlace:(NSString *)placeID imageView:(UIImageView *)imageView attributionLabel:(UILabel *)attributionLabel {
    [[GMSPlacesClient sharedClient]
     lookUpPhotosForPlaceID:placeID
     callback:^(GMSPlacePhotoMetadataList *_Nullable photos,
                NSError *_Nullable error) {
         if (error) {
             NSLog(@"Error: %@", [error description]);
         } else {
             if (photos.results.count > 0) {
                 if (![[TMCacheManager sharedInstance] getCachedImageForKey:placeID]) {
                     GMSPlacePhotoMetadata *firstPhoto = photos.results.firstObject;
                     [[TMCacheManager sharedInstance] cacheCityImage:firstPhoto forKey:placeID];
                     [self loadImageForMetadata:firstPhoto imageView:imageView attributionLabel:attributionLabel];
                 }
                 else {
                     GMSPlacePhotoMetadata *firstPhoto = [[TMCacheManager sharedInstance] getCachedImageForKey:placeID];
                     [self loadImageForMetadata:firstPhoto imageView:imageView attributionLabel:attributionLabel];
                 }
             }
         }
     }];
}

+ (void)loadImageForMetadata:(GMSPlacePhotoMetadata *)photoMetadata imageView:(UIImageView *)imageView attributionLabel:(UILabel *)attributionLabel {
    [[GMSPlacesClient sharedClient]
     loadPlacePhoto:photoMetadata
     constrainedToSize:imageView.bounds.size
     scale:imageView.window.screen.scale
     callback:^(UIImage *_Nullable photo, NSError *_Nullable error) {
         if (error) {
             NSLog(@"Error: %@", [error description]);
         } else {
             imageView.image = photo;
             attributionLabel.attributedText = photoMetadata.attributions;
         }
     }];
}

+ (void)loadImageForMetadata:(GMSPlacePhotoMetadata *)photoMetadata imageView:(UIImageView *)imageView  attribution:(NSAttributedString *)attribution attributionLabel:(UILabel *)attributionLabel {
    [[GMSPlacesClient sharedClient]
     loadPlacePhoto:photoMetadata
     constrainedToSize:imageView.bounds.size
     scale:imageView.window.screen.scale
     callback:^(UIImage *_Nullable photo, NSError *_Nullable error) {
         if (error) {
             NSLog(@"Error: %@", [error description]);
         } else {
             imageView.image = photo;
             attributionLabel.attributedText = attribution;
         }
     }];
}

@end

//
//  Travel+CoreDataClass.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 12/16/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "Travel+CoreDataClass.h"

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
                 GMSPlacePhotoMetadata *firstPhoto = photos.results.firstObject;
                 [self loadImageForMetadata:firstPhoto imageView:imageView attributionLabel:attributionLabel];
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

@end

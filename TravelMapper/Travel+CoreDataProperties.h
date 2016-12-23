//
//  Travel+CoreDataProperties.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 12/16/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "Travel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Travel (CoreDataProperties)

+ (NSFetchRequest<Travel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cityName;
@property (nullable, nonatomic, copy) NSString *formattedAddress;
@property (nullable, nonatomic, copy) NSDate *dateVisited;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSString *stateName;
@property (nullable, nonatomic, copy) NSString *travelType;
@property (nullable, nonatomic, copy) NSString *placeId;

@end

NS_ASSUME_NONNULL_END

//
//  Travel+CoreDataProperties.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 3/16/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "Travel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Travel (CoreDataProperties)

+ (NSFetchRequest<Travel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cityName;
@property (nullable, nonatomic, copy) NSDate *dateVisited;
@property (nullable, nonatomic, copy) NSString *formattedAddress;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSString *placeId;
@property (nullable, nonatomic, copy) NSString *stateName;
@property (nullable, nonatomic, copy) NSString *travelType;
@property (nullable, nonatomic, copy) NSString *timeZone;

@end

NS_ASSUME_NONNULL_END

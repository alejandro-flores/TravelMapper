//
//  Travel+CoreDataProperties.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 3/16/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "Travel+CoreDataProperties.h"

@implementation Travel (CoreDataProperties)

+ (NSFetchRequest<Travel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Travel"];
}

@dynamic cityName;
@dynamic dateVisited;
@dynamic formattedAddress;
@dynamic latitude;
@dynamic longitude;
@dynamic placeId;
@dynamic stateName;
@dynamic travelType;
@dynamic timeZone;

@end

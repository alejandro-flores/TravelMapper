//
//  Travel+CoreDataProperties.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 12/16/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "Travel+CoreDataProperties.h"

@implementation Travel (CoreDataProperties)

+ (NSFetchRequest<Travel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Travel"];
}

@dynamic cityName;
@dynamic formattedAddress;
@dynamic dateVisited;
@dynamic latitude;
@dynamic longitude;
@dynamic stateName;
@dynamic travelType;
@dynamic placeId;

@end

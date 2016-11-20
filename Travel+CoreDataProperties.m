//
//  Travel+CoreDataProperties.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/11/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "Travel+CoreDataProperties.h"

@implementation Travel (CoreDataProperties)

+ (NSFetchRequest<Travel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Travel"];
}

@dynamic cityName;
@dynamic countryName;
@dynamic latitude;
@dynamic longitude;
@dynamic dateVisited;
@dynamic travelType;

@end

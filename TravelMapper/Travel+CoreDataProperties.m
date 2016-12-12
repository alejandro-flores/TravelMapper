//
//  Travel+CoreDataProperties.m
//  
//
//  Created by Alejandro Martin Flores Naranjo on 12/11/16.
//
//

#import "Travel+CoreDataProperties.h"

@implementation Travel (CoreDataProperties)

+ (NSFetchRequest<Travel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Travel"];
}

@dynamic cityName;
@dynamic countryName;
@dynamic dateVisited;
@dynamic latitude;
@dynamic longitude;
@dynamic travelType;
@dynamic stateName;

@end

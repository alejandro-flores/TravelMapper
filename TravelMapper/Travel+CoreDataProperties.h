//
//  Travel+CoreDataProperties.h
//  
//
//  Created by Alejandro Martin Flores Naranjo on 12/11/16.
//
//

#import "Travel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Travel (CoreDataProperties)

+ (NSFetchRequest<Travel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cityName;
@property (nullable, nonatomic, copy) NSString *countryName;
@property (nullable, nonatomic, copy) NSDate *dateVisited;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSString *travelType;
@property (nullable, nonatomic, copy) NSString *stateName;

@end

NS_ASSUME_NONNULL_END

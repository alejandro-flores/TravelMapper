//
//  TMDetailedTravelViewController.m
//  TravelMapper
//
//  Created by Guests on 12/25/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMDetailedTravelViewController.h"
#import "TMTravelTableViewController.h"
#import "Travel+CoreDataClass.h"
#import <GooglePlaces/GooglePlaces.h>

@interface TMDetailedTravelViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cityImageView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *traveltypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *attributeLabel;


@end

@implementation TMDetailedTravelViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    TMTravelTableViewController *tableVC = [[TMTravelTableViewController alloc]init];
    _cityLabel.text = _cityName;
    _cityLabel.adjustsFontSizeToFitWidth = YES;
    _stateLabel.text = _cityFormattedAddress;
    _stateLabel.adjustsFontSizeToFitWidth = YES;
    _traveltypeLabel.text = [NSString stringWithFormat:@"Travel Type: %@", _travelType];
    _traveltypeLabel.adjustsFontSizeToFitWidth = YES;
    [tableVC loadFirstPhotoForPlace:_placeId imageView:_cityImageView attributionLabel:_attributeLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

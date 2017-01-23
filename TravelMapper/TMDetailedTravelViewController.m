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
#import "LocalWeather.h"

@interface TMDetailedTravelViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *cityImageView;
@property (weak, nonatomic) IBOutlet UILabel *traveltypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *attributeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *highTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *highTempImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lowTempImageView;
@property (strong, nonatomic) LocalWeather *localWeather;

@end

@implementation TMDetailedTravelViewController

float tempKelvin, minTempKelvin, maxTempKelvin;
NSString *description;

- (void)viewDidLoad {
    [super viewDidLoad];
    _localWeather = [[LocalWeather alloc]initWithLatitude:_latitude longitude:_longitude];
    [self setUpUIElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpUIElements {
    _cityLabel.text         = _cityName;
    _stateLabel.text        = _cityFormattedAddress;
    _traveltypeLabel.text   = [NSString stringWithFormat:@"%@", _travelType];
    _tempLabel.text         = [_localWeather kelvinToCelsius:[_localWeather getCurrentWeatherTemp]];
    _highTempLabel.text     = [NSString stringWithFormat:@"↑%@", [_localWeather kelvinToCelsius:[_localWeather getDailyForecastMaxTemp]]];
    _lowTempLabel.text      = [NSString stringWithFormat:@"↓%@", [_localWeather kelvinToCelsius:[_localWeather getDailyForecastMinTemp]]];
    _descriptionLabel.text  = [_localWeather getCurrentWeatherDescription];
    _weatherIconImageView.image = [UIImage imageNamed:[_localWeather getCurrentWeatherIconFileName]];
    
    _cityLabel.adjustsFontSizeToFitWidth        = YES;
    _stateLabel.adjustsFontSizeToFitWidth       = YES;
    _traveltypeLabel.adjustsFontSizeToFitWidth  = YES;
    _tempLabel.adjustsFontSizeToFitWidth        = YES;
    _descriptionLabel.adjustsFontSizeToFitWidth = YES;
    
    [Travel loadFirstPhotoForPlace:_placeId imageView:_cityImageView attributionLabel:_attributeLabel];
}

@end

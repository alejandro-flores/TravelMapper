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
#import "SWRevealViewController.h"
#import "TMLocalWeatherManager.h"
#import "TMTimeZoneManager.h"

@interface TMDetailedTravelViewController ()

@property (strong, nonatomic) SWRevealViewController *revealController;
@property (weak, nonatomic) IBOutlet UIImageView *weatherIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *highTempImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lowTempImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cityImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *traveltypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *attributeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *highTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeLabel;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) TMLocalWeatherManager *localWeatherManager;
@property (strong, nonatomic) TMTimeZoneManager *timeZoneManager;
@property (strong, nonatomic) UIColor *nightColor;

@end

@implementation TMDetailedTravelViewController

float tempKelvin;
float minTempKelvin;
float maxTempKelvin;
NSString *description;

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Disables opening the menu while in this view.
    _revealController = [self revealViewController];
    _revealController.panGestureRecognizer.enabled = NO;
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _localWeatherManager = [[TMLocalWeatherManager alloc]initWithLatitude:_latitude longitude:_longitude];
    _timeZoneManager = [[TMTimeZoneManager alloc]initWithLatitude:_latitude longitude:_longitude];
    [self setUpUIElements];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Re-enables the PanGestureRecognizer when leaving this view.
    _revealController.panGestureRecognizer.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper Methods
- (void)setUpUIElements {
    _nightColor = [UIColor colorWithRed:199.0f / 255.0f green:199.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f];
    if (![_timeZoneManager isDay])
        self.view.backgroundColor = _nightColor;
    
    _cityLabel.text         = _cityName;
    _stateLabel.text        = _cityFormattedAddress;
    _traveltypeLabel.text   = [NSString stringWithFormat:@"%@", _travelType];
    _descriptionLabel.text  = [_localWeatherManager getCurrentWeatherDescription];
    _weatherIconImageView.image = [UIImage imageNamed:[_localWeatherManager getCurrentWeatherIconFileName]];
    [self checkSelectedTemperatureUnit];
    _cityLabel.adjustsFontSizeToFitWidth        = YES;
    _stateLabel.adjustsFontSizeToFitWidth       = YES;
    _traveltypeLabel.adjustsFontSizeToFitWidth  = YES;
    _tempLabel.adjustsFontSizeToFitWidth        = YES;
    _descriptionLabel.adjustsFontSizeToFitWidth = YES;
    
    [Travel loadFirstPhotoForPlace:_placeId imageView:_cityImageView attributionLabel:_attributeLabel];
}


/**
 * Checks the stored temperature unit settings and determines whether the labels will display
 * the temperatures in Celsius or Fahrenheit according to the stored value.
 */
- (void)checkSelectedTemperatureUnit {
    _tempLabel.text     = ([[_userDefaults stringForKey:@"tempUnit"] isEqualToString:@"C"] ?
                               [_localWeatherManager kelvinToCelsius:[_localWeatherManager getCurrentWeatherTemp]] :
                               [_localWeatherManager kelvinToFahrenheit:[_localWeatherManager getCurrentWeatherTemp]]);
    
    _highTempLabel.text = ([[_userDefaults stringForKey:@"tempUnit"] isEqualToString:@"C"] ?
                               [NSString stringWithFormat:@"↑%@", [_localWeatherManager kelvinToCelsius:[_localWeatherManager getDailyForecastMaxTemp]]] :
                               [NSString stringWithFormat:@"↑%@", [_localWeatherManager kelvinToFahrenheit:[_localWeatherManager getDailyForecastMaxTemp]]]);
    
    _lowTempLabel.text  = ([[_userDefaults stringForKey:@"tempUnit"] isEqualToString:@"C"] ?
                               [NSString stringWithFormat:@"↓%@", [_localWeatherManager kelvinToCelsius:[_localWeatherManager getDailyForecastMinTemp]]] :
                               [NSString stringWithFormat:@"↓%@", [_localWeatherManager kelvinToFahrenheit:[_localWeatherManager getDailyForecastMinTemp]]]);
    
    _localTimeLabel.text= [_timeZoneManager getCurrentTime];
}

@end

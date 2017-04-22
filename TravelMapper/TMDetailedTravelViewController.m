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
#import "TMCacheManager.h"

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
@property (strong, nonatomic) UIImage *currentWeatherIcon;
@property (strong, nonatomic) UIColor *nightColor;

@end

@implementation TMDetailedTravelViewController
#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Disables opening the menu while in this view.
    _revealController = [self revealViewController];
    _revealController.panGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadFieldsAsync];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.tabBarController.tabBar setBarStyle:UIBarStyleDefault];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Re-enables the PanGestureRecognizer when leaving this view.
    _revealController.panGestureRecognizer.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper Methods

/**
 * Uses asynchronoud calls to get the city image for each Travel and to load all other data into the view.
 */
- (void)loadFieldsAsync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        GMSPlacePhotoMetadata *cityImage = [[TMCacheManager sharedInstance] getCachedImageForKey:_placeId];
        _currentWeatherIcon = [UIImage imageNamed:_iconFileName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cityImage) {
                [Travel loadImageForMetadata:cityImage
                                   imageView:_cityImageView
                                 attribution:cityImage.attributions
                            attributionLabel:_attributeLabel];
            }
            else {
                // Gets a new city image, displays it in the cell and caches it.
                [Travel loadFirstPhotoForPlace:_placeId
                                     imageView:_cityImageView
                              attributionLabel:_attributeLabel];
            }
            [self setUpUIElements];
        });
    });
}

/**
 * Sets up the values for the different fields used in this view.
 */
- (void)setUpUIElements {
    _nightColor = [UIColor colorWithRed:36.0f / 255.0f green:42.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f];
    if (!_isDay) {
        self.view.backgroundColor = _nightColor;
        [self changeViewsColor:[UIColor whiteColor]];
    }
    
    _cityLabel.text         = _cityName;
    _stateLabel.text        = _cityFormattedAddress;
    _traveltypeLabel.text   = [NSString stringWithFormat:@"%@", _travelType];
    _descriptionLabel.text  = _weatherDescription;
    _weatherIconImageView.image = _currentWeatherIcon;
    _tempLabel.text = _currentTemp;
    _highTempLabel.text = _highTemp;
    _lowTempLabel.text = _lowTemp;
    _localTimeLabel.text= _currentTime;
    _cityLabel.adjustsFontSizeToFitWidth        = YES;
    _stateLabel.adjustsFontSizeToFitWidth       = YES;
    _traveltypeLabel.adjustsFontSizeToFitWidth  = YES;
    _tempLabel.adjustsFontSizeToFitWidth        = YES;
    _descriptionLabel.adjustsFontSizeToFitWidth = YES;
}

/**
 * Changes the Labels, Images and Bars color/themes to dark.
 * Used when changing the to night colors 
 */
- (void)changeViewsColor:(UIColor *)color {
    _cityLabel.textColor = color;
    _stateLabel.textColor = color;
    _traveltypeLabel.textColor = color;
    _descriptionLabel.textColor = color;
    _tempLabel.textColor = color;
    _highTempLabel.textColor = color;
    _lowTempLabel.textColor = color;
    _localTimeLabel.textColor = color;
    _weatherIconImageView.tintColor = color;
    [self.tabBarController.tabBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

@end

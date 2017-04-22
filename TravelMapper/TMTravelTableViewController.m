//
//  TMTravelTableViewController.m
//  Travel Mapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/7/16.
//  Copyright © 2016 Alejandro Flores. All rights reserved.
//

#import "TMTravelTableViewController.h"
#import "TMMapViewController.h"
#import "Travel+CoreDataClass.h"
#import "TMTravelTableViewCell.h"
#import <GooglePlaces/GooglePlaces.h>
#import "TMDetailedTravelViewController.h"
#import "TMCacheManager.h"
#import "TMLocalWeatherManager.h"
#import "TMTimeZoneManager.h"
@import CoreData;

@interface TMTravelTableViewController ()

@property (strong, nonatomic) TMLocalWeatherManager *localWeatherManager;
@property (strong, nonatomic) TMTimeZoneManager *timeZoneManager;
@property (strong, nonatomic) NSMutableDictionary *weatherDataDict;
@property (strong, nonatomic) NSMutableDictionary *latlonDict;
@property (strong, nonatomic) NSMutableArray *travelsArray;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSString *weatherDescription;
@property (strong, nonatomic) NSString *formattedAddress;
@property (strong, nonatomic) NSString *iconFileName;
@property (strong, nonatomic) NSString *currentTemp;
@property (strong, nonatomic) NSString *currentTime;
@property (strong, nonatomic) NSString *travelType;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *highTemp;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSString *lowTemp;

@property (assign, nonatomic) BOOL isDay;

@end

@implementation TMTravelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRefreshControl];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    _localWeatherManager = [[TMLocalWeatherManager alloc]init];
    _timeZoneManager = [[TMTimeZoneManager alloc]init];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _latlonDict = [NSMutableDictionary new];
    _weatherDataDict = [NSMutableDictionary new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchTravels];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getTravelLatLongPairs];
        for (Travel *travel in _travelsArray) {
            NSString *tempPlaceID = [NSString stringWithFormat:@"%@", [travel valueForKey:@"placeId"]];
            [self fetchWeatherForAllTravels:tempPlaceID];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_travelsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSUInteger cell_height = 275;
    
    return cell_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    [view setBackgroundColor:[UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:0.5]];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMTravelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelCell" forIndexPath:indexPath];
    [self getTravelFields:indexPath];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *tempPlaceID = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"placeId"]];
        GMSPlacePhotoMetadata *cityImage = [[TMCacheManager sharedInstance] getCachedImageForKey:tempPlaceID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cityImage) {
                [Travel loadImageForMetadata:cityImage
                                   imageView:cell.cityImageView
                                 attribution:cityImage.attributions
                            attributionLabel:cell.attributionLabel];
            } else {
                // Gets a new city image, displays it in the cell and caches it.
                [Travel loadFirstPhotoForPlace:tempPlaceID
                                     imageView:cell.cityImageView
                              attributionLabel:cell.attributionLabel];
                
            }
        });
    });
    
    cell.title.text = _cityName;
    cell.title.adjustsFontSizeToFitWidth = YES;
    cell.subtitle.text = _formattedAddress;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempPlaceID = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"placeId"]];
    NSString *tempTimeZone = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"timeZone"]];
    [self getTravelFields:indexPath];
    [self getWeatherData:tempPlaceID];
    [self getCurrentTime:tempPlaceID timeZone:tempTimeZone];
    [self performSegueWithIdentifier:@"toDetaliedTravelVC" sender:self];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Travel *travelToDelete = [_travelsArray objectAtIndex:indexPath.section];
        [_managedObjectCtx deleteObject:travelToDelete];
        [_travelsArray removeObjectAtIndex:indexPath.section];
        
        NSError *err = nil;
        if (![_managedObjectCtx save:&err]) {
        }
        
        [tableView beginUpdates];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [[TMCacheManager sharedInstance] removeCachedImageForKey:_placeId];
        [tableView endUpdates];
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *navController = (UINavigationController *)viewController;
    if ([navController.topViewController isKindOfClass:[TMMapViewController class]]) {
        TMMapViewController *mvc = (TMMapViewController *)navController.topViewController;
        [mvc setManagedObjectCtx:_managedObjectCtx]; // Injects the ManagedObjectContext
    }
    return YES;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toDetaliedTravelVC"]) {
        TMDetailedTravelViewController *detailedVC = [segue destinationViewController];
        [self setDetailedViewControllerFields:detailedVC];
    }
}

#pragma mark - Helper Methods
/*
 * Used to fetch the Blades from the Persistent Data Store and store them in the bladesArray
 */
- (void)fetchTravels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Travel"];
    _travelsArray = [[_managedObjectCtx executeFetchRequest:fetchRequest error:nil] mutableCopy];
    _travelsArray = [[[_travelsArray reverseObjectEnumerator] allObjects] mutableCopy]; // Reversed Array so that newly added Travels show up first.
}

/**
 * Adds a UIRefreshControl to the table view to update the table.
 */
- (void)addRefreshControl {
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:refreshControl];
}

/**
 * When the refresh control is pulled down, this method
 * polls Core Data and updates the table view
 * @param refreshControl UIRefreshControl requesting action
 */
- (void)refreshTable:(UIRefreshControl *)refreshControl {
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}


/**
 * Obtains a Travel's fields from CoreData to be used throughout the application.

 * @param indexPath Travel's indexPath.
 */
- (void)getTravelFields:(NSIndexPath *)indexPath {
    _formattedAddress   = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"formattedAddress"]];
    _travelType         = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"travelType"]];
    _longitude          = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"longitude"]];
    _cityName           = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"cityName"]];
    _latitude           = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"latitude"]];
    _placeId            = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"placeId"]];
}


/**
 * Queries the latitude and longitude values for each Travel in the table view and stores it in a dictionary for later use.
 */
- (void)getTravelLatLongPairs {
    NSString *latLon, *placeId;
    for (Travel *travel in _travelsArray) {
        placeId = [NSString stringWithFormat:@"%@", [travel valueForKey:@"placeId"]];
        latLon = [NSString stringWithFormat:@"%@+%@", [travel valueForKey:@"latitude"], [travel valueForKey:@"longitude"]];
        
        // Add lat and long values to the Dictionary with the placeId as the key
        [_latlonDict setObject:latLon forKey:placeId];
    }
}


/**
 * Fetches the weather data for all the Travels stored in the table view, then packs
 * that data in a NSMutableDictionary with the Travel's place ID as the key.

 * @param placeID The location's place ID.
 */
- (void)fetchWeatherForAllTravels:(NSString *)placeID {
    NSString *allWXData;
    NSArray *items = [[_latlonDict valueForKey:placeID] componentsSeparatedByString:@"+"];
    NSString *lat = [items objectAtIndex:0];
    NSString *lon = [items objectAtIndex:1];
    
    [_localWeatherManager queryWeather:lat longitude:lon];
    _weatherDescription = [_localWeatherManager getCurrentWeatherDescription];
    _iconFileName = [_localWeatherManager getCurrentWeatherIconFileName];
    [self checkSelectedTemperatureUnitForLowTemp:[_localWeatherManager getDailyForecastMinTemp]
                                        highTemp:[_localWeatherManager getDailyForecastMaxTemp]
                                  AndCurrentTemp:[_localWeatherManager getCurrentWeatherTemp]];
    
    allWXData = [NSString stringWithFormat:@"%@+%@+%@+%@+%@", _weatherDescription, _iconFileName, _currentTemp, _lowTemp, _highTemp];
    // Store values in the weatherDataDictionary with the placeID as the key
    [_weatherDataDict setObject:allWXData forKey:placeID];
}


/**
 * Obtains the locaton's current time and whether it is nday or night values.
 * @param placeID The target's place ID.
 * @param timeZone String containing the location's time zone (e.g UTC -5).
 */
- (void)getCurrentTime:(NSString *)placeID timeZone:(NSString *)timeZone {
    NSArray *items = [[_latlonDict valueForKey:placeID] componentsSeparatedByString:@"+"];
    NSString *lat = [items objectAtIndex:0];
    NSString *lon = [items objectAtIndex:1];
    
    [_timeZoneManager queryCurrentTimeForLatitude:lat longitude:lon];
    _currentTime = [_timeZoneManager getCurrentTime];
    _isDay = [_timeZoneManager isDay];
}


/**
 * Obtains the location's required weather information.
 * @param placeID The target's place ID.
 */
- (void)getWeatherData:(NSString *)placeID {
    NSArray *wxDataItems = [[_weatherDataDict objectForKey:placeID] componentsSeparatedByString:@"+"];
    _weatherDescription = [wxDataItems objectAtIndex:0];
    _iconFileName = [wxDataItems objectAtIndex:1];
    _currentTemp = [wxDataItems objectAtIndex:2];
    _lowTemp = [wxDataItems objectAtIndex:3];
    _highTemp = [wxDataItems objectAtIndex:4];
}

/**
 * Checks the stored temperature unit settings and determines whether the labels will display
 * the temperatures in Celsius or Fahrenheit according to the stored value.
 */
- (void)checkSelectedTemperatureUnitForLowTemp:(float)lowTemp highTemp:(float)highTemp AndCurrentTemp:(float)currentTemp {
    _currentTemp = ([[_userDefaults stringForKey:@"tempUnit"] isEqualToString:@"C"] ?
                    [_localWeatherManager kelvinToCelsius:currentTemp] :
                    [_localWeatherManager kelvinToFahrenheit:currentTemp]);
    
    _highTemp = ([[_userDefaults stringForKey:@"tempUnit"] isEqualToString:@"C"] ?
                 [NSString stringWithFormat:@"↑%@", [_localWeatherManager kelvinToCelsius:highTemp]] :
                 [NSString stringWithFormat:@"↑%@", [_localWeatherManager kelvinToFahrenheit:highTemp]]);
    
    _lowTemp  = ([[_userDefaults stringForKey:@"tempUnit"] isEqualToString:@"C"] ?
                 [NSString stringWithFormat:@"↓%@", [_localWeatherManager kelvinToCelsius:lowTemp]] :
                 [NSString stringWithFormat:@"↓%@", [_localWeatherManager kelvinToFahrenheit:lowTemp]]);
}


/**
 * Sets the TMDetailedTravelViewController's fields. Called in prepareForSegue.
 * @param detailedVC The View Controller involved in the segue.
 */
- (void)setDetailedViewControllerFields:(TMDetailedTravelViewController *)detailedVC {
    [detailedVC setCityName:_cityName];
    [detailedVC setCityFormattedAddress:_formattedAddress];
    [detailedVC setTravelType:_travelType];
    [detailedVC setPlaceId:_placeId];
    [detailedVC setLatitude:_latitude];
    [detailedVC setLongitude:_longitude];
    [detailedVC setWeatherDescription:_weatherDescription];
    [detailedVC setIconFileName:_iconFileName];
    [detailedVC setCurrentTemp:_currentTemp];
    [detailedVC setLowTemp:_lowTemp];
    [detailedVC setHighTemp:_highTemp];
    [detailedVC setCurrentTime:_currentTime];
    [detailedVC setIsDay:_isDay];
}


@end

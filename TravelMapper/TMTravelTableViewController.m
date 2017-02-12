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
@import CoreData;

@interface TMTravelTableViewController ()

@property (strong, nonatomic) NSString *cityName, *cityFormattedAddress, *travelType, *placeId, *latitude, *longitude;
@property (strong, nonatomic) NSMutableArray *travelsArray;
@property (strong, nonatomic) NSString *imageURL;

@end

@implementation TMTravelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRefreshControl];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchTravels];
    [self.tableView reloadData];
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
    _cityName = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"cityName"]];
    _cityFormattedAddress = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"formattedAddress"]];
    _placeId = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"placeId"]];
    
    [Travel loadFirstPhotoForPlace:_placeId imageView:cell.cityImageView attributionLabel:cell.attributionLabel];
    
    cell.title.text = _cityName;
    cell.title.adjustsFontSizeToFitWidth = YES;
    cell.subtitle.text = _cityFormattedAddress;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _cityName = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"cityName"]];
    _cityFormattedAddress = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"formattedAddress"]];
    _travelType = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"travelType"]];
    _placeId = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"placeId"]];
    _latitude = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"latitude"]];
    _longitude = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"longitude"]];
    
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
            NSLog(@"TVC - Error deleting Travel: %@", [err localizedDescription]);
        }
        
        [tableView beginUpdates];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
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
        [detailedVC setCityName:_cityName];
        [detailedVC setCityFormattedAddress:_cityFormattedAddress];
        [detailedVC setTravelType:_travelType];
        [detailedVC setPlaceId:_placeId];
        [detailedVC setLatitude:_latitude];
        [detailedVC setLongitude:_longitude];
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

@end

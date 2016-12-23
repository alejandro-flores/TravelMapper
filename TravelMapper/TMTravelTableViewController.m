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
@import CoreData;

@interface TMTravelTableViewController ()
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
    NSLog(@"Travels Array Count = %ld", (unsigned long)[_travelsArray count]);
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
    [view setBackgroundColor:[UIColor colorWithRed:242.0 green:242.0 blue:242.0 alpha:0.5]];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMTravelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelCell" forIndexPath:indexPath];
    NSString *cityName = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"cityName"]];
    NSString *formattedAddress = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"formattedAddress"]];
    NSString *placeID = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.section] valueForKey:@"placeId"]];
    
    [self loadFirstPhotoForPlace:placeID imageView:cell.cityImageView attributionLabel:cell.attributionLabel];
    
    cell.title.text = cityName;
    cell.title.adjustsFontSizeToFitWidth = YES;
    cell.subtitle.text = formattedAddress;
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

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

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Fetch Place Photo
- (void)loadFirstPhotoForPlace:(NSString *)placeID imageView:(UIImageView *)imageView attributionLabel:(UILabel *)attributionLabel {
    [[GMSPlacesClient sharedClient]
     lookUpPhotosForPlaceID:placeID
     callback:^(GMSPlacePhotoMetadataList *_Nullable photos,
                NSError *_Nullable error) {
         if (error) {
             NSLog(@"Error: %@", [error description]);
         } else {
             if (photos.results.count > 0) {
                 GMSPlacePhotoMetadata *firstPhoto = photos.results.firstObject;
                 [self loadImageForMetadata:firstPhoto imageView:imageView attributionLabel:attributionLabel];
             }
         }
     }];
}

- (void)loadImageForMetadata:(GMSPlacePhotoMetadata *)photoMetadata imageView:(UIImageView *)imageView attributionLabel:(UILabel *)attributionLabel {
    [[GMSPlacesClient sharedClient]
     loadPlacePhoto:photoMetadata
     constrainedToSize:imageView.bounds.size
     scale:imageView.window.screen.scale
     callback:^(UIImage *_Nullable photo, NSError *_Nullable error) {
         if (error) {
             NSLog(@"Error: %@", [error description]);
         } else {
             imageView.image = photo;
             attributionLabel.attributedText = photoMetadata.attributions;
         }
     }];
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

#pragma mark - Helper Methods
/*
 * Used to fetch the Blades from the Persistent Data Store and store them in the bladesArray
 */
- (void)fetchTravels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Travel"];
    _travelsArray = [[_managedObjectCtx executeFetchRequest:fetchRequest error:nil]mutableCopy];
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

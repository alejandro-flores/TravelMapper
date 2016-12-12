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
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/AFHTTPSessionManager.h>
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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchTravels];
    [self.tableView reloadData];
    NSLog(@"Travels Array Count = %ld", (unsigned long)[_travelsArray count]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_travelsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSUInteger cell_height = 300;
    return cell_height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMTravelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelCell" forIndexPath:indexPath];
    NSString *cityName = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.row] valueForKey:@"cityName"]];
    NSString *stateName = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.row] valueForKey:@"stateName"]];
    NSString *countryName = [NSString stringWithFormat:@"%@", [[_travelsArray objectAtIndex:indexPath.row] valueForKey:@"countryName"]];
    
    _imageURL = [self getImageURLWithCityName:cityName stateName:stateName countryName:countryName];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_imageURL]];
    
    //cell.flagImageView.image = [UIImage imageNamed:@"IMAGE_NAME"];
    
    cell.placeLabel.text = [NSString stringWithFormat:@"%@, %@", cityName, countryName];
    
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
        Travel *travelToDelete = [_travelsArray objectAtIndex:indexPath.row];
        [_managedObjectCtx deleteObject:travelToDelete];
        [_travelsArray removeObjectAtIndex:indexPath.row];
        
        NSError *err = nil;
        if (![_managedObjectCtx save:&err]) {
            NSLog(@"TVC - Error deleting Travel: %@", [err localizedDescription]);
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *navController = (UINavigationController *)viewController;
    if ([navController.topViewController isKindOfClass:[TMMapViewController class]]) {
        TMMapViewController *mvc = (TMMapViewController *)navController.topViewController;
        [mvc setManagedObjectCtx:_managedObjectCtx]; // Injects the ManagedObjectContext
    }
    return YES;
}

#pragma mark - Flickr API Calls
- (NSString *)getImageURLWithCityName:(NSString *)cityName stateName:(NSString *)stateName countryName:(NSString *)countryName {
    NSMutableArray *flickrFeeds = [NSMutableArray new];
    __block NSDictionary *items = [NSMutableDictionary new];
    __block NSDictionary *mediaDictionary = [NSMutableDictionary new];
    __block NSString *resultURL = @"";
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/feeds/photos_public.gne?tags=%@,%@,%@&;tagmode=any&format=json&nojsoncallback=1", cityName, stateName, countryName];
    
#warning The url is being generated correctly, but the block is being skipped for some reason. Fix this
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id jsonObject) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonResult = [[NSDictionary alloc]initWithDictionary:jsonObject];
            [flickrFeeds addObject:[jsonResult objectForKey:@"items"]];
            items = [[jsonResult valueForKey:@"items"] objectAtIndex:0];
            mediaDictionary = [items valueForKey:@"media"];
            resultURL = [NSString stringWithFormat:@"%@", [mediaDictionary valueForKey:@"m"]];
            NSLog(@"URL for %@: %@", cityName, resultURL);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    return resultURL;
}

- (NSURL *)createURLWithCityName:(NSString *)cityName stateName:(NSString *)stateName countryName:(NSString *)countryName {
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/feeds/photos_public.gne?tags=%@,%@,%@&;tagmode=any&format=json&nojsoncallback=1", cityName, stateName, countryName];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return url;
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

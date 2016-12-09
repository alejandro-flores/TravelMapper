//
//  TMTravelTableViewController.m
//  Travel Mapper
//
//  Created by Alejandro Martin Flores Naranjo on 11/7/16.
//  Copyright © 2016 Alejandro Flores. All rights reserved.
//

#import "TMTravelTableViewController.h"
@import CoreData;

@interface TMTravelTableViewController ()
@property (strong, nonatomic) NSMutableArray *travelsArray;

@end

@implementation TMTravelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchTravels];
    NSLog(@"Travels Array Count = %ld", (unsigned long)[_travelsArray count]);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"travelCell"];
    }
    
    cell.textLabel.text = [[_travelsArray objectAtIndex:indexPath.row] valueForKey:@"cityName"];
    cell.detailTextLabel.text = [[_travelsArray objectAtIndex:indexPath.row] valueForKey:@"countryName"];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Helper Methods
/**
 * Used to fetch the Blades from the Persistent Data Store and store them in the bladesArray
 */
- (void)fetchTravels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Travel"];
    _travelsArray = [[_managedObjectCtx executeFetchRequest:fetchRequest error:nil]mutableCopy];
}

@end

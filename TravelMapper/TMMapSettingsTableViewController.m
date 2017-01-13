//
//  TMMapSettingsTableViewController.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/10/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMMapSettingsTableViewController.h"

static const NSInteger SAT_ROW = 0;
static const NSInteger HYB_ROW = 1;

@interface TMMapSettingsTableViewController ()

@property (strong, nonatomic) NSArray *menuItemsIdentifiers;

@end

@implementation TMMapSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hides empty rows
    _menuItemsIdentifiers = @[@"standardCell", @"hybridCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuItemsIdentifiers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [_menuItemsIdentifiers objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    switch (row) {
        case SAT_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeNormal];
            break;
        case HYB_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeHybrid];
            break;
        default:
            break;
    }
}

@end

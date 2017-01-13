//
//  TMMapSettingsTableViewController.m
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 1/10/17.
//  Copyright © 2017 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMMapSettingsTableViewController.h"

static const NSInteger STD_ROW = 0;
static const NSInteger SAT_ROW = 1;
static const NSInteger HYB_ROW = 2;

@interface TMMapSettingsTableViewController ()

@property (strong, nonatomic) NSArray *menuItems;

@end

@implementation TMMapSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuItems = @[@"Standard", @"Satellite", @"Hybrid"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        // Customize Cell
        NSString *cellText = nil;
        NSInteger row = indexPath.row;
        switch (row) {
            case STD_ROW:
                cellText = [NSString stringWithFormat:@"%@", [_menuItems objectAtIndex:STD_ROW]];
                break;
            case SAT_ROW:
                cellText = [NSString stringWithFormat:@"%@", [_menuItems objectAtIndex:SAT_ROW]];;
                break;
            case HYB_ROW:
                cellText = [NSString stringWithFormat:@"%@", [_menuItems objectAtIndex:HYB_ROW]];;
                break;
            default:
                break;
        }
        
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = cellText;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    switch (row) {
        case STD_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeNormal];
            break;
        case SAT_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeSatellite];
            break;
        case HYB_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeHybrid];
            break;
        default:
            break;
    }
}

@end

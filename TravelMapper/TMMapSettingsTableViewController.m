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

@property (weak, nonatomic) IBOutlet UISegmentedControl *tempSegmentedControl;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation TMMapSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hides empty rows
    _userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Read NSUserDefaults to select chosen temperature unit
    [_tempSegmentedControl setSelectedSegmentIndex:([[_userDefaults stringForKey:@"tempUnit"] isEqualToString:@"C"] ? 0 : 1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    switch (row) {
        case SAT_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeNormal];
            [_userDefaults setObject:@"satellite" forKey:@"mapType"];
            break;
        case HYB_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeHybrid];
            [_userDefaults setObject:@"hybrid" forKey:@"mapType"];
            break;
        default:
            break;
    }
    [_userDefaults synchronize];
}

- (IBAction)changeTemperatureUnits:(UISegmentedControl *)sender {
    NSInteger index = [_tempSegmentedControl selectedSegmentIndex];
    
    switch (index) {
        case 0:
            [_userDefaults setObject:@"C" forKey:@"tempUnit"];
            break;
        case 1:
            [_userDefaults setObject:@"F" forKey:@"tempUnit"];
            break;
        default:
            break;
    }
    [_userDefaults synchronize];
}

@end

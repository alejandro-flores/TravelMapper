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
@property (strong, nonatomic) NSString *chosenTempUnits;

@end

@implementation TMMapSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hides empty rows
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
            break;
        case HYB_ROW:
            [self.delegate willChangeMapType:self mapType:kGMSTypeHybrid];
            break;
        default:
            break;
    }
}

- (IBAction)changeTemperatureUnits:(UISegmentedControl *)sender {
    NSInteger index = [_tempSegmentedControl selectedSegmentIndex];
    
    _chosenTempUnits = [NSString stringWithFormat:@"%@", [_tempSegmentedControl titleForSegmentAtIndex:index]];
}

@end

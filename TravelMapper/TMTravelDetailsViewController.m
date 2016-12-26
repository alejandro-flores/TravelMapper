//
//  TMTravelDetailsViewController.m
//  TravelMapper
//
//  Created by Guests on 12/24/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMTravelDetailsViewController.h"
#import "TMTravelDetailsBounceAnimationController.h"
#import "TMTravelDetailsPresentationController.h"
#import "Travel+CoreDataClass.h"

@interface TMTravelDetailsViewController () <UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *travelTypeSegmentedControl;
@property (strong, nonatomic) NSString *travelType;
@end

@implementation TMTravelDetailsViewController

#pragma mark - Lifecycle
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self respondsToSelector:@selector(setTransitioningDelegate:)]) {
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.transitioningDelegate = self;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Default Selected is index 0 for "Vacation" if no other type is chosen from the segmented control.
    _travelType = [NSString stringWithFormat:@"%@", [_travelTypeSegmentedControl titleForSegmentAtIndex:0]];
    _cityNameLabel.text = [NSString stringWithString:_place.name];
    _stateLabel.text = [NSString stringWithString:_place.formattedAddress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[TMTravelDetailsBounceAnimationController alloc] init];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[TMTravelDetailsPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

#pragma mark - IBActions
- (IBAction)saveButon:(UIBarButtonItem *)sender {
    [self storeTravel:_place];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButton:(UIBarButtonItem *)sender {
}

- (IBAction)pickTravelType:(UISegmentedControl *)sender {
    NSInteger index = [self.travelTypeSegmentedControl selectedSegmentIndex];
    _travelType = [NSString stringWithFormat:@"%@", [_travelTypeSegmentedControl titleForSegmentAtIndex:index]];
}

#pragma mark - Core Data
- (void)storeTravel:(GMSPlace *)place {
    Travel *newTravel = [NSEntityDescription insertNewObjectForEntityForName:@"Travel"
                                                      inManagedObjectContext:_managedObjectCtx];
    [newTravel setValue:place.name forKey:@"cityName"];
    [newTravel setValue:place.formattedAddress forKey:@"formattedAddress"];
    [newTravel setValue:place.placeID forKey:@"placeId"];
    [newTravel setValue:[NSNumber numberWithDouble:place.coordinate.latitude] forKey:@"latitude"];
    [newTravel setValue:[NSNumber numberWithDouble:place.coordinate.longitude] forKey:@"longitude"];
    [newTravel setValue:[NSDate date] forKey:@"dateVisited"];
    [newTravel setValue:_travelType forKey:@"travelType"];
    
    //Store the New Blade to Persistent Store
    NSError *travelSaveError = nil;
    if (![_managedObjectCtx save:&travelSaveError])
        NSLog(@"TMAPVC -- Error Saving New Travel: %@", [travelSaveError localizedDescription]);
    NSLog(@"TMAPVC -- Saved New Travel");
}

@end

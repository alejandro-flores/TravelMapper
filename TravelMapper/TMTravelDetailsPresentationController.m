//
//  TMTravelDetailsPresentationController.m
//  TravelMapper
//
//  Created by Guests on 12/24/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import "TMTravelDetailsPresentationController.h"

@interface TMTravelDetailsPresentationController()

@property (strong, readonly) UIView *dimmedBackgroundView;

@end

@implementation TMTravelDetailsPresentationController

#pragma mark - UIPresentationController Required Methods
- (UIView *)dimmedBackgroundView {
    static UIView *instance = nil;
    if (instance == nil) {
        instance = [[UIView alloc]initWithFrame:self.containerView.bounds];
        instance.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    }

    return instance;
}

- (void)presentationTransitionWillBegin {
    UIView *presentedView = self.presentedViewController.view;
    [self setUpPresentedView:presentedView];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> ctx) {
        self.dimmedBackgroundView.alpha = 1.0;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmedBackgroundView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmedBackgroundView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmedBackgroundView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGFloat size = 350;
    CGRect frame = CGRectMake((self.containerView.frame.size.width - size) / 2, (self.containerView.frame.size.height - size) / 2, size, size);
    
    return frame;
}

- (void)containerViewWillLayoutSubviews {
    self.dimmedBackgroundView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

#pragma mark - Helper Methods
- (void)setUpPresentedView:(UIView *)presentedView {
    presentedView.layer.cornerRadius = 0;
    presentedView.layer.shadowColor = [[UIColor blackColor]CGColor];
    presentedView.layer.shadowOffset = CGSizeMake(0, 10);
    presentedView.layer.shadowRadius = 10;
    presentedView.layer.shadowOpacity = 0.5;
    
    self.dimmedBackgroundView.frame = self.containerView.bounds;
    self.dimmedBackgroundView.alpha = 0;
    [self.containerView addSubview:self.dimmedBackgroundView];
}

@end

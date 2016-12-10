//
//  TMTravelTableViewCell.h
//  TravelMapper
//
//  Created by Alejandro Martin Flores Naranjo on 12/10/16.
//  Copyright © 2016 Alejandro Martin Flores Naranjo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMTravelTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cityImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *flagImageView;
@end

//
//  AmLiveCell.h
//  InterestMe
//
//  Created by Portanos on 7/20/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//
#import "InterestMe-Swift.h" //ADVSegmentedControl

#import <UIKit/UIKit.h>
//#import "ADVSegmentedControl.h"

@interface AmLiveCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *directionTextView;
@property (weak, nonatomic) IBOutlet ADVSegmentedControl *customSegControl;


@end

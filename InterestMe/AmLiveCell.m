//
//  AmLiveCell.m
//  InterestMe
//
//  Created by Portanos on 7/20/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "AmLiveCell.h"
#import <Parse/Parse.h>
#import "InterestMe-Swift.h" //ADVSegmentedControl

@implementation AmLiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //set up the playing button
    if ([[PFUser currentUser][@"playing"] isEqualToString:@"YES"]) {
        self.customSegControl.selectedIndex=0;
    } else {
        self.customSegControl.selectedIndex=1;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)segmentChanged:(ADVSegmentedControl *)sender {
    NSInteger selectedInt=sender.selectedIndex;
        if (selectedInt==0) {
            [PFUser currentUser][@"playing"]=@"YES";
        } else {
            [PFUser currentUser][@"playing"]=@"NO";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playingStatusChanged"
                                                            object:self
                                                          userInfo:nil];
        [[PFUser currentUser] saveInBackground];
}

@end

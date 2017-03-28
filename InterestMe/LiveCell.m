//
//  LiveCell.m
//  InterestMe
//
//  Created by Portanos on 7/20/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "LiveCell.h"

@implementation LiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.userInteractionEnabled=NO;
    self.interestsLabel.userInteractionEnabled=NO;
    self.interestsLabel.userInteractionEnabled=NO;

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

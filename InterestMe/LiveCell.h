//
//  LiveCell.h
//  InterestMe
//
//  Created by Portanos on 7/20/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *interestsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceAwayLabel;
@property (weak, nonatomic) IBOutlet UILabel *numMessagesLabel;

@property (weak, nonatomic) IBOutlet UIButton *commentButton; //doesn't really need to be a button (I'm planning to have a tap take you to their messages, but okay--can look more into this if the app gets popular...)
@property (weak, nonatomic) IBOutlet UIImageView *discolureImageView;
@end

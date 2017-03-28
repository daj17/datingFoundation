//
//  profileCell.h
//  InterestMe
//
//  Created by Portanos on 5/28/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface profileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

@end

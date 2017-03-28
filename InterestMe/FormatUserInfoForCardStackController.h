//
//  FormatUserInfoForCardStackController.h
//  InterestMe
//
//  Created by Portanos on 7/10/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

// Prepares Cardstack basic info

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FormatUserInfoForCardStackController : UIViewController

+(NSString * )returnCommonInterestStringInfoBetweenMe:(PFUser *)me andUser:(PFUser *)otherPerson;
+(NSString * )returnMainInfoForUser:(PFUser *)user;

@end

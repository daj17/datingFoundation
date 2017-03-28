//
//  RequestLocationAccessController.h
//  Portanos
//
//  Created by Portanos on 12/7/15.
//  Copyright © 2015 Portanos LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestLocationAccessController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *allowButton;
@property (weak, nonatomic) IBOutlet UIButton *dontAllowButton;

@property (strong, nonatomic) NSString * firstNameString;
@property (strong, nonatomic) NSString * lastNameString;

@end

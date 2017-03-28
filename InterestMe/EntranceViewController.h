//
//  EntranceViewController.h

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EntranceViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signInWithFacebookButton;

@property bool DID_JUST_LOGOUT;


@end

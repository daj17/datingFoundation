//
//  EntranceViewController.m

#import "EntranceViewController.h"
#import "ColorSuperclass.h"
#import <Parse/Parse.h>
#import "AgeCalcSuperclass.h"
#import "ParseFacebookUtilsV4.h"
#import "CachedPwdSuperclass.h"
#import "DeafultSettinsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "appDelegate.h"
#import "ParseFacebookUtilsV4.h"

@interface EntranceViewController ()

@property (nonatomic, strong) FBSDKLoginButton * facebookLoginButton;

@property (nonatomic, strong) UIView * loadingView;

@property (strong, nonatomic) IBOutlet UIImageView *launchView; //for the automatic login


@end

@implementation EntranceViewController

bool attemptingCachedSignIn=NO;

#warning testing below this point.

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //For now, we're not going to use these.
    self.loginButton.hidden=YES;
    //    self.signInWithFacebookButton.hidden=YES;
    
    
    [self.signInWithFacebookButton setBackgroundColor:[ColorSuperclass returnSignInWithFacebookButtonColor]];
    [self.view setBackgroundColor:[ColorSuperclass returnEntranceBackgroundColor]];
    
    // Set up target for Facebook login button
    [self.signInWithFacebookButton addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    self.signInWithFacebookButton.alpha=0.0;
    [UIView animateWithDuration:.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{self.signInWithFacebookButton.alpha=1;}
                     completion:nil];
    // Do any additional setup after loading the view.
    
    NSInteger facebookLoginButtonHeight=85;
    
    NSInteger tinyDisplacement=3; //avoid a little corner radius problem.
    CGRect facebookButtonFrame=CGRectMake(-tinyDisplacement, self.view.frame.size.height-facebookLoginButtonHeight+tinyDisplacement, self.view.frame.size.width+tinyDisplacement*2, facebookLoginButtonHeight);
    self.facebookLoginButton=[[FBSDKLoginButton alloc] initWithFrame:facebookButtonFrame];
    
    [self.facebookLoginButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:25.0f]];
    self.facebookLoginButton.layer.cornerRadius=0.1f;
    //    [self.view addSubview:self.facebookLoginButton];
    [self.facebookLoginButton addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if (![self returnIsThereInternet]) {
        //do nothing, return this method
        return;
    } else{
        if (!self.DID_JUST_LOGOUT)   {
            [self setUpLaunchImage];
            [self checkAndEnterCachedInfo];
        }
        [self checkForServerUpdate];
    }
}

-(void)showServerUpdated    { //also stored separately in the tab bar controller
    UIImageView * serVerUpdateImageview=[[[NSBundle mainBundle] loadNibNamed:@"ForceUpdate" owner:self options:nil] objectAtIndex:0];
    serVerUpdateImageview.frame=self.view.frame;
    [self.view addSubview:serVerUpdateImageview];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.view bringSubviewToFront:serVerUpdateImageview];
}

-(BOOL)returnIsThereInternet    {
    [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate returnInternetConnectionAvailable];
}

-(void)checkForServerUpdate { //forced update implementation.
    PFQuery * query=[PFQuery queryWithClassName:@"firstUpdateObject"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count]>0)  {
                PFObject * serverObject=[objects objectAtIndex:0];
                if ([serverObject[@"updateReady"] isEqualToString:@"YES"])    {
                    [self showServerUpdated];
                }
                else{
                    
                }
            } else{
                
            }
        } else{
            NSLog(@"Error: %@",error);
            ;
        }
    }];
}

-(void)setUpLaunchImage { //for automatic login
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    self.launchView=[[[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil] objectAtIndex:0];
    self.launchView.frame=self.view.frame;
    [self.view addSubview:self.launchView];
    [self.view bringSubviewToFront:self.launchView];
}

//This didn't quite work as intended...whatever...
-(void)viewDidAppear:(BOOL)animated    {
    // Check for cached cloud object.
#warning todo write cached cloud objects
    
    //Also check to see if we just authenticated
    if (ATTEMPT_USER_AUTH_WITH_FACEBOOK && ![PFUser currentUser])   {
        [self fadeAndThenRemoveLoadingViewSinceCanceled];
    }
}

-(void)removeLaunchIcon {
    [self.launchView removeFromSuperview];
    self.launchView=nil;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

////Caching of user login
-(void)checkAndEnterCachedInfo  {
    const float DISPATCH_TIME_FLOAT=.1; //HACKEY
    
    dispatch_after(dispatch_time(DISPATCH_TIME_FLOAT, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dispatchCache];
    });
}

-(void)dispatchCache    {
    
    // Caching is done in the cloud b/c Core Data is just such a pain to work with.
    
    PFQuery * cacheObjectQuery=[PFQuery queryWithClassName:@"cachedLoginObject"];
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    NSString * myUUID=[oNSUUID UUIDString];
    [cacheObjectQuery whereKey:@"deviceUUID" equalTo:myUUID];
    [cacheObjectQuery orderByDescending:@"createdAt"];
    
    [cacheObjectQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count]==0)   {
                [self removeLaunchIcon];
            } else {
                // Log em' in!
                PFObject * cachedLoginInfo=[objects objectAtIndex:0];
                NSString * username=cachedLoginInfo[@"username"];
                // For security purposes to start we don't store pwd in open text form in the cloud.
                NSString * password=[CachedPwdSuperclass returnUniversalPassword]; // used to be cachedLoginInfo[@"password"];
                [self attemptLoginWithUsername:username andPassword:password];
                NSLog(@"Found a cached login object, logging in...");
            }
        } else {
            NSLog(@"error: %@",error);
            [self removeLaunchIcon];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

bool attemptingAutomaticSignIn=NO;
- (IBAction)attemptLoginWithUsername:(NSString *)username andPassword:(NSString *)password { //called when next button pressed.
    
    if (!attemptingAutomaticSignIn)  {
        
        attemptingAutomaticSignIn=YES;
        
        
        
        [PFUser logInWithUsernameInBackground:username password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                // Do stuff after successful login.
                                                
                                                attemptingAutomaticSignIn=NO;
                                                
                                                dispatch_after(.3, dispatch_get_main_queue(), ^(void){
                                                    [self removeLaunchIcon];
                                                });

                                                
                                                
                                                
                                                [self setUserInCurrentInstallation];
                                                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                                [self performSegueWithIdentifier:@"segueToMainController" sender:self];
                                                
                                            } else {
                                                [self removeLaunchIcon];
                                                
                                                // The automatic login failed. Check error to see why.
                                                attemptingAutomaticSignIn=NO;
                                                
                                                NSLog(@"Error: %@",error);
                                            }
                                        }];
    }
}

-(void)setUserInCurrentInstallation {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //we're good
        } else   {
            NSLog(@"error: %@",error);
        }
    }];
    
}

///////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////


-(BOOL)prefersStatusBarHidden{
    return YES;
}

BOOL ATTEMPT_USER_AUTH_WITH_FACEBOOK=NO;
////////////////////////////////////////////// FACEBOOK LOGIN /////////////////////////////////////////////////////
- (void)loginWithFacebook //Facebook login used to increase authenticity of profiles.
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile"]; // We need their age, gender, and access to all of their profile pictures. //@"user_photos",
    
    ATTEMPT_USER_AUTH_WITH_FACEBOOK=YES;
    // Login PFUser using Facebook
    [self showLoggingInOrSigningUpView];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            //Perhaps show them a message saying that they canceled it.
            NSLog(@"error: %@",error.description);
            [self fadeAndThenRemoveLoadingViewGenerally];
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            [self fetchUserProfilePictureAndInfo];
            ATTEMPT_USER_AUTH_WITH_FACEBOOK=NO;
        } else {
            NSLog(@"User logged in through Facebook!");
            [self setUserInCurrentInstallation];
            [self fadeAndThenRemoveLoadingViewAtLogin];
            ATTEMPT_USER_AUTH_WITH_FACEBOOK=NO;
        }
    }];
}

//This is only called when they first sign up.
-(void)fetchUserProfilePictureAndInfo  {
    if ([FBSDKAccessToken currentAccessToken]) {
        
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,picture.width(400).height(400)"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"result: %@",result);
                 NSString *fbIdString = [result valueForKey:@"id"];
                 NSString *birthday=nil;
                 //                 if ([result valueForKey:@"birthday"])  {
                 //                     birthday = [result valueForKey:@"birthday"];
                 //                 }
                 NSString *firstName;
                 
                 if (![result valueForKey:@"first_name"])   {
                     firstName=@""; //account has no first name
                 } else{
                     firstName = [result valueForKey:@"first_name"];
                 }
                 
                 NSURL *url;
                 UIImage * image;
                 if (![result valueForKey:@"picture"])  { //account has no photo
                     image=[UIImage imageNamed:@"noPhoto.jpg"];
                 } else{
                     NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                     url = [[NSURL alloc] initWithString:imageStringOfLoginUser];
                 }
                 
                 PFFile * pictureFile;
                 
                 if (![result valueForKey:@"picture"])  {
                     pictureFile=[PFFile fileWithData:UIImagePNGRepresentation(image)];
                 } else{
                     pictureFile=[PFFile fileWithData:[NSData dataWithContentsOfURL:url]];
                 }
                 
                 
                 // Save the file, then save the current user.
                 [pictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if(!error)
                     {
                         NSLog(@"Uploaded profile image succesfully, about to save user...");
                         
                         // Set up the basic structures of a user's attributes
                         //                         PFUser * user=[PFUser currentUser];
                         //                         //You're not allowed to set username (it'll refuse to modify PFUser in the next controller if you do). Not exatly sure why it does this on a deeper level but it does...
                         [PFUser currentUser][@"picture"]=pictureFile;
                         //                         if (birthday) [PFUser currentUser][@"birthdayString"]=birthday;
                         [PFUser currentUser][@"fbIDString"]=fbIdString;
                         
                         [PFUser currentUser][@"blocked"]=[[NSMutableArray alloc] init]; // who I've blocked
                         [PFUser currentUser][@"muted"]=[[NSMutableArray alloc] init]; // who I've muted notifications from
                         [PFUser currentUser][@"reported"]=[[NSMutableArray alloc] init]; // who I've reported
                         
                         [PFUser currentUser][@"playing"]=@"YES";
                         [PFUser currentUser][@"interests"]=[[NSMutableArray alloc] init];
                         [PFUser currentUser][@"first_name"]=firstName;
                         [PFUser currentUser][@"searchRadius"]=[NSNumber numberWithInteger:25]; //default, watch out, this is hard coded
                         [PFUser currentUser][@"genderInterests"]=[[NSMutableArray alloc] init];
                         
                         [self setUserInCurrentInstallation];
                         
                         
                         [self fadeAndThenRemoveLoadingViewAtSigup];
                         
                     }
                     else {
                         NSLog(@"error: %@",error);
                         [self fadeAndThenRemoveLoadingViewGenerally];
                     }
                 }];
                 
             } else{
                 NSLog(@"error: %@",error);
             }
         }];
    }
}

//while it's loading
-(void)showLoggingInOrSigningUpView    {
    
    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGFloat width=100.0f;
        
        UIView * loadingView=[[UIView alloc] initWithFrame:self.view.frame];
        [loadingView setBackgroundColor:[UIColor whiteColor]];
        UIImageView * imageView=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2- width/2, 200,  width,  width)];
        imageView.image=[UIImage imageNamed:@"compass_background"];
        UIImageView * secondImageView=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2- width/2, 200,  width,  width)];
        secondImageView.image=[UIImage imageNamed:@"compass_spinner"];
        [loadingView addSubview:imageView];
        [loadingView addSubview:secondImageView];
        self.loadingView=loadingView;
        [loadingView setBackgroundColor:[ColorSuperclass returnFirstLoadingViewColor]];
        [self.view addSubview:loadingView];
        
        //        [UIView animateWithDuration:1.0
        //                              delay:0.0
        //                            options:0
        //                         animations:^{
        //                             [UIView setAnimationRepeatCount:HUGE_VALF];
        //                             [UIView setAnimationBeginsFromCurrentState:YES];
        //                             self.loadingView.transform = CGAffineTransformMakeRotation(M_PI);
        //                         }
        //                         completion:^(BOOL finished){
        //                             NSLog(@"Done!");
        //                         }];
    });
    
    
}

-(void)fadeAndThenRemoveLoadingViewAtLogin {
    
    //Disappear
    [UIView animateWithDuration:.5 animations:^(void) {
        [self.loadingView setBackgroundColor:[ColorSuperclass returnSecondLoadingViewColor]];
    }
                     completion:^(BOOL finished){
                         //Disappear
                         [UIView animateWithDuration:.5 animations:^(void) {
                             //                             self.loadingView.alpha = 0;
                             [self.loadingView setBackgroundColor:[ColorSuperclass returnThirdLoadingViewColor]];
                         }
                                          completion:^(BOOL finished){
                                              
                                              [self performSegueWithIdentifier:@"segueToMainController" sender:self];
                                              
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                  [self.loadingView removeFromSuperview];
                                              });
                                              
                                          }];
                         
                         
                         
                     }];
    
}

-(void)fadeAndThenRemoveLoadingViewSinceCanceled {
    
    [self.loadingView removeFromSuperview];
    
}

-(void)fadeAndThenRemoveLoadingViewAtSigup {
    
    //Disappear
    [UIView animateWithDuration:.5 animations:^(void) {
        [self.loadingView setBackgroundColor:[ColorSuperclass returnSecondLoadingViewColor]];
    }
                     completion:^(BOOL finished){
                         //Disappear
                         [UIView animateWithDuration:.5 animations:^(void) {
                             //                             self.loadingView.alpha = 0;
                             [self.loadingView setBackgroundColor:[ColorSuperclass returnThirdLoadingViewColor]];
                             
                         }
                                          completion:^(BOOL finished){
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                  [self.loadingView removeFromSuperview];
                                              });
                                              [self performSegueWithIdentifier:@"signUpSegue" sender:self];
                                              
                                          }];
                         
                         
                         
                     }];
    
}

-(void)fadeAndThenRemoveLoadingViewGenerally {
    
    //Disappear
    [UIView animateWithDuration:.5 animations:^(void) {
        [self.loadingView setBackgroundColor:[ColorSuperclass returnSecondLoadingViewColor]];
    }
                     completion:^(BOOL finished){
                         //Disappear
                         [UIView animateWithDuration:.5 animations:^(void) {
                             self.loadingView.alpha = 0;
                             [self.loadingView setBackgroundColor:[ColorSuperclass returnThirdLoadingViewColor]];
                         }
                                          completion:^(BOOL finished){
                                              
                                              [self.loadingView removeFromSuperview];
                                              
                                              
                                          }];
                         
                         
                         
                     }];
    
}



////////////////////////////////////// END FACEBOOK LOGIN /////////////////////////////////////////////////////////

@end

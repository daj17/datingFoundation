//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DemoMessagesViewController.h"
#import "PushesSuperclass.h"
#import "AppDelegate.h"
#import <OneSignal/OneSignal.h>
#import "ColorSuperclass.h"
#import "SIAlertView.h"


@interface DemoMessagesViewController ()

//for viewing profile image:
@property (nonatomic, strong) UIView * blurView;
@property (nonatomic, strong) UIImage * secondPersonImage; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImage * thirdPersonImage; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImageView * productImageView; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImageView * thirdPhotoImageView; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImageView * secondPhotoImageView; //when user taps on image to see closeup of it.

@property (nonatomic, strong) UITextView * selfProductImageTextView; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UITextView * selfBioTextView; //when user taps on image to see closeup of it.

@property (nonatomic, strong) NSTimer * animationPicsTimer;


@property (nonatomic, strong) UITextView * quipView;
@property (nonatomic, strong) UIImageView * theirMainPhotoImageView;

@property (nonatomic, strong) NSTimer * refreshTimer;

@end

@implementation DemoMessagesViewController



#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    if (self.SHOULD_SHOW_THEIR_PHOTO_SINCE_NO_MESSAGES) {
        [self setUpQuipBecauseNoMessages];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMyCollectionViewData) name:@"refreshMessagesSinceReceivedMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMyCollectionViewData) name:@"removeQuipsBecauseMessages" object:nil];
    
    self.title = self.user[@"first_name"];
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    
    /**
     *  Load up our fake data for the demo
     */
    self.demoData = [[DemoModelData alloc] init];
    self.demoData.userImage=self.userImage;
    self.demoData.user=self.user;
    [self.demoData doBasicSetup];
    
    
    [self.demoData refreshTheMessages];
    
    self.collectionView.accessoryDelegate = self;
    
    
    /**
     *  You can set custom avatar sizes
     */
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }
    
    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(37, 37);
    
    self.showLoadEarlierMessagesHeader = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(showBLockReportOrMuteOptions)];
    
    /**
     *  Register custom menu actions for cells.
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    
    
    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    /**
     *  Set a maximum height for the input toolbar
     *
     *  self.inputToolbar.maximumHeight = 150;
     */
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)setUpQuipBecauseNoMessages    {
    
    CGFloat imageWidth=310.0f; //we'll put it smack dab in the center.
    CGFloat imageHeight=310.0f;
    
    CGFloat verticalDisplacement=30.0f;
    
    UIImageView * imageView=[[UIImageView alloc] init];
    CGRect imageViewFrame=CGRectMake(self.middleCoordHack-imageWidth/2, self.view.frame.size.height/2-imageHeight/2-verticalDisplacement, imageWidth, imageHeight);
    [imageView setFrame:imageViewFrame];
    imageView.image=self.userImage;
    
    imageView.layer.cornerRadius=imageView.frame.size.width/2;
    [imageView.layer setMasksToBounds:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productImageTapped:)];
    [imageView addGestureRecognizer:tap];
    
    
    CGFloat textFieldWidth=200.0f;
    CGFloat textFieldHeight=200.0f;
    CGFloat textFieldVerticalDisplacement=13.0f;
    
    UITextView * quipField=[[UITextView alloc] init];
    CGRect textFrame=CGRectMake(self.middleCoordHack-textFieldWidth/2, self.view.frame.size.height/2-imageHeight/2+imageHeight+textFieldVerticalDisplacement-verticalDisplacement, textFieldWidth, textFieldHeight);
    [quipField setFrame:textFrame];
    [quipField setTextColor:[UIColor lightGrayColor]];
    self.quipView=quipField;
    [quipField setText:self.quip];
    [imageView setUserInteractionEnabled:YES];
    quipField.textAlignment=NSTextAlignmentCenter;
    self.theirMainPhotoImageView=imageView;
    quipField.userInteractionEnabled=NO;
    
    [quipField setFont:[UIFont fontWithName:@"Helvetica" size:19.0f]];
    
    
    [self.view addSubview:imageView];
    [self.view addSubview:quipField];
    
    
    //    imageView.alpha=0.0f;
    //    quipField.alpha=0.0f;
    //
    //    [UIView animateWithDuration:0.6f animations:^(void) {
    //        imageView.alpha=1.0f;
    //        quipField.alpha=1.0f;
    //    }completion:^(BOOL finished){
    //
    //
    //    }];
    
}

-(void)productImageTapped:(UIGestureRecognizer *)tap {
    
    
    
    
    [self placeScreenShotOverMainViewWithInfo:self.mainUserInfoString];
}

-(void)placeScreenShotOverMainViewWithInfo:(NSString *)mainUserInfo  {
    self.inputToolbar.hidden=YES;
    [self.blurView removeFromSuperview];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        self.theirMainPhotoImageView.alpha=0.0f;
        
        self.navigationController.navigationBar.hidden=YES;
        self.view.backgroundColor = [UIColor whiteColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //Disable tableview scrolling
        
        //        TabbarController * tabBarrController=(TabbarController *)self.navigationController.parentViewController;
        [self.view addSubview:blurEffectView];
        blurEffectView.tag = 773920;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBlurredEffectOverTabbar)];
        [blurEffectView addGestureRecognizer:tap];
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeBlurredEffectOverTabbar)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [blurEffectView addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(removeBlurredEffectOverTabbar)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [blurEffectView addGestureRecognizer:swipeRight];
        
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]  initWithTarget:self action:@selector(removeBlurredEffectOverTabbar)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        [blurEffectView addGestureRecognizer:swipeUp];
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeBlurredEffectOverTabbar)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        [blurEffectView addGestureRecognizer:swipeDown];
        self.blurView=blurEffectView;
        
        CGFloat VERT_DISPLACE_FROM_CENTER=25.0f;
        
        CGFloat width=self.view.frame.size.width*.97;
        CGFloat height=width;
        
        CGRect imageViewframe=CGRectMake(self.view.frame.size.width/2-width/2, self.view.frame.size.height/2-width/2-VERT_DISPLACE_FROM_CENTER, width, height);
        UIImage * image=self.userImage;
        UIImageView * imageView=[[UIImageView alloc] initWithFrame:imageViewframe];
        
        imageView.layer.cornerRadius=imageView.frame.size.width/2;
        imageView.layer.masksToBounds=YES;
        
        UITextView * textView=[[UITextView alloc] init];
        textView.text=mainUserInfo;
        textView.textAlignment=NSTextAlignmentCenter;
        [textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f]];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTextColor:[UIColor grayColor]];
        textView.userInteractionEnabled=NO;
        
        CGFloat textViewHeight=100.0f;
        CGFloat textViewWidth=self.view.frame.size.width*.94;
        
        CGFloat textViewDisplacement=94.0f;
        CGRect textViewframe=CGRectMake(self.view.frame.size.width/2-textViewWidth/2, self.view.frame.size.height/2-textViewWidth/2-textViewDisplacement, textViewWidth, textViewHeight);
        [textView setFrame:textViewframe];
        self.selfProductImageTextView=textView;
        self.productImageView=imageView;
        //        [self.productImageView.layer setBorderColor:[ColorSuperclass returnProfilePicBorderColor].CGColor];
        //        [self.productImageView.layer setBorderWidth:2.0f];
        imageView.image=image;
        [blurEffectView addSubview:imageView];
        [blurEffectView addSubview:textView];
        
        //Make the bio text view
        CGFloat bioTextViewWidth=self.view.frame.size.width*.84;
        CGFloat bioTextViewHeight=120.0f;
        CGFloat yCoordinateBioTextView=self.view.frame.size.height-bioTextViewHeight-35; // Give it a little extra space from the bottom...
        
        UITextView * bioTextView=[[UITextView alloc] init];
        
        CGRect textViewRect=CGRectMake(self.view.frame.size.width/2-bioTextViewWidth/2, yCoordinateBioTextView, bioTextViewWidth, bioTextViewHeight);
        [bioTextView setFrame:textViewRect];
        [blurEffectView addSubview:bioTextView];
        if (self.user[@"bio"])   {
            [bioTextView setText:self.user[@"bio"]];
        }
        bioTextView.textAlignment=NSTextAlignmentCenter;
        [bioTextView setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
        [bioTextView setTextColor:[UIColor lightGrayColor]];
        bioTextView.scrollEnabled=NO;
        [bioTextView setBackgroundColor:[UIColor clearColor]];
        bioTextView.userInteractionEnabled=NO;
        self.selfBioTextView=bioTextView;
        
        [self possiblyFetchMoreUserPhotosForUser:self.user];
        
    }
    else {
        
        self.view.backgroundColor = [UIColor blackColor];
    }
}

///////////////////
// Called via gesture recognizers
-(void)leftMostPhotoTapped  {
    UIImage * currentThirdImage=self.thirdPhotoImageView.image;
    self.thirdPhotoImageView.image=self.productImageView.image;
    //move the left one to the middle, and rotate the others forward...
    self.productImageView.image=self.secondPhotoImageView.image;
    self.secondPhotoImageView.image=currentThirdImage;
}
-(void)rightMostPhotoTapped  {
    UIImage * currentSecondImage=self.secondPhotoImageView.image;
    self.secondPhotoImageView.image=self.productImageView.image;
    self.productImageView.image=self.thirdPhotoImageView.image;
    self.thirdPhotoImageView.image=currentSecondImage;
}


-(void)possiblyFetchMoreUserPhotosForUser:(PFUser *)user  {
    
    BOOL HAS_A_SECOND_PHOTO=NO;
    BOOL HAS_A_THIRD_PHOTO=NO;
    
    if (user[@"secondPicture"]) HAS_A_SECOND_PHOTO=YES;
    if (user[@"thirdPicture"]) HAS_A_THIRD_PHOTO=YES;
    
    
    
    if (HAS_A_SECOND_PHOTO)   { // Has to have a second photo before they can make a third...
        // Let's fetch the second photo, then see if we need to fetch the third.
        PFFile * pictureFile=user[@"secondPicture"];
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            if (!error) {
                
                UIImage * image =[UIImage imageWithData:data];
                self.secondPersonImage=image;
                
                
                
                if (!HAS_A_THIRD_PHOTO)   {
                    [self createSecondProductImageOnBlurView];
                } else{
                    PFFile * pictureFile=user[@"thirdPicture"];
                    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        
                        if (!error) {
                            
                            UIImage * image =[UIImage imageWithData:data];
                            self.thirdPersonImage=image;
                            
                            [self createSecondProductImageOnBlurView];
                            [self createThirdProductImageOnBlurView];
                            
                        }
                        else{
                            NSLog(@"error: %@",error);
                        }
                    }];
                    
                }
                
            }
            else{
                NSLog(@"error: %@",error);
            }
        }];
        
    }
    
}

///////////////////
BOOL SHOWING_MAIN_USER_PIC=NO;
-(void)createSecondProductImageOnBlurView   {
    if (self.secondPersonImage)    {
        
        
        
        
        
        
        
        if (self.user[@"thirdPicture"])    {
            CGRect frame= CGRectMake(self.productImageView.frame.origin.x+self.productImageView.frame.size.width/2, self.productImageView.frame.origin.y, self.productImageView.frame.size.width, self.productImageView.frame.size.height);
            UIImageView * secondPhotoOfPersonImageView=[[UIImageView alloc] initWithFrame:frame];
            self.secondPhotoImageView=secondPhotoOfPersonImageView;
            secondPhotoOfPersonImageView.image=self.secondPersonImage;
            
            [self.blurView bringSubviewToFront:self.productImageView]; // Always want him in front... <-- DID YOU JUST ASSUME THE IMAGEVIEW's gender???? (TRIGGERED)
            
            secondPhotoOfPersonImageView.userInteractionEnabled=YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftMostPhotoTapped)];
            [secondPhotoOfPersonImageView addGestureRecognizer:tap];
            secondPhotoOfPersonImageView.alpha=.7;
            secondPhotoOfPersonImageView.layer.cornerRadius=secondPhotoOfPersonImageView.frame.size.width/2;
            
            [self.secondPhotoImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [self.secondPhotoImageView.layer setBorderWidth:1.0f];
            
            
            [secondPhotoOfPersonImageView.layer setMasksToBounds:YES];
            
            [self.blurView addSubview:secondPhotoOfPersonImageView];
            
            
        } else {
            
            SHOWING_MAIN_USER_PIC=YES;
            [self.animationPicsTimer invalidate];
            self.animationPicsTimer = [NSTimer scheduledTimerWithTimeInterval: 1.7 target: self
                                                                     selector: @selector(photoAnimationCalled) userInfo: nil repeats: YES];
        }
    }
}

-(void)createThirdProductImageOnBlurView   {
    if (self.thirdPersonImage)    {
        CGRect frame= CGRectMake(self.productImageView.frame.origin.x-self.productImageView.frame.size.width/2, self.productImageView.frame.origin.y, self.productImageView.frame.size.width, self.productImageView.frame.size.height);
        UIImageView * thirdPhotoOfPersonImageView=[[UIImageView alloc] initWithFrame:frame];
        [self.blurView addSubview:thirdPhotoOfPersonImageView];
        self.thirdPhotoImageView=thirdPhotoOfPersonImageView;
        thirdPhotoOfPersonImageView.image=self.thirdPersonImage;
        [self.blurView bringSubviewToFront:self.productImageView]; // Always want him in front... <-- DID YOU JUST ASSUME THE IMAGEVIEW's gender???? (TRIGGERED)
        thirdPhotoOfPersonImageView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightMostPhotoTapped)];
        [thirdPhotoOfPersonImageView addGestureRecognizer:tap];
        thirdPhotoOfPersonImageView.alpha=.7;
        [thirdPhotoOfPersonImageView.layer setMasksToBounds:YES];
        
        [self.thirdPhotoImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.thirdPhotoImageView.layer setBorderWidth:1.0f];
        
        thirdPhotoOfPersonImageView.layer.cornerRadius=thirdPhotoOfPersonImageView.frame.size.width/2;
    }
}

-(void)removeBlurredEffectOverTabbar    {
    [self.animationPicsTimer invalidate];
    //    self.tableView.scrollEnabled=YES;
    self.theirMainPhotoImageView.alpha=1.0f;
    self.inputToolbar.alpha=0.0f;
    self.inputToolbar.hidden=NO;
    
    [self.productImageView.layer removeAllAnimations]; //Avoid UI animation bug when it's animating while you swipe down

    
    [UIView animateWithDuration:1.0f animations:^(void) {
        self.inputToolbar.alpha=1.0f;
    }completion:^(BOOL finished){
        
        
    }];
    
    for (UIView *subview in [self.view subviews]) {
        if (subview.tag == 773920) {
            
            CGFloat displacement=100.0f;
            
            CGRect newTextViewFrame=CGRectMake(self.selfProductImageTextView.frame.origin.x, self.selfProductImageTextView.frame.origin.y+displacement, self.selfProductImageTextView.frame.size.width, self.selfProductImageTextView.frame.size.height);
            
            CGRect newImageFrame=CGRectMake(self.productImageView.frame.origin.x, self.productImageView.frame.origin.y+displacement, self.productImageView.frame.size.width, self.productImageView.frame.size.height);
            
            CGRect newBioTextFrame=CGRectMake(self.selfBioTextView.frame.origin.x, self.selfBioTextView.frame.origin.y+displacement, self.selfBioTextView.frame.size.width, self.selfBioTextView.frame.size.height);
            
            CGRect leftPhotoFrame=CGRectMake(self.secondPhotoImageView.frame.origin.x, self.secondPhotoImageView.frame.origin.y+displacement, self.secondPhotoImageView.frame.size.width, self.secondPhotoImageView.frame.size.height);
            CGRect rightPhotoFrame=CGRectMake(self.thirdPhotoImageView.frame.origin.x, self.thirdPhotoImageView.frame.origin.y+displacement, self.thirdPhotoImageView.frame.size.width, self.thirdPhotoImageView.frame.size.height);
            
            
            
            [UIView animateWithDuration:.30 animations:^(void) {
                
                
                [self.productImageView setFrame:newImageFrame];
                [self.selfBioTextView setFrame:newBioTextFrame];
                
                [self.secondPhotoImageView setFrame:leftPhotoFrame];
                [self.thirdPhotoImageView setFrame:rightPhotoFrame];
                
                
                [self.selfProductImageTextView setFrame:newTextViewFrame];
                
                self.selfProductImageTextView.alpha=0;
                self.productImageView.alpha=0;
                self.secondPhotoImageView.alpha=0;
                self.thirdPhotoImageView.alpha=0;
                self.selfBioTextView.alpha=0;
                
                
            }
                             completion:^(BOOL finished){
                                 //Appear
                                 
                                 self.navigationController.navigationBar.hidden=NO;
                                 
                                 
                                 [UIView animateWithDuration:.30 animations:^(void) {
                                     subview.alpha = 0;
                                     
                                     
                                     
                                 }
                                                  completion:^(BOOL finished){
                                                      //Appear
                                                      
                                                      [subview removeFromSuperview];
                                                      
                                                  }];
                                 
                                 
                             }];
        }
    }
}

NSInteger ANIMATIONS_COUNTER=0; //little hack
-(void)photoAnimationCalled  {
    
    if (!SHOWING_MAIN_USER_PIC)   {
        SHOWING_MAIN_USER_PIC=YES;
        UIImage * personProfImage=self.userImage;
        
        
        [UIView transitionWithView:self.productImageView
                          duration:.7f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            
                            
                            self.productImageView.image=personProfImage;
                        } completion:nil];
        
        
    } else{
        SHOWING_MAIN_USER_PIC=NO;
        [UIView transitionWithView:self.productImageView
                          duration:.7f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            self.productImageView.image=self.secondPersonImage;
                        } completion:nil];
        
    }
    
}






-(void)inititateFrequentReload  { //on view did appear
    //create the global timer that reloads
}

-(void)deInititateFrequentReload  { //on view did dissapear
    //de alloc init the timer
}

BOOL SAVING_NEW_MESSAGE=NO;
-(void)saveMessageISentWithText:(NSString *)messageText {
    if (SAVING_NEW_MESSAGE) return;
    SAVING_NEW_MESSAGE=YES;
    
    PFObject * message=[PFObject objectWithClassName:@"Message"];
    message[@"dateMade"]=[NSDate date]; // This is when I wrote it
    message[@"whoSent"]=[PFUser currentUser].username; // I sent it
    message[@"whoSentTo"]=self.user.username; // To this person
    message[@"read"]=@"NO"; // If the sender has read it.
    message[@"deleted"]=@"NO"; // Not sure, may add option to delete messages later.
    message[@"type"]=@"text"; //in case we want to classify message types later on (gifs, media, etc.)
    message[@"text"]=messageText;
    NSMutableArray * whoInvolved=[[NSMutableArray alloc] init];
    [whoInvolved addObject:[PFUser currentUser].username];
    [whoInvolved addObject:self.user.username];
    message[@"whoInvolved"]=whoInvolved;
    
    // Save the message, and upon completion of save, send a push to the user you just sent the message to.
    
    [message saveInBackgroundWithBlock:^(BOOL success,NSError * error)   {
        if (!error) {
            SAVING_NEW_MESSAGE=NO;
            NSLog(@"no error saving new message");
            
            // Now send the push, and update the UI
            
            [self.inputToolbar.contentView.textView resignFirstResponder];
            self.inputToolbar.contentView.textView.text=@"";
            [self.inputToolbar toggleSendButtonEnabled];
            
            //////////   SEND THE PUSH  //////////////
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            OneSignal * oneSig=[appDelegate returnOneSignalInstance];

            if (self.user[@"oneSignalIDs"])  {
                if (![self.user[@"muted"] containsObject:[PFUser currentUser].username])   { // If they've blocked notifications from me
                    [PushesSuperclass sendMessagePushToPlayerIds:self.user[@"oneSignalIDs"] withOneSignalObject:oneSig];
                    
                   
                }
            }
            
            //////// ADD TO MESSAGES
            [self.demoData addMessageUsingPFObject:message];
            
        } else{
            SAVING_NEW_MESSAGE=NO;
            NSLog(@"error: %@",error);
        }
    }];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
    
    NSTimer * refreshTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                              target: self
                              
                                                            selector:@selector(timerHit)
                                                            userInfo: nil repeats:YES];
    self.refreshTimer=refreshTimer;
    
    
    //    [self.navigationController.navigationBar setBarTintColor:[ColorSuperclass returnNavBarTintInLive]];
    //    [self.navigationController.navigationBar setTranslucent:NO];
    

    
}

-(void)timerHit   {
    NSLog(@"refreshing since timer hit");
    [self.demoData refreshTheMessages];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshTimer invalidate];
    self.refreshTimer=nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
}



#pragma mark - Custom menu actions for cells

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    [super didReceiveMenuWillShowNotification:notification];
    
    /**
     *  Display custom menu actions for cells.
     */
    UIMenuController *menu = [notification object];
    menu.menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action" action:@selector(customAction:)] ];
}



#pragma mark - Testing

- (void)pushMainViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:nc.topViewController animated:YES];
}


#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    /**
     *  DEMO ONLY
     *
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdJobs
                                          displayName:kJSQDemoAvatarDisplayNameJobs
                                                 text:@"First received!"];
    }
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        if (copyMessage.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            id<JSQMessageMediaData> copyMediaData = copyMessage.media;
            
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [locationItemCopy.location copy];
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = NO;
                
                newMediaData = videoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                JSQAudioMediaItem *audioItemCopy = [((JSQAudioMediaItem *)copyMediaData) copy];
                audioItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [audioItemCopy.audioData copy];
                
                /**
                 *  Reset audio item to simulate "downloading" the audio
                 */
                audioItemCopy.audioData = nil;
                
                newMediaData = audioItemCopy;
            }
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                   media:newMediaData];
        }
        else {
            /**
             *  Last message was a text message
             */
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                    text:copyMessage.text];
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        // [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        
        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                    ((JSQAudioMediaItem *)newMediaData).audioData = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
            });
        }
        
    });
}

///////////////////////////////////////////////

-(void)showBLockReportOrMuteOptions   {
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    alertView.SHOULD_MOVE_ALERT_VIEW_DOWN=NO;
    
    if ([[PFUser currentUser][@"muted"] containsObject:self.user.username]) {
        [alertView addButtonWithTitle:@"Unmute Notifications"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  
                                  [self muteThisUsersNotifications];
                              }];
    } else{
        [alertView addButtonWithTitle:@"Mute Notifications"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  
                                  [self muteThisUsersNotifications];
                                  
                              }];
    }
    
    [alertView addButtonWithTitle:@"Block"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self blockThisUser];
                              
                              
                              
                          }];
    
    [alertView addButtonWithTitle:@"Block And Report"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self blockAndReportThisUser];
                          }];
    
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                          }];
    
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
    
    
}

-(void)muteThisUsersNotifications    {
    NSMutableArray * mutedArr=[PFUser currentUser][@"muted"];
    if ([mutedArr containsObject:self.user.username])   {
        //unmute them
        [mutedArr removeObject:self.user.username];
        [PFUser currentUser][@"muted"]=mutedArr;
        
        [[PFUser currentUser] saveInBackground];
        [self showUserUnMuted];
    } else{
        //mute them
        [mutedArr addObject:self.user.username];
        [PFUser currentUser][@"muted"]=mutedArr;
        [[PFUser currentUser] saveInBackground];
        [self showUserMuted];
    }
    
}

-(void)showUserMuted    {
    
    NSMutableString * notifString=[[NSMutableString alloc] initWithString:@""];
    [notifString appendString:@"Notifications from "];
    [notifString appendString:self.user[@"first_name"]];
    [notifString appendString:@" have been muted. You can change this at any time."];
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:notifString];
    alertView.SHOULD_MOVE_ALERT_VIEW_DOWN=NO;
    
    
    
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
                              
                              
                          }];
    
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

-(void)showUserUnMuted    {
    
    NSMutableString * notifString=[[NSMutableString alloc] initWithString:@""];
    [notifString appendString:@"Notifications from "];
    [notifString appendString:self.user[@"first_name"]];
    [notifString appendString:@" have been enabled."];
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:notifString];
    alertView.SHOULD_MOVE_ALERT_VIEW_DOWN=NO;
    
    
    
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
                              
                              
                          }];
    
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}


-(void)blockThisUser    {
    NSMutableArray * mutedArr=[PFUser currentUser][@"blocked"];
    if ([mutedArr containsObject:self.user.username])   {
        //unmute them
        [mutedArr removeObject:self.user.username];
        [PFUser currentUser][@"blocked"]=mutedArr;
        
        [[PFUser currentUser] saveInBackground];
    } else{
        //mute them
        [mutedArr addObject:self.user.username];
        [PFUser currentUser][@"blocked"]=mutedArr;
        [[PFUser currentUser] saveInBackground];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)blockAndReportThisUser    {
    NSMutableArray * mutedArr=[PFUser currentUser][@"reported"];
    [mutedArr addObject:self.user.username];
    [PFUser currentUser][@"reported"]=mutedArr;
    
    //in the block method the user will get saved...
    [self blockThisUser];
    
    
    
}

///////////////////////////////////////////////


//added by djax, this is called after the refresh.
-(void)reloadMyCollectionViewData   {
    
    if (self.quipView)     { //if these were showing, remove them...
        [self.quipView removeFromSuperview];
        self.quipView=nil;
    }
    
    if (self.theirMainPhotoImageView)     {
        [self.theirMainPhotoImageView removeFromSuperview];
        self.theirMainPhotoImageView=nil;
    }
    
    [self.collectionView reloadData];
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    
    
    
    [self saveMessageISentWithText:text]; //added by djax
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Send photo", nil), NSLocalizedString(@"Send location", nil), NSLocalizedString(@"Send video", nil), NSLocalizedString(@"Send audio", nil), nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self.demoData addPhotoMediaMessage];
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
        }
            break;
            
        case 2:
            [self.demoData addVideoMediaMessage];
            break;
            
        case 3:
            [self.demoData addAudioMediaMessage];
            break;
    }
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}



#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return kJSQDemoAvatarIdSquires;
}

- (NSString *)senderDisplayName {
    return kJSQDemoAvatarDisplayNameSquires;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }
    
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

-(void)removeQuipBecauseMessages    {
    //remove both from the superview
    [self.quipView removeFromSuperview];
    [self.theirMainPhotoImageView removeFromSuperview];
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * messages=self.demoData.messages;
    JSQMessage * message=[messages objectAtIndex:indexPath.row];
    
    //potentially make this more robust later on lol...
    if ([message.senderDisplayName isEqualToString:@""]) {
        NSLog(@"Tapped their avatar!");
        [self.inputToolbar.contentView.textView resignFirstResponder];
        self.inputToolbar.alpha=0;
        [self placeScreenShotOverMainViewWithInfo:self.mainUserInfoString];
    }
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.demoData.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

@end

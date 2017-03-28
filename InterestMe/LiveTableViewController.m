//
// LiveTableViewController.m
// Made by djax

#import "LiveTableViewController.h"
#import "LiveCell.h"
#import "AreOfflineCell.h"
#import "AppDelegate.h"
#import "CachedPwdSuperclass.h"
#import "ColorSuperclass.h"
#import "buttonSuperclass.h"
#import "AgeCalcSuperclass.h"
#import "SIAlertView.h"
#import "NoPeoplePlayingCell.h"
#import "FormatUserInfoForCardStackController.h"
#import "AmLiveCell.h"
#import "AppDelegate.h"
#import "DemoMessagesViewController.h"

#import "InterestMe-Swift.h" //ADVSegmentedControl

@interface LiveTableViewController ()

//Global data structures for users and profile pitures.
@property (nonatomic, strong) NSMutableArray * usersArray; //Users themselves.
@property (nonatomic, strong) NSMutableDictionary * usersImagesDict; //Profile pictures of users.
@property (nonatomic, strong) NSMutableArray * commonInterestsArray;
@property (nonatomic, strong) NSMutableArray * mainUsersInfoArray;
@property (nonatomic, strong) NSMutableArray * quipsArray;

//custom seg control:
@property (nonatomic, strong) ADVSegmentedControl * customSegmentedControl;

//for viewing profile image:
@property (nonatomic, strong) UIView * blurView;
@property (nonatomic, strong) UIImage * selectedImage; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImage * secondPersonImage; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImage * thirdPersonImage; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImageView * productImageView; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImageView * thirdPhotoImageView; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UIImageView * secondPhotoImageView; //when user taps on image to see closeup of it.

@property (nonatomic, strong) UITextView * selfProductImageTextView; //when user taps on image to see closeup of it.
@property (nonatomic, strong) UITextView * selfBioTextView; //when user taps on image to see closeup of it.
@property (nonatomic, strong) PFUser * selectedProduct; //when user taps on image to see closeup of it.

@property (nonatomic, strong) PFUser * userToChatWith; //when user taps on cell to chat
@property (nonatomic, strong) NSString * selectedQuip; ///from the cell they tap
@property (nonatomic, strong) NSString * mainUsersInfoStringSelected;

@property (nonatomic, strong) NSMutableDictionary * usersLastCommentsDict;



//For going to the user's profile
@property (nonatomic) UIBarButtonItem *settingsButton;

@property (nonatomic, strong) NSTimer * animationPicsTimer;

@property (nonatomic, strong) UIImage * profileImage;

//REFRESHING
@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;


@end

@implementation LiveTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupRefreshControl];
    
    //    [self.navigationItem.backBarButtonItem setTitle:@" "];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{UITextAttributeFont: [UIFont fontWithName:@"Helvetica" size:21.0f]}];
    
    
    //    self.navigationController.navigationItem.left
    [self.navigationItem setHidesBackButton:YES];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self registerNibs];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 52.0; // this number doesn't matter as long as all cell heights are determined, but apple requires it for some reason...
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOurTableview) name:@"playingStatusChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOurTableview) name:@"refreshLiveNearbySinceReceivedMessage" object:nil];
    
    [self setUpLogoutButton];
    
    [self assignCurrentUserPassword];
    
    [self possiblyUpdateMyAge];
    
    //For push notifications... //This may be a little redundant but that's ok to send it every time they log in...This early on I don't think it really matters...
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    OneSignal * oneSignal=[appDelegate returnOneSignalInstance];
    [oneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
        
        NSLog(@"UserId:%@", userId);
        
        if (userId) {
            
            //Using an array so we can send pushes to multiple devices...
            if (![PFUser currentUser][@"oneSignalIDs"]) {
                NSMutableArray * IDSArray=[[NSMutableArray alloc] init];
                [IDSArray addObject:userId];
                [PFUser currentUser][@"oneSignalIDs"]=IDSArray;
                [[PFUser currentUser] saveInBackground];
                [appDelegate sendTagForUsername:[PFUser currentUser].username]; //Send a tag up to OneSignal, this purely for administrative purposes.
            } else{
                if (![[PFUser currentUser][@"oneSignalIDs"] containsObject:userId]) {
                    [[PFUser currentUser][@"oneSignalIDs"] addObject:userId];
                    [[PFUser currentUser] saveInBackground];
                    [appDelegate sendTagForUsername:[PFUser currentUser].username]; //Send a tag up to OneSignal, this purely for administrative purposes.
                }
            }
        }
        
        if (pushToken != nil)
            NSLog(@"pushToken:%@", pushToken);
    }];
}

-(void)possiblyUpdateMyAge  {
    NSInteger userAge= [AgeCalcSuperclass returnAgeUsingBirthDate:[PFUser currentUser][@"birthday"]];
    NSInteger savedAge=[[PFUser currentUser][@"age"] integerValue];
    if (userAge!=savedAge)  {
        [PFUser currentUser][@"age"]=[NSNumber numberWithInteger:userAge];
    }
}



//Reassigning current user's password to default. Bit of a security flaw, as well as a hack--but Parse login is pretty broken if you try to assign it to the current user--this is Facebook's fault.
-(void)assignCurrentUserPassword {
    if ([[PFUser currentUser][@"assignedPassword"] isEqualToString:@"YES"]) return; // Don't assign password unless they don't have it yet...
    
    [self createCachedLoginObjectForUsername:[PFUser currentUser].username andPassword:[CachedPwdSuperclass returnUniversalPassword]];
}

-(void)createCachedLoginObjectForUsername:(NSString *)username andPassword:(NSString *)password {
    PFObject * cachedLoginObject=[PFObject objectWithClassName:@"cachedLoginObject"];
    cachedLoginObject[@"username"]=username;
    cachedLoginObject[@"deviceUUID"]=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    cachedLoginObject[@"password"]=password;
    [cachedLoginObject saveInBackgroundWithBlock:^(BOOL success,NSError * error)   {
        if (!error) {
            NSLog(@"No error saving cached object! Now adding flag on user that we've saved a cached object already.");
            [PFUser currentUser][@"assignedPassword"]=@"YES";
            [[PFUser currentUser] saveInBackground];
        } else{
            NSLog(@"error: %@",error);
        }
    }];
}

-(void)possiblyUpdateSettingsImage  {
    if ([PFUser currentUser][@"bio"] && [PFUser currentUser][@"secondPicture"])  {
        CGFloat buttonBarHeight=[buttonSuperclass returnBarButtonDimension];
        UIImage * image = [UIImage imageNamed:@"goToProfileImage"];
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonBarHeight, buttonBarHeight)]; //these constants can always be subject to tweaking in the superclass...
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goToMyProfile) forControlEvents:UIControlEventTouchUpInside];
        self.settingsButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = self.settingsButton;
        ///////////End making bar button in top right.
        
    }
    
    
}

-(void)setUpLogoutButton    {
    
    
    
    CGFloat buttonBarHeight=[buttonSuperclass returnBarButtonDimension];
    
    //Making the logout button
    UIImage * image = [UIImage imageNamed:@"goToProfileImage"];
    
    if (![PFUser currentUser][@"bio"] ||  ![PFUser currentUser][@"secondPicture"])  {
        
        
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, rect, image.CGImage);
        CGContextSetFillColorWithColor(context, [[ColorSuperclass returnHasntMadeSecondPicOrMaybeBioSettingsColor] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        image = [UIImage imageWithCGImage:img.CGImage
                                    scale:1.0 orientation: UIImageOrientationDownMirrored];
        
        
    }
    
    
    
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonBarHeight, buttonBarHeight)]; //these constants can always be subject to tweaking in the superclass...
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToMyProfile) forControlEvents:UIControlEventTouchUpInside];
    self.settingsButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = self.settingsButton;
    ///////////End making bar button in top right.
}

-(void)goToMyProfile    {
    //    self.navigationItem.title=@"";
    [self performSegueWithIdentifier:@"showProfileSegue" sender:self];
}


-(void)showMessages    {
    
    
    [self performSegueWithIdentifier:@"showMessages" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated    {
    [super viewWillAppear:NO];
    [self fetchUsersNearby];
    [self possiblyUpdateSettingsImage];
    
    
    
    self.navigationItem.title=@"ChatsApp";
//    UIImage *image = [UIImage imageNamed:@"Lower_Res_ICON_Version.png"];
//    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
//    UIView *headerView = [[UIView alloc] init];
//    headerView.frame = CGRectMake(0, 0, 320, 44);
//    
//    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
//    imgView.frame = CGRectMake(75, 0, 150, 44);
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    
//    [headerView addSubview:imgView];
//    
//    self.navigationController.navigationBar.topItem.titleView = headerView;
    
    
    //    NSShadow *shadow = [[NSShadow alloc] init];
    //    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    //    shadow.shadowOffset = CGSizeMake(0, 1);
    //    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
    //                                                           [UIColor blackColor], NSForegroundColorAttributeName,
    //                                                           shadow, NSShadowAttributeName,
    //                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    //
    //    [self.navigationController.navigationBar setBarTintColor:[ColorSuperclass returnTabbarTextTintColor]];
    //    [self.navigationController.navigationBar setTranslucent:NO];
    
    
    self.navigationController.navigationBar.tintColor = [ColorSuperclass returnTabbarTextTintColor];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)   {
        self.userToChatWith=[self.usersArray objectAtIndex:indexPath.row];
        self.selectedQuip=[self.commonInterestsArray objectAtIndex:indexPath.row];
        self.mainUsersInfoStringSelected=[self.mainUsersInfoArray objectAtIndex:indexPath.row];
        [self showMessages];
    }
    
}

-(void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"AmLiveCell" bundle:nil] forCellReuseIdentifier:@"amLiveCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveCell" bundle:nil] forCellReuseIdentifier:@"LivePersonCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NoPeoplePlayingCell" bundle:nil] forCellReuseIdentifier:@"NoPeoplePlayingCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AreOfflineCell" bundle:nil] forCellReuseIdentifier:@"AreOfflineCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[PFUser currentUser][@"playing"] isEqualToString:@"NO"]) return 1; //they're offline
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section==0) return 1; //the Playing Control Cell
    
    //else just the number of people that the refresh pulls:
    if (section==1) {
        
        if (!self.usersArray) return 0; // Refreshing
        else if ([self.usersArray count]==0) { // Nobody nearby
            return 1;
        }
        return [self.usersArray count]; // Show the people
    }
    
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) return @"";
    //    if (section==1) return @"Also Playing Nearby";
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        AmLiveCell *amLiveCell = (AmLiveCell *)[tableView dequeueReusableCellWithIdentifier:@"amLiveCell" forIndexPath:indexPath];
        amLiveCell.selectionStyle = UITableViewCellSelectionStyleNone;
        amLiveCell.directionTextView.scrollEnabled=NO;
        [amLiveCell setBackgroundColor:[ColorSuperclass returnPlayingCustomSegmentColor]];
        
        return amLiveCell;
    } else if (indexPath.section==1)  {
        if ([[PFUser currentUser][@"playing"] isEqualToString:@"NO"])   {
            AreOfflineCell * areOfflineCell = (AreOfflineCell *)[tableView dequeueReusableCellWithIdentifier:@"AreOfflineCell" forIndexPath:indexPath];
            areOfflineCell.mainTextView.scrollEnabled=NO;
            
            return areOfflineCell;
        }
        else if ([self.usersArray count]==0) {
            NoPeoplePlayingCell * noPeopleNearbyCell = (NoPeoplePlayingCell *)[tableView dequeueReusableCellWithIdentifier:@"NoPeoplePlayingCell" forIndexPath:indexPath];
            noPeopleNearbyCell.noPeopleNearbyTextView.scrollEnabled=NO;
            noPeopleNearbyCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return noPeopleNearbyCell;
        } else{
            LiveCell *liveCell = (LiveCell *)[tableView dequeueReusableCellWithIdentifier:@"LivePersonCell" forIndexPath:indexPath];
            PFUser * user=[self.usersArray objectAtIndex:indexPath.row];
            UIImage * profileImage=[self.usersImagesDict objectForKey:user.username];
            liveCell.profileImageView.image=profileImage;
            liveCell.profileImageView.layer.cornerRadius=liveCell.profileImageView.frame.size.width/2;
            liveCell.nameLabel.text=[self.mainUsersInfoArray objectAtIndex:indexPath.row];
            liveCell.numMessagesLabel.hidden=YES;
            liveCell.interestsLabel.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
            
            //Managing showing the last message in the cells
            if ([self.usersLastCommentsDict objectForKey:user.username])  {
                PFObject * lastMessageObject=[self.usersLastCommentsDict objectForKey:user.username];
                NSString * textToShow=lastMessageObject[@"text"];
                liveCell.interestsLabel.text=textToShow;
                
                liveCell.interestsLabel.textContainer.maximumNumberOfLines = 2;
                [liveCell.interestsLabel.layoutManager textContainerChangedGeometry:liveCell.interestsLabel.textContainer];
                
                [  liveCell.interestsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f]];
                
                if ([lastMessageObject[@"whoSentTo"] isEqualToString:[PFUser currentUser].username])    {
                    
                    liveCell.profileImageView.layer.cornerRadius=liveCell.profileImageView.frame.size.width/2;
                    liveCell.profileImageView.layer.masksToBounds=YES;
                    
                    UIImage * alteredImageDisclosure=[self alterColorOfUIImage:liveCell.discolureImageView.image ToColor:[ColorSuperclass returnTheySentMessageDiscolure]]; //change it to the custom color
                    liveCell.discolureImageView.image=alteredImageDisclosure;
                    
                    [liveCell.interestsLabel setTextColor:[ColorSuperclass returnTheySentMessageDiscolure]];
                    
                } else{
                    
                    
                    [liveCell.profileImageView.layer setBorderWidth:0.0f];
                    [liveCell.profileImageView.layer setBorderColor:[UIColor clearColor].CGColor];
                    
                    
                    UIImage * alteredImageDisclosure=[self alterColorOfUIImage:liveCell.discolureImageView.image ToColor:[UIColor lightGrayColor]]; //change it to the custom color
                    liveCell.discolureImageView.image=alteredImageDisclosure;
                    
                    [liveCell.interestsLabel setTextColor:[UIColor lightGrayColor]];
                    
                    
                }
            }   else{
                [liveCell.profileImageView.layer setBorderWidth:0.0f];
                [liveCell.profileImageView.layer setBorderColor:[UIColor clearColor].CGColor];
                [  liveCell.interestsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:15.0f]];
                liveCell.interestsLabel.text=[self.commonInterestsArray objectAtIndex:indexPath.row];
                liveCell.interestsLabel.textContainer.maximumNumberOfLines = 100;
                [liveCell.interestsLabel.layoutManager textContainerChangedGeometry:liveCell.interestsLabel.textContainer];
                
                UIImage * alteredImageDisclosure=[self alterColorOfUIImage:liveCell.discolureImageView.image ToColor:[UIColor lightGrayColor]]; //change it to the custom color
                liveCell.discolureImageView.image=alteredImageDisclosure;
                
                [liveCell.interestsLabel setTextColor:[UIColor lightGrayColor]];
                
                
            }
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productImageTapped:)];
            [liveCell.profileImageView addGestureRecognizer:tap];
            liveCell.profileImageView.tag=indexPath.row;
            
            liveCell.profileImageView.userInteractionEnabled=YES;
            
            [liveCell.nameLabel setBackgroundColor:[UIColor whiteColor]];
            [liveCell.interestsLabel setBackgroundColor:[UIColor whiteColor]];
            [liveCell.distanceAwayLabel setBackgroundColor:[UIColor whiteColor]];
            
            PFGeoPoint * theirLocation=user[@"location"];
            NSString * locationString=[self returnCustomizedDeliveryTimeStringForLocation:theirLocation];
            
            liveCell.distanceAwayLabel.text=locationString;
            
            liveCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return liveCell;
        }
    }
    return nil;
}

-(UIImage *)alterColorOfUIImage:(UIImage *)image ToColor:(UIColor *)color
{
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
};





-(void)reloadOurTableview   {
    if ([[PFUser currentUser][@"playing"] isEqualToString:@"YES"])  {
        [self fetchUsersNearby];
    } else{
        [self.tableView reloadData];
    }
    
}

-(void)productImageTapped:(UIGestureRecognizer *)tap {
    NSInteger index=tap.view.tag;
    PFUser * user=[self.usersArray objectAtIndex:index];
    UIImage * image=[self.usersImagesDict objectForKey:user.username];
    self.selectedImage=image;
    self.selectedProduct=user;
    NSString * mainUserInfo=[self.mainUsersInfoArray objectAtIndex:index];
    [self placeScreenShotOverMainViewWithInfo:mainUserInfo];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)placeScreenShotOverMainViewWithInfo:(NSString *)mainUserInfo  {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        
        self.navigationController.navigationBar.hidden=YES;
        self.view.backgroundColor = [UIColor whiteColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //Disable tableview scrolling
        self.tableView.scrollEnabled=NO;
        
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
        UIImage * image=self.selectedImage;
        UIImageView * imageView=[[UIImageView alloc] initWithFrame:imageViewframe];
        
        imageView.layer.cornerRadius=imageView.frame.size.width/2;
        imageView.layer.masksToBounds=YES;
        
        UITextView * textView=[[UITextView alloc] init];
        textView.text=mainUserInfo;
        textView.textAlignment=NSTextAlignmentCenter;
        [textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:30.0f]];
        [textView setBackgroundColor:[UIColor clearColor]];
        //        [textView setTextColor:[ColorSuperclass returnProfilePicBorderColor]];
        [textView setTextColor:[UIColor grayColor]];
        
        textView.userInteractionEnabled=NO;
        
        CGFloat textViewHeight=100.0f;
        CGFloat textViewWidth=self.view.frame.size.width*.94;
        
        CGFloat textViewDisplacement=94.0f;
        CGRect textViewframe=CGRectMake(self.view.frame.size.width/2-textViewWidth/2, self.view.frame.size.height/2-textViewWidth/2-textViewDisplacement, textViewWidth, textViewHeight);
        [textView setFrame:textViewframe];
        self.selfProductImageTextView=textView;
        self.productImageView=imageView;
        [self.productImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        //        [self.productImageView.layer setBorderWidth:1.0f];
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
        if (self.selectedProduct[@"bio"])   {
            [bioTextView setText:self.selectedProduct[@"bio"]];
        }
        bioTextView.textAlignment=NSTextAlignmentCenter;
        [bioTextView setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
        [bioTextView setTextColor:[UIColor lightGrayColor]];
        bioTextView.scrollEnabled=NO;
        [bioTextView setBackgroundColor:[UIColor clearColor]];
        bioTextView.userInteractionEnabled=NO;
        self.selfBioTextView=bioTextView;
        
        [self possiblyFetchMoreUserPhotosForUser:self.selectedProduct];
        
    }
    else {
        
        self.view.backgroundColor = [UIColor blackColor];
    }
}

//CUSTOM REFRESHING
- (void)setupRefreshControl
{
    // TODO: Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Setup the color view, which will display the rainbowed background
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = 0.30;
    
    // Create the graphic image views
    self.compass_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass_background.png"]];
    self.compass_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass_spinner.png"]];
    
    // Add the graphics to the loading view
    [self.refreshLoadingView addSubview:self.compass_background];
    [self.refreshLoadingView addSubview:self.compass_spinner];
    
    // Clip so the graphics don't stick out
    self.refreshLoadingView.clipsToBounds = YES;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    [self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:self.refreshLoadingView];
    
    // Initalize flags
    self.isRefreshIconsOverlap = NO;
    self.isRefreshAnimating = NO;
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(fetchUsersNearby) forControlEvents:UIControlEventValueChanged];
}


-(void)possiblyFetchMoreUserPhotosForUser:(PFUser *)user  {
    
    BOOL HAS_SECOND_PHOTO=NO;
    BOOL HAS_THIRD_PHOTO=NO;
    
    if (user[@"secondPicture"]) HAS_SECOND_PHOTO=YES;
    if (user[@"thirdPicture"]) HAS_THIRD_PHOTO=YES;
    
    
    
    if (HAS_SECOND_PHOTO)   { // Has to have a second photo before they can make a third...
        // Let's fetch the second photo, then see if we need to fetch the third.
        PFFile * pictureFile=user[@"secondPicture"];
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            if (!error) {
                
                UIImage * image =[UIImage imageWithData:data];
                self.secondPersonImage=image;
                
                
                
                if (!HAS_THIRD_PHOTO)   {
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

- (void)animateRefreshView
{
    // Background color to loop through for our color view
    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    static int colorIndex = 0;
    
    // Flag that we are animating
    self.isRefreshAnimating = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.compass_spinner setTransform:CGAffineTransformRotate(self.compass_spinner.transform, M_PI_2)];
                         
                         // Change the background color
                         //                         UIColor * currentColor=[colorArray objectAtIndex:colorIndex];
                         
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         
                         //                         [self.myProfileImageView.layer setBorderColor:currentColor.CGColor];
                         
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         }else{
                             [self resetAnimation];
                         }
                     }];
}

- (void)resetAnimation
{
    
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    
    
    
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
///////////////////
BOOL SHOWING_MAIN_PIC=NO;
-(void)createSecondProductImageOnBlurView   {
    if (self.secondPersonImage)    {
        
        
        
        
        
        
        
        if (self.selectedProduct[@"thirdPicture"])    {
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
            
            
        } else { //They just have a second photo.
            CGRect frame= CGRectMake(self.productImageView.frame.origin.x, self.productImageView.frame.origin.y, self.productImageView.frame.size.width, self.productImageView.frame.size.height);
            UIImageView * secondPhotoOfPersonImageView=[[UIImageView alloc] initWithFrame:frame];
            [self.blurView addSubview:secondPhotoOfPersonImageView];
            secondPhotoOfPersonImageView.image=self.secondPersonImage;
            self.secondPhotoImageView=secondPhotoOfPersonImageView;
            [self.blurView bringSubviewToFront:self.productImageView]; // Always want him in front... <-- DID YOU JUST ASSUME THE IMAGEVIEW's gender???? (TRIGGERED)
            
            secondPhotoOfPersonImageView.userInteractionEnabled=YES;
            //            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftMostPhotoTapped)];
            //            [secondPhotoOfPersonImageView addGestureRecognizer:tap];
            secondPhotoOfPersonImageView.alpha=.7;
            secondPhotoOfPersonImageView.layer.cornerRadius=secondPhotoOfPersonImageView.frame.size.width/2;
            [secondPhotoOfPersonImageView.layer setMasksToBounds:YES];
            [self.secondPhotoImageView.layer removeAllAnimations];
            [self.productImageView.layer removeAllAnimations];
            
            [self.animationPicsTimer invalidate];
            self.animationPicsTimer = [NSTimer scheduledTimerWithTimeInterval: 1.7 target: self
                                                                     selector: @selector(photoAnimationCalled) userInfo: nil repeats: YES];
            
            
            SHOWING_MAIN_PIC=YES;
            
            
            
            
            //            [self.secondPhotoImageView.layer setBorderColor:[ColorSuperclass returnProfilePicBorderColor].CGColor];
            //            [self.secondPhotoImageView.layer setBorderWidth:2.0f];
            
            
        }
        
        
        
        
    }
}

NSInteger ANIMATION_COUNTER=0; //little hack
-(void)photoAnimationCalled  {
    
    if (!SHOWING_MAIN_PIC)   {
        SHOWING_MAIN_PIC=YES;
        UIImage * personProfImage=[self.usersImagesDict objectForKey:self.selectedProduct.username];
        
        
        [UIView transitionWithView:self.productImageView
                          duration:.7f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            
                            
                            self.productImageView.image=personProfImage;
                        } completion:nil];
        
        
    } else{
        SHOWING_MAIN_PIC=NO;
        [UIView transitionWithView:self.productImageView
                          duration:.7f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            
                            self.productImageView.image=self.secondPersonImage;
                        } completion:nil];
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    // Get the current size of the refresh controller
    CGRect refreshBounds = self.refreshControl.bounds;
    
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    // Half the width of the table
    CGFloat midX = self.tableView.frame.size.width / 2.0;
    
    // Calculate the width and height of our graphics
    CGFloat compassHeight = self.compass_background.bounds.size.height;
    CGFloat compassHeightHalf = compassHeight / 2.0;
    
    CGFloat compassWidth = self.compass_background.bounds.size.width;
    CGFloat compassWidthHalf = compassWidth / 2.0;
    
    CGFloat spinnerHeight = self.compass_spinner.bounds.size.height;
    CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
    
    CGFloat spinnerWidth = self.compass_spinner.bounds.size.width;
    CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
    
    // Calculate the pull ratio, between 0.0-1.0
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    
    // Set the Y coord of the graphics, based on pull distance
    CGFloat compassY = pullDistance / 2.0 - compassHeightHalf;
    CGFloat spinnerY = pullDistance / 2.0 - spinnerHeightHalf;
    
    // Calculate the X coord of the graphics, adjust based on pull ratio
    CGFloat compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
    CGFloat spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
    
    // When the compass and spinner overlap, keep them together
    if (fabsf(compassX - spinnerX) < 1.0) {
        self.isRefreshIconsOverlap = YES;
    }
    
    // If the graphics have overlapped or we are refreshing, keep them together
    if (self.isRefreshIconsOverlap || self.refreshControl.isRefreshing) {
        compassX = midX - compassWidthHalf;
        spinnerX = midX - spinnerWidthHalf;
    }
    
    // Set the graphic's frames
    CGRect compassFrame = self.compass_background.frame;
    compassFrame.origin.x = compassX;
    compassFrame.origin.y = compassY;
    
    CGRect spinnerFrame = self.compass_spinner.frame;
    spinnerFrame.origin.x = spinnerX;
    spinnerFrame.origin.y = spinnerY;
    
    self.compass_background.frame = compassFrame;
    self.compass_spinner.frame = spinnerFrame;
    
    // Set the encompassing view's frames
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    
    // If we're refreshing and the animation is not playing, then play the animation
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }
    
    //    DLog(@"pullDistance: %.1f, pullRatio: %.1f, midX: %.1f, isRefreshing: %i", pullDistance, pullRatio, midX, self.refreshControl.isRefreshing);
}


//-(void)animateTwoImages { //constantly switches images of person
//    //Disappear
//
//    CGFloat DELAY=2.8;
//    CGFloat ANIMATION_DURATION=1;
//
//
//
//
//
//    [UIView animateWithDuration:ANIMATION_DURATION animations:^(void) {
//        self.productImageView.alpha = 0;
//        self.secondPhotoImageView.alpha = 1;
//    }
//                     completion:^(BOOL finished){
//                         //Appear
//
//
//                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                             [UIView animateWithDuration:ANIMATION_DURATION animations:^(void) {
//                                 self.productImageView.alpha = 1;
//                                 self.secondPhotoImageView.alpha = 0;
//                             }completion:^(BOOL finished){
//                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                                     [self animateTwoImages];                             });
//
//                             }];
//
//                         });
//
//                     }];
//}

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
    self.tableView.scrollEnabled=YES;
    [self.animationPicsTimer invalidate];
    [self.productImageView.layer removeAllAnimations]; //Avoid UI animation bug when it's animating while you swipe down
    
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



///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//use the current location of the user to estimate a delivery time.
-(NSString *)returnCustomizedDeliveryTimeStringForLocation:(PFGeoPoint *)theirLocation   {
    
    CGFloat  distance=[[PFUser currentUser][@"location"] distanceInMilesTo:theirLocation];
    
    CGFloat numMiles=distance;
    
    NSInteger numMilesIntValue=(NSInteger)numMiles;
    
    if (numMilesIntValue==0) numMilesIntValue=1; //they should be able to tell if they're that close, too much of a privacy invasion.
    
    NSMutableString * farAwayString=[[NSMutableString alloc] initWithString:@""];
    NSString * distanceString=[NSString stringWithFormat: @"%ld", (long)numMilesIntValue];
    
    [farAwayString appendString:distanceString];
    
    if (numMilesIntValue==1)    {
        [farAwayString appendString:@" mile away"];
    } else{
        [farAwayString appendString:@" miles away"];
    }
    
    return farAwayString;
    
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMessages"]) {
        DemoMessagesViewController * vc=(DemoMessagesViewController *)segue.destinationViewController;
        vc.user=self.userToChatWith;
        vc.userImage=[self.usersImagesDict objectForKey:self.userToChatWith.username];
        vc.quip=self.selectedQuip;
        vc.mainUserInfoString=self.mainUsersInfoStringSelected;
        vc.middleCoordHack=self.view.frame.size.width/2;
        if ([self.usersLastCommentsDict objectForKey:self.userToChatWith.username])  {
            vc.SHOULD_SHOW_THEIR_PHOTO_SINCE_NO_MESSAGES=NO;
        } else{
            vc.SHOULD_SHOW_THEIR_PHOTO_SINCE_NO_MESSAGES=YES;
            
        }
    }
}

///////////////////////////////////       API:

-(BOOL)returnInternetAvailable  {
    [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate returnInternetConnectionAvailable];
}

BOOL REFRESHING_PEOPLE=NO;
-(void)fetchUsersNearby {
    
    if (![self returnInternetAvailable])  { // Can't refresh with no internet.
        REFRESHING_PEOPLE=NO;
        [self showNoInternetAvailable];
        [self.refreshControl endRefreshing];
        return;
    }
    
    if (!REFRESHING_PEOPLE) {
        REFRESHING_PEOPLE=YES;
        
        AppDelegate * appDelegate = ( AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        NSInteger status=[CLLocationManager authorizationStatus];
        if (status==kCLAuthorizationStatusAuthorizedWhenInUse) {
            //we can has their location while they use the app, just let the thread continue...
        } else{
            if (status==kCLAuthorizationStatusDenied || status==kCLAuthorizationStatusRestricted)   {
                [self showPleaseAllowCurrentLocationToSeeNearbyPeople];
                [self.refreshControl endRefreshing];
                ;
                REFRESHING_PEOPLE=NO;
                //                [self.refreshControl endRefreshing];
                return;
            }
            else if (status==kCLAuthorizationStatusNotDetermined)   {
                //request acesss.
                [self.refreshControl endRefreshing];
                [[appDelegate returnLocationManager] requestWhenInUseAuthorization];
                REFRESHING_PEOPLE=NO;
                return;
                
                //If the user says "Don't Allow" when they sign up, but then we show them the alert view and they allow, there will be one refresh where the user won't get thier location, simply since there is no completion method on the requestWhenINUseAuthorization. We'll let this slide by, as it seems a sort of rarish edgecase, and I (djax) don't see a good solution, but I'll keep thinking about it.
            }
        }
    }
    
#warning We'll need to place some UI over to show that we're fetching!
    
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) { //Parse is so much more reliable in terms of location. Although we have to fetch the value. In a perfect world we might check for the "0 lat error", an Apple bug most likely (talk to djax if you want to understand this), and use apple's implemenation when there isn't an error. But there's really no reason, our Api isn't under strain (yet haha).
        if (!error) {
            
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
            [[PFUser currentUser] saveInBackground]; //So other people can find me
            
            //No problems w/ internet or access to current user's location, let's continue...
            
            PFQuery *query = [PFUser query]; //Query for users
            
            // Location restrictions based on distance
            NSInteger searchRadius=[[PFUser currentUser][@"searchRadius"] integerValue];
            [query whereKey:@"location" nearGeoPoint:[PFUser currentUser][@"location"] withinMiles:searchRadius];
            
            //            [query whereKey:@"username" notContainedIn:[PFUser currentUser][@"blocked"]];
            //            //so they shouldn't be reported, but not blocked. But whatever, maybe if only one save went through
            //            [query whereKey:@"username" notContainedIn:[PFUser currentUser][@"reported"]];
            
            //Now we'll add some more constraints to our query...
            
            [query whereKey:@"gender" containedIn:[PFUser currentUser][@"genderInterests"]]; //only show users of gender that I'm interested in...
            
            [query whereKey:@"finishedSetup" equalTo:@"YES"]; // Only show me users who have finished creating their accounts.
            
            //
            [query whereKey:@"playing" equalTo:@"YES"]; // Only members who are playing right now
            //
            //            // Limit users based on my age prefs
            //
            [query whereKey:@"age" greaterThanOrEqualTo:[PFUser currentUser][@"lowerAgeLimit"]];
            [query whereKey:@"age" lessThanOrEqualTo:[PFUser currentUser][@"upperAgeLimit"]];
            
            //You could write a cloud function to do this, but really whether the code exists in the cloud or in XCode it does the same thing...
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                if (!error) {
                    
                    // Now pass this array in to the next method, checking first to make sure we found at least 1 person.
                    
                    //But also check make sure they're interested in my gender too...
                    
                    NSMutableArray * usersWithOkayGenderInterests=[[NSMutableArray alloc] init];
                    
                    for (PFUser * user in users)    {
                        
                        if ([user[@"fbIDString"] isEqualToString:[PFUser currentUser][@"fbIDString"]]) continue; // Don't show me myself
                        
                        //these actually shouldn't hit (they're built into the query above...)
                        if ([[PFUser currentUser][@"blocked"] containsObject:user.username]) continue;
                        if ([[PFUser currentUser][@"reported"] containsObject:user.username]) continue;
                        
                        
                        
                        NSMutableArray * gendersTheyAreInterestedIn=user[@"genderInterests"];
                        NSLog(@"interests of theirs genderwise: %@",gendersTheyAreInterestedIn);
                        if ([gendersTheyAreInterestedIn containsObject:[PFUser currentUser][@"gender"]])    {
                            
                            // Now we will also check their distance range, and their age to make sure I'm acceptable to them (so  one of us doesn't see the other but the other person does!)
                            
                            CGFloat  distance=[[PFUser currentUser][@"location"] distanceInMilesTo:user[@"location"]];
                            
                            CGFloat numMiles=distance;
                            
                            NSInteger numMilesIntValue=(NSInteger)numMiles;
                            
                            if (numMilesIntValue==0) numMilesIntValue=1; //they should be able to tell if they're that close, too much of a privacy
                            
                            if (!([user[@"searchRadius"] integerValue]<numMilesIntValue))  {
                                //we checked the location, now let's check the age range...
                                NSInteger myAge= [AgeCalcSuperclass returnAgeUsingBirthDate:[PFUser currentUser][@"birthday"]];
                                
                                NSNumber * theirLowerAgeLimit=user[@"lowerAgeLimit"];
                                NSNumber * theirUpperAgeLimit=user[@"upperAgeLimit"];
                                
                                if (myAge<=[theirUpperAgeLimit integerValue] && myAge>=[theirLowerAgeLimit integerValue])   {
                                    
                                    //Now let's check if they've blocked me
                                    
                                    if (![user[@"blocked"] containsObject:[PFUser currentUser].username])   {
                                        if (![user[@"reported"] containsObject:[PFUser currentUser].username])   {
                                            [usersWithOkayGenderInterests addObject:user];
                                        }
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                            
                        }
                    }
                    
                    if ([usersWithOkayGenderInterests count]==0)   {
                        
                        NSLog(@"No other singles on ChatsApp right at the moment!");
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .03* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            REFRESHING_PEOPLE=NO;
                            self.usersArray=[[NSMutableArray alloc] init];
                            [self.tableView reloadData];
                            [self.refreshControl endRefreshing];
                        });
                        
                        
                        
                        
                    } else{
                        
                        NSMutableDictionary * lastCommentDictionary=[[NSMutableDictionary alloc] init];
                        
                        NSMutableArray * tagArray=[[NSMutableArray alloc] init];
                        
                        for (PFUser * user in usersWithOkayGenderInterests) {
                            PFQuery *query = [PFQuery queryWithClassName:@"Message"];
                            [query whereKey:@"whoInvolved" containsString:[PFUser currentUser].username];
                            [query whereKey:@"whoInvolved" containsString:user.username]; //TODO test constraint stacking
                            [query setLimit:1];
                            [query orderByDescending:@"dateMade"];
                            [query findObjectsInBackgroundWithBlock:^(NSArray *firstMessages, NSError *error) {
                                if (!error) {
                                    [tagArray addObject:@"tag"];
                                    if ([firstMessages count]==1)   {
                                        [lastCommentDictionary setObject:[firstMessages objectAtIndex:0] forKey:user.username];
                                    }
                                    
                                    if ([tagArray count]==[usersWithOkayGenderInterests count]) {
                                        self.usersLastCommentsDict=lastCommentDictionary;
                                        [self fetchProfileImagesForUsers:usersWithOkayGenderInterests];
                                    }
                                    
                                } else{
                                    NSLog(@"Error: %@",error);
                                }
                                
                            }];
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                    }
                } else {
                    [self.refreshControl endRefreshing];                    [self handleFetchError:error];
                }
            }];
            
            
        } else{
            [self.refreshControl endRefreshing];            NSLog(@"Location Fetching Error: %@",error.description);
        }
    }];
    
}



-(void)showNoInternetAvailable  {
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"No Network Connection";
    NSString * message=@"Please connect your device to view nearby people.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
                          }];
    
    //    [alertView addButtonWithTitle:@"No thanks" // Not sure if I should even give them this option
    //                             type:SIAlertViewButtonTypeCancel
    //                          handler:^(SIAlertView *alert) {
    //                              NSLog(@"User canceled logout");
    //                          }];
    
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

// Now that we have the users we're interested in, we need to pull the profile images for these users. We'll pass in the users we just fetched, and then we'll pull the main profile image for each of these users. Then we'll be able to display the "card-stack", or however we may decide to display this information.
//////////////////////    IMAGE FETCHING FOR USERS WITH COMMON INTEREST(S)       //////////////////////
-(void)fetchProfileImagesForUsers:(NSArray *)usersArray     {
    
    NSMutableDictionary * imageDictTemp=[[NSMutableDictionary alloc] init];
    NSMutableArray * tagArray=[[NSMutableArray alloc] init]; //A tag array, so we know when we've got all the images.
    
    NSMutableArray * commonInterestsArray=[[NSMutableArray alloc] init];
    NSMutableArray * mainUserInfoArray=[[NSMutableArray alloc] init];
    NSMutableArray * photosArray=[[NSMutableArray alloc] initWithCapacity:[usersArray count]];
    
    for (PFUser * user in usersArray) {
        
        // Since we're already iterating through all the users, we might as well create the commonIntersts Array we'll also use on the cardstack
        
        //This is a formatted string that says something like: "Common Interests (num): item1, item2, etc... "
        NSString * commonInterestsString=[FormatUserInfoForCardStackController returnCommonInterestStringInfoBetweenMe:[PFUser currentUser] andUser:user];
        [commonInterestsArray addObject:commonInterestsString];
        
        NSString * mainLabelString=[FormatUserInfoForCardStackController returnMainInfoForUser:user];
        [mainUserInfoArray addObject:mainLabelString];
        
        NSString * username=user.username;
        PFFile * pictureFile=user[@"picture"];
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            if (!error) {
                
                UIImage * image =[UIImage imageWithData:data];
                [imageDictTemp setObject:image forKey:username];
                [tagArray addObject:@"tag"];
                
                NSInteger indexNum=[usersArray indexOfObject:user];
                [photosArray setObject:image atIndexedSubscript:indexNum];
                
                if ([tagArray count]==[usersArray count])    { //we got all the images.
                    
                    // This line hits when the tag 'fires' aka we have all the photos.
                    
                    //switch the pointers over.
                    self.usersImagesDict=imageDictTemp;
                    self.usersArray=[NSMutableArray arrayWithArray:usersArray];
                    
                    // The formatted stuff
                    self.commonInterestsArray=commonInterestsArray;
                    self.mainUsersInfoArray=mainUserInfoArray;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.refreshControl endRefreshing];
                    });
                    
                    REFRESHING_PEOPLE=NO;
                    [self.tableView reloadData]; // Update the UI
                    
                }
                
            }
            else{
                [self handleFetchError:error];
            }
        }];
    }
    
}

-(void)handleFetchError:(NSError *)error   { // When there is a fetch error due to timeout, there's not much we can do. Just reset the variables (get 'em ready for another refresh, and then possibly call to refresh again).
    REFRESHING_PEOPLE=NO;
    NSLog(@"Error: %@",error);
    
    //possibly also do some UI cleanup if you use UI to signify that the app is refreshing.
}

-(void)showPleaseAllowCurrentLocationToSeeNearbyPeople    {
    
    NSString * titleString=@"Enable Location Services";
    NSString * message=@"Please allow access to your location to see nearby people. You can enable this feature in your device's Settings.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Go To Settings"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                          }];
    
    //    [alertView addButtonWithTitle:@"No thanks" // Not sure if I should even give them this option
    //                             type:SIAlertViewButtonTypeCancel
    //                          handler:^(SIAlertView *alert) {
    //                              NSLog(@"User canceled logout");
    //                          }];
    
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


@end

//
//  ChooseInterestsOnSignupTableViewController.m

#import "ChooseInterestsOnSignupTableViewController.h"
#import "CategoryCell.h"
#import "returnCategoriesSuperclass.h"
#import "ColorSuperclass.h"
#import "SIAlertView.h"
#import <Parse/Parse.h>

@interface ChooseInterestsOnSignupTableViewController ()

// Global Data Structures
@property (nonatomic, strong) NSDictionary * categoriesDict;
@property (nonatomic, strong) NSArray * sortedDictKeys;
@property (nonatomic, strong) NSMutableSet * interestsSet;

// REFRESHING (FORKED, SUPER COOL!)
@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;
// END REFRESHING

@end

@implementation ChooseInterestsOnSignupTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    [self informUserAboutThisPage];
    
    [self setupRefreshControl];
    
    self.tableView.estimatedRowHeight = 204.0; // An estimate of how tall each cell is. Overridden in the first case because the profile cell has a designated height already
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.interestsSet=[[NSMutableSet alloc] init];
    
    self.navigationItem.title=@"My Interests";
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{UITextAttributeFont: [UIFont fontWithName:@"Helvetica" size:25.0f]}];
    
    //Now let's register the nib(s) and do some setup
    [self registerNibs];
    [self setUpDict];
    [self sortMainDict];
    
    // Set up the user's interests
    NSArray * interestsArray=[PFUser currentUser][@"interests"];
    self.interestsSet = [[NSMutableSet alloc] init];
    self.interestsSet=[NSMutableSet setWithArray:interestsArray];
    [self.tableView reloadData];
    NSLog(@"my interests: %@",interestsArray);
    
    
    
}

-(void)viewWillAppear:(BOOL)animated    {
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:28]];
    self.navigationItem.hidesBackButton = YES;
    
    // Set up next button
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(attemptGoToNextController)];
    self.navigationItem.rightBarButtonItem=nextButton;
    
    [nextButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont fontWithName:@"Chalkduster" size:25], NSFontAttributeName,
                                     [ColorSuperclass returnNextButtonTextTintColor], NSForegroundColorAttributeName,
                                     nil]
                           forState:UIControlStateNormal];

}

-(void)attemptGoToNextController    {
    //first we need to check if user has enough interests
    
    
    NSInteger numInterests=[[PFUser currentUser][@"interests"] count];
    if (numInterests<5){
        [self showPleaseChooseMinNumInterests];
    } else{
        //save the user.... then transfer
        [self performSegueWithIdentifier:@"segueToAskForLocation" sender:self];
    }
}

-(void)showPleaseChooseMinNumInterests  {
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"Hang on!";
    NSString * message=@"Please choose at least five interests to get started!";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
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

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)informUserAboutThisPage   {
    
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"Great 👍";
    NSString * message=@"If you'd like, choose some interests from the list below! This will help us match you with similar people.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Got it!"
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

-(void)setUpDict    {
    self.categoriesDict=[returnCategoriesSuperclass returnCategoriesDict];
}

-(void)sortMainDict {
    self.sortedDictKeys = [[self.categoriesDict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
}

-(void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"CategoryCell" bundle:nil] forCellReuseIdentifier:@"CategoryCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.categoriesDict) return 0;
    return [[self.categoriesDict allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray * bigArray=[self.categoriesDict objectForKey:[self.sortedDictKeys objectAtIndex:section]];
    return [bigArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[ColorSuperclass returnInterestTableViewHeaderColor]];
    return [self.sortedDictKeys objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CategoryCell *categoryCell = (CategoryCell *)[tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    NSString * interestName=[[self.categoriesDict objectForKey:[self.sortedDictKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    categoryCell.nameLabel.text=interestName;
    [categoryCell.nameLabel setBackgroundColor:[UIColor whiteColor]];
    categoryCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Decide whether imageview is selected
    if ([self.interestsSet containsObject:interestName]) {
        categoryCell.selectionImageView.image=[UIImage imageNamed:@"chosenSendImage"];
    } else{
        categoryCell.selectionImageView.image=[UIImage imageNamed:@"notChosenSendImage"];
    }
    
    UIImage *newImage = [categoryCell.selectionImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(categoryCell.selectionImageView.image.size, NO, newImage.scale);
    [[ColorSuperclass returnInterestSelectionTableViewColor] set];
    [newImage drawInRect:CGRectMake(0, 0, categoryCell.selectionImageView.image.size.width, newImage.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    categoryCell.selectionImageView.image = newImage;
    
    return categoryCell;
}

//Add it to the set
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * interestName=[[self.categoriesDict objectForKey:[self.sortedDictKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    if (![self.interestsSet containsObject:interestName])   {
        [self.interestsSet addObject:interestName];
    } else{
        [self.interestsSet removeObject:interestName];
    }
    NSArray * interestsArray=[self.interestsSet allObjects];
    [PFUser currentUser][@"interests"]=interestsArray;
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success,NSError * error)   {
        if (!error) {
            NSLog(@"no error saving new interst:");
        } else{
            NSLog(@"error: %@",error);
        }
    }];
    
    
    [self.tableView reloadData];
    
}

// Change the color on the selected images.
- (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance {
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    //float a = components[3]; // not needed
    
    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;
    
    const float redRange[2] = {
        MAX(r - (tolerance / 2.0), 0.0),
        MIN(r + (tolerance / 2.0), 255.0)
    };
    
    const float greenRange[2] = {
        MAX(g - (tolerance / 2.0), 0.0),
        MIN(g + (tolerance / 2.0), 255.0)
    };
    
    const float blueRange[2] = {
        MAX(b - (tolerance / 2.0), 0.0),
        MIN(b + (tolerance / 2.0), 255.0)
    };
    
    int byteIndex = 0;
    
    while (byteIndex < bitmapByteCount) {
        unsigned char red   = rawData[byteIndex];
        unsigned char green = rawData[byteIndex + 1];
        unsigned char blue  = rawData[byteIndex + 2];
        
        if (((red >= redRange[0]) && (red <= redRange[1])) &&
            ((green >= greenRange[0]) && (green <= greenRange[1])) &&
            ((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
            // make the pixel transparent
            //
            rawData[byteIndex] = 0;
            rawData[byteIndex + 1] = 0;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 0;
        }
        
        byteIndex += 4;
    }
    
    UIImage *result = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    
    CGContextRelease(context);
    free(rawData);
    
    return result;
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
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender{
    //    DLog(@"");
    
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        DLog(@"DONE");
        
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [self.refreshControl endRefreshing];
    });
    // -- FINISHED SOMETHING AWESOME, WOO! --
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
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
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
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
}

@end

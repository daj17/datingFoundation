//
//  CardViewController.m

#import "CardsViewController.h"
#import <Parse/Parse.h>
#import "DraggableViewBackground.h"
#import "SIAlertView.h"
#import "AppDelegate.h"
#import "AgeCalcSuperclass.h"
#import "FormatUserInfoForCardStackController.h"

@interface CardsViewController ()

//Global data structures for users and profile pitures.
@property (nonatomic, strong) NSMutableArray * usersArray; //Users themselves.
@property (nonatomic, strong) NSMutableDictionary * usersImagesDict; //Profile pictures of users.
@property (nonatomic, strong) DraggableViewBackground * draggableBackgroundView;

@end

@implementation CardsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title=@"People Nearby";
    
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
    
    //add target to overlay button
    [draggableBackground.menuButton addTarget:self action:@selector(showProfile) forControlEvents:UIControlEventTouchUpInside];
    self.draggableBackgroundView=draggableBackground;
}

-(void)viewWillAppear:(BOOL)animated    {
    [super viewWillAppear:NO];
    self.navigationController.navigationBar.hidden=YES;
    [self fetchUsersNearby];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////// API CALLS /////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

//OVERVIEW: pull the users, then pull the images. That gives enough info to build the "Card Stack." See the README under the Card Stack Section of the project for specifics on the sorting algorithm.

-(BOOL)returnInternetAvailable  {
    [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate returnInternetConnectionAvailable];
}

-(void)showProfile  {
    [self performSegueWithIdentifier:@"FastSegue" sender:self];
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

BOOL REFRESHING_CARDS=NO;
-(void)fetchUsersNearby {
    
    if (![self returnInternetAvailable])  { // Can't refresh with no internet.
        REFRESHING_CARDS=NO;
        [self showNoInternetAvailable];
        return;
    }
    
    if (!REFRESHING_CARDS) {
        REFRESHING_CARDS=YES;
        
        AppDelegate * appDelegate = ( AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        NSInteger status=[CLLocationManager authorizationStatus];
        if (status==kCLAuthorizationStatusAuthorizedWhenInUse) {
            //we can has their location while they use the app, just let the thread continue...
        } else{
            if (status==kCLAuthorizationStatusDenied || status==kCLAuthorizationStatusRestricted)   {
                [self showPleaseAllowCurrentLocationToSeeNearbyPeople];
                REFRESHING_CARDS=NO;
                //                [self.refreshControl endRefreshing];
                return;
            }
            else if (status==kCLAuthorizationStatusNotDetermined)   {
                //request acesss.
                [[appDelegate returnLocationManager] requestWhenInUseAuthorization];
                REFRESHING_CARDS=NO;
                return;
                
                //If the user says "Don't Allow" when they sign up, but then we show them the alert view and they allow, there will be one refresh where the user won't get thier location, simply since there is no completion method on the requestWhenINUseAuthorization. We'll let this slide by, as it seems a sort of rarish edgecase, and I (djax) don't see a good solution, but I'll keep thinking about it.
            }
        }
    }
    
    if ([self.usersArray count]>0)  { // Only fetch more when we need to
        REFRESHING_CARDS=NO;
        return;
    }
    
#warning We'll need to place some UI over to show that we're fetching!
    

    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) { // Parse is so much more reliable in terms of location. Although we have to fetch the value. In a perfect world we might check for the "0 lat error", an Apple bug most likely (talk to djax if you want to understand this), and use apple's implemenation when there isn't an error. But there's really no reason, our Api isn't under strain (yet haha).
        if (!error) {
            
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            // Round to hundredths accuracy to prevent user location triangulation. Plan to use geohashing later on.
            CGFloat roundedLat= roundf( geoPoint.latitude*100.0)/100.0;
            CGFloat roundedLong=roundf( geoPoint.longitude*100.0)/100.0;

            PFGeoPoint * newPoint=[PFGeoPoint geoPointWithLatitude:roundedLat longitude:roundedLong];
            
            [[PFUser currentUser] setObject:newPoint forKey:@"location"];
            [[PFUser currentUser] saveInBackground]; //So other people can find me
            
            //No problems w/ internet or access to current user's location, let's continue...
            
            PFQuery *query = [PFUser query]; //Query for users
            
            // Location restrictions
            NSInteger searchRadius=[[PFUser currentUser][@"searchRadius"] integerValue];
            [query whereKey:@"location" nearGeoPoint:[PFUser currentUser][@"location"] withinMiles:searchRadius];
            
            //Now we'll add some more constraints to our query...
            
            [query setLimit:30]; // This number subject to tweaking based on amount of data and speed of connection
            
            [query whereKey:@"gender" containedIn:[PFUser currentUser][@"genderInterests"]]; //only show users of gender that I'm interested in...
            
            [query whereKey:@"username" notContainedIn:[PFUser currentUser][@"peopleIveJudged"]]; //In the fist version, let's not show same person twice to the other person...
            
            [query whereKey:@"username" notEqualTo:[PFUser currentUser].username]; // Don't show me myself!
            
            [query whereKey:@"finishedSetup" equalTo:@"YES"]; // Only show me users who have finished creating their accounts.
            
            // Limit users based on my age prefs
#warning TODO account for if user decided to imcmpletely sign up ("DID finish creating account parameters--then we need them to go over to thei profile and finish doing this", otherwise we'll get a nil for value for key crash)
            
#warning for debugging

            
            [query whereKey:@"age" greaterThanOrEqualTo:[PFUser currentUser][@"lowerAgeLimit"]];
            [query whereKey:@"age" lessThanOrEqualTo:[PFUser currentUser][@"upperAgeLimit"]];
            
            //Unfortunately Parse doesn't support imposing "Venn_Diagram" contraints on the same specific query contraint (ask djax if you want an explanation of what this means; I know the wording is weird.)
            
            //We will, therefore, just fetch all the nearby users.
            
            //Then we'll prune the userArray based upon people who don't have a least 1 common interest to the current user.
            
            //You could write a cloud function to do this, but really whether the code exists in the cloud or in XCode it does the same thing...
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                if (!error) {
                    
                    //See MatchingAlorithmDescription README file for description of the logic behind this algorithm.
                    
                    // Create an new array, which will contain all the uers who matched me already
                    NSMutableArray * usersWhoHaveMatchedMeAlready=[[NSMutableArray alloc] init];
                    
                    // Create an new array, which will contain all the uers who pass the "common-interests-checks" but who haven't matched me
                    NSMutableArray * usersWithCommonInterests=[[NSMutableArray alloc] init];
                    
                    for (PFUser * user in users)    {
                        
                        // Obtain user's intersts
                        NSMutableArray * userInterestsList=user[@"interests"];
                        
                        NSMutableArray * gendersTheyAreInterestedIn=[[NSMutableArray alloc] init];
                        
                        // POST-FETCH-SORTING
                        // When we get off of Parse, we'll implement this all in server functions.
                        
                        //This gender filtering is actually already taken care of in the above code.
                        // Make sure that people shown to me are interested in my gender.
                        //                        if (![gendersTheyAreInterestedIn containsObject:[PFUser currentUser][@"gender"]])  {
                        //                            // Don't waste my time by showing me people that aren't interested in my gender...
                        //
                        //                            continue;
                        //
                        //                        }
                        
                        BOOL WE_HAVE_COMMON_INTEREST=NO;
                        
                        for (NSString * interest in userInterestsList)  {
                            
                            if ([[PFUser currentUser][@"interests"] containsObject:interest]) {
                                
                                //They have at least one common interest (add them)
                                
                                WE_HAVE_COMMON_INTEREST=YES;
                                
                                break;
                            }
                        }
                        
                        if (WE_HAVE_COMMON_INTEREST)    {
                            if ([user[@"liked"] containsObject:[PFUser currentUser]])   {
                                
                                [usersWhoHaveMatchedMeAlready addObject:user];
                                
                            } else {
                                [usersWithCommonInterests addObject:user];
                            }
                        }
                    }
                    
                    // Now we've got a list of users with at least one common interest, sorted in order of descending priority.
                    NSArray * usersToShowMeTemp=[usersWhoHaveMatchedMeAlready arrayByAddingObjectsFromArray:usersWithCommonInterests];
                    
                    // Now pass this array in to the next method, checking first to make sure we found at least 1 person.
                    if ([usersToShowMeTemp count]==0)   {
                        REFRESHING_CARDS=NO;
                        NSLog(@"no one similar nearby!");
#warning write some kind of indicator to the user that there are no nearby users with similar interests.
                    } else{
                        [self fetchProfileImagesForUsers:usersToShowMeTemp];
                    }
                    
                } else {
                    [self handleFetchError:error];
                }
            }];
            
            
        } else{
            NSLog(@"Location Fetching Error: %@",error.description);
        }
    }];
    
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
                    
                    //switch the pointers over.
                    self.usersImagesDict=imageDictTemp;
                    self.usersArray=[NSMutableArray arrayWithArray:usersArray];
                    
 
                    // Now that we've got all the info we need to build the basic card stack, we need to do some parsing to do format the displayed information. A superclass is used to do this.
                    
                    // This line hits when the tag 'fires' aka we have all the photos.
                    
                    
        #warning incomplete implementation, write the update UI methods here.
                    
                    // Update the cards
                    self.draggableBackgroundView.commonInterestsArray=commonInterestsArray;
                    self.draggableBackgroundView.mainInfoArray=mainUserInfoArray;
                    self.draggableBackgroundView.photosArray=photosArray;
                    
                    REFRESHING_CARDS=NO;
                }
                
            }
            else{
                [self handleFetchError:error];
            }
        }];
    }
    
}

-(void)handleFetchError:(NSError *)error   { // When there is a fetch error due to timeout, there's not much we can do. Just reset the variables (get 'em ready for another refresh, and then possibly call to refresh again).
    REFRESHING_CARDS=NO;
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

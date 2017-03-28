//
//  AppDelegate.m

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseFacebookUtilsV4.h"
#import "SIAlertView.h"
#import "Reachability.h"
#import <OneSignal/OneSignal.h>
#import <AudioToolbox/AudioServices.h>
#import "NSUserDefaults+DemoSettings.h"
#import "ColorSuperclass.h"

@interface AppDelegate ()

//Reachability properties:
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@property (strong, nonatomic) CLLocationManager * locationManager;

@property (strong, nonatomic) CLLocation * currentLocation;
@property (strong, nonatomic) OneSignal * oneSignal;

@end

@implementation AppDelegate {
    id _services;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];

    //Messaging
    // Load our default settings
    [NSUserDefaults saveIncomingAvatarSetting:YES];
//    [NSUserDefaults saveOutgoingAvatarSetting:YES]; //Hacking the messages avatar thing, don't remember shit about this line, or why I commented it out...

    //oh well, that other server doesn't seem to be working. Let's use the other one for now.
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"YOUR_ID_HERE";
        configuration.clientKey = @"YOUR_KEY_HERE";
        configuration.server = @"SERVER_URL";
    }]];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    [attributes setValue:[UIFont fontWithName:@"Avenir" size:25] forKey:UITextAttributeFont];
    
    [FBSDKSettings setAppID:@"FB_ID_HERE"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [self setUpCurrentLocationTracking];
    
    //For Reachability Class.
    [self setUpReachability];

    //// SIALertView characteristics...
    [[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:13]];

    [[SIAlertView appearance] setCornerRadius:12];
    [[SIAlertView appearance] setShadowRadius:20];
    [[SIAlertView appearance] setViewBackgroundColor:[UIColor colorWithRed:0.891 green:0.936 blue:0.978 alpha:1.000]];

    
    [[SIAlertView appearance] setDefaultButtonImage:[[UIImage imageNamed:@"button-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateNormal];
    [[SIAlertView appearance] setDefaultButtonImage:[[UIImage imageNamed:@"button-default-d"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateHighlighted];

    
    [[SIAlertView appearance] setCancelButtonImage:[[UIImage imageNamed:@"button-cancel"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateNormal];
    [[SIAlertView appearance] setCancelButtonImage:[[UIImage imageNamed:@"button-cancel-d"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateHighlighted];
    [[SIAlertView appearance] setDestructiveButtonImage:[[UIImage imageNamed:@"button-destructive"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateNormal];
    [[SIAlertView appearance] setDestructiveButtonImage:[[UIImage imageNamed:@"button-destructive-d"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateHighlighted];
    
    //djax alteration

    [[SIAlertView appearance] setDestructiveButtonImage:[[UIImage imageNamed:@"button-cancel"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateNormal];
    [[SIAlertView appearance] setDestructiveButtonImage:[[UIImage imageNamed:@"button-cancel-d"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateHighlighted];
    
    //another djax alteration
    [[SIAlertView appearance] setDefaultButtonImage:[[UIImage imageNamed:@"button-cancel"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateNormal];
    [[SIAlertView appearance] setDefaultButtonImage:[[UIImage imageNamed:@"button-cancel-d"] resizableImageWithCapInsets:UIEdgeInsetsMake(15,5,14,6)] forState:UIControlStateHighlighted];
    
#warning I, djax, made them all colorless because I wanted to do that.

    
    self.oneSignal = [[OneSignal alloc]
                      initWithLaunchOptions:launchOptions
                      appId:@"APP_ID_HERE"
                      handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
                          NSLog(@"OneSignal Notification opened:\nMessage: %@", message);
                          
                          //Refresh These Controllers
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLiveNearbySinceReceivedMessage"
                                                                              object:self
                                                                            userInfo:nil];
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessagesSinceReceivedMessage"
                                                                              object:self
                                                                            userInfo:nil];

                          if (additionalData) {
                              NSLog(@"additionalData: %@", additionalData);
                              
                              // Check for and read any custom values you added to the notification
                              // This done with the "Additional Data" section the dashboard.
                              // OR setting the 'data' field on our REST API.
                              NSString* customKey = additionalData[@"customKey"];
                              if (customKey)
                                  NSLog(@"customKey: %@", customKey);
                          }
                      }];
    
    [self.oneSignal registerForPushNotifications];

    return YES;
}

-(OneSignal *)returnOneSignalInstance   {
    return self.oneSignal;
}

-(void)sendTagForUsername:(NSString *)username  {
   // Send tag:After login
    [self.oneSignal sendTag:@"username" value:username];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

-(BOOL)returnInternetConnectionAvailable    {
    NSLog(@"status: %ld",(long)[self.internetReachability currentReachabilityStatus]);
    if ([self.internetReachability currentReachabilityStatus]==NotReachable)   { //from Reachability.h class, provided by Apple
        return NO;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


///REACHABILITY
-(void)setUpReachability    {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor to determine reachability.
    NSString *remoteHostName = @"www.apple.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
}

//------------ Current Location Address-----
-(void)setUpCurrentLocationTracking
{
    //---- For getting current gps location
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    //------
}

-(CLLocationManager *)returnLocationManager {
    return self.locationManager;
}

-(CLLocation *)returnCurrentLocation {
    return self.currentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

//-(BOOL)appIsInBackground{ //Might want to user this later
//    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
//    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
//    {
//        return YES;
//    }
//    return NO;
//}




@end

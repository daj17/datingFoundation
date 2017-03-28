//
//  AppDelegate.h

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <OneSignal/OneSignal.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(BOOL)returnInternetConnectionAvailable;

// Location management
-(CLLocationManager *)returnLocationManager; //these two methods are for location tracking.
-(CLLocation *)returnCurrentLocation;
-(void)setUpCurrentLocationTracking;
-(void)sendTagForUsername:(NSString *)username;
-(OneSignal *)returnOneSignalInstance;


@end


//
//  ColorSuperclass.h
//  Campus Whiteboard
//
//  Created by Portanos on 4/7/16.
//  Copyright © 2016 Jackson Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorSuperclass : UIViewController

//In the interests table view controller
+(UIColor *)returnInterestTableViewHeaderColor;

//In the interests table view controller
+(UIColor *)returnInterestSelectionTableViewColor;

//ENTRANCE VIEW:
+(UIColor *)returnSignInWithFacebookButtonColor;
+(UIColor *)returnEntranceBackgroundColor;

+(UIColor *)returnProfilePicBorderColor;

//TAB BAR
+(UIColor *)returnTabbarTextTintColor;
+(UIColor *)returnTabbarBackgroundTintColor;

//logout coloring
+(UIColor *)returnSettingsButtonTintColor;
+(UIColor *)returnLogoutOptionsColor;

+(UIColor *)colorFromHex:(NSString *)hex;

+(UIColor *)theySentYouSomethingLiveMessageColor;
+(UIColor *)ISentThemSomethingLiveMessageColor;

+(UIColor *)returnTheySentMessageDiscolure;

+(UIColor *)returnActivityIndicatorTint;

+(UIColor *)returnGoPersonalControllerNextColor;

+(UIColor *)returnProfSliderTints;

+(UIColor *)returnNavBarTintInLive;

// Color of act. ind. when saving bio info
+(UIColor *)returnSavingBioIndicatorColor;

+(UIColor *)returnHasntMadeBioYetColor;
+(UIColor *)returnHasntMadeSecondPicYetColor;
+(UIColor *)returnHasntMadeSecondPicOrMaybeBioSettingsColor;

//Personal Info:
+(UIColor *)returnPersonalInfoBetweenColor;
+(UIColor *)returnPersonalInfoTextFieldsTextColor;
+(UIColor *)returnPersonalInfoBackgroundColorForViews;
+(UIColor *)returnNavigationBarTintColor;

//messaging
+(UIColor *)returnIncomingMessagesColor;

//custom segments:
+(UIColor *)returnPlayingCustomSegmentColor;

//loadingviews
+(UIColor *)returnFirstLoadingViewColor    ;
+(UIColor *)returnSecondLoadingViewColor    ;
+(UIColor *)returnThirdLoadingViewColor    ;


+(UIColor *)returnDonePickingBirthdayViewColor;

//allow location
+(UIColor *)returnAllowLocationButtonColor;
//+(UIColor *)returnDontAllowContactsButtonColor;
+(UIColor *)returnRequestLocationBackgroundColor;
/////////////////////////////////

+(UIColor *)returnNextButtonTextTintColor;

+(UIColor *)returnMakeSecondAndThirdPictureBackground;

+(UIColor *)returnChooseStoreImageColor;

+(UIColor *)returnApplicationMainColor;


@end

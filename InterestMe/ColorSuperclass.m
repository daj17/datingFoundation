//
//  ColorSuperclass.m
//  Campus Whiteboard
//
//  Created by Portanos on 4/7/16.
//  Copyright © 2016 Jackson Technologies LLC. All rights reserved.
//

#import "ColorSuperclass.h"

@interface ColorSuperclass ()

@end

@implementation ColorSuperclass

+(UIColor *)returnInterestTableViewHeaderColor  {
    
    NSString * hexString=@"#FF7722";
    return [self colorFromHex:hexString];
    
//    NSString * hexString=@"#0BB5FF";
//
//    unsigned rgbValue = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:hexString];
//    [scanner setScanLocation:1]; // bypass '#' character
//    [scanner scanHexInt:&rgbValue];
//    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)returnInterestSelectionTableViewColor{
    
    NSString * hexString=@"#0BB5FF";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


//ENTRANCE VIEW CONTROLLER
+(UIColor *)returnSignInWithFacebookButtonColor  {
    
    NSString * hexString=@"#3b5998";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
+(UIColor *)returnEntranceBackgroundColor  {
    return [UIColor whiteColor];
    //Uncomment to add non-white color for background
//    NSString * hexString=@"#0BB5FF";
//    
//    unsigned rgbValue = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:hexString];
//    [scanner setScanLocation:1]; // bypass '#' character
//    [scanner scanHexInt:&rgbValue];
//    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)returnTabbarTextTintColor   {
    NSString * hexString=@"#FF7722";
    return [self colorFromHex:hexString];

}

+(UIColor *)returnActivityIndicatorTint   {
    NSString * hexString=@"#FF7722";
    return [self colorFromHex:hexString];
    
}

///choosing store images
+(UIColor *)returnChooseStoreImageColor    {
    UIColor * color= [self colorFromHex:@"#1FBAD6"];
    return [color colorWithAlphaComponent:0.2f];
    ///end choosing store images
}

+(UIColor *)returnNextButtonTextTintColor   {
    
    
    
    NSString * hexString=@"#FF7722";
//    NSString * hexString=@"#3b5998";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)returnApplicationMainColor    {
    UIColor * color= [self colorFromHex:@"#55DE83"];
    return color;
}

+(UIColor *)returnMakeSecondAndThirdPictureBackground   {
//    NSString * hexString=@"#d7e6fa";
    NSString * hexString=@"#FF7722";

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:.4];
}

+(UIColor *)returnProfilePicBorderColor   {
    //    NSString * hexString=@"#d7e6fa";
    NSString * hexString=@"#FF7722";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1];
}



+(UIColor *)returnTabbarBackgroundTintColor   {
    NSString * hexString=@"#000080";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)returnIncomingMessagesColor{
//    NSString * hexString=@"#037CFF";
    NSString * hexString=@"#FF7722";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)theySentYouSomethingLiveMessageColor{
    
    
    NSString * hexString=@"#FF7722";
//     NSString * hexString=@"#FF6600";

    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)ISentThemSomethingLiveMessageColor{
    
    
    
    NSString * hexString=@"#037CFF";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}



+(UIColor *)returnSettingsButtonTintColor{
    NSString * hexString=@"#000080";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
+(UIColor *)returnLogoutOptionsColor{
    NSString * hexString=@"#000080";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)returnSavingBioIndicatorColor{
    NSString * hexString=@"#000080";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//Personal info controller:
+(UIColor *)returnPersonalInfoBackgroundColorForViews {
    NSString * hexString=@"#F0F8FF";
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//Personal info controller:
+(UIColor *)returnPersonalInfoTextFieldsTextColor {
    return [UIColor lightGrayColor];
//    NSString * hexString=@"#F0F8FF";
//    
//    unsigned rgbValue = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:hexString];
//    [scanner setScanLocation:1]; // bypass '#' character
//    [scanner scanHexInt:&rgbValue];
//    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

//Personal info controller:
+(UIColor *)returnPersonalInfoBetweenColor {
    return [UIColor yellowColor];
//    NSString * hexString=@"#F0F8FF";
//    
//    unsigned rgbValue = 0;
//    NSScanner *scanner = [NSScanner scannerWithString:hexString];
//    [scanner setScanLocation:1]; // bypass '#' character
//    [scanner scanHexInt:&rgbValue];
//    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)returnNavigationBarTintColor    {
    return [self colorFromHex:@"#1FBAD6"];
}

///loading view
+(UIColor *)returnFirstLoadingViewColor    {
    return [self colorFromHex:@"#7FFDF5"];
}

+(UIColor *)returnSecondLoadingViewColor    {
    return [self colorFromHex:@"#509EEA"];
}

+(UIColor *)returnThirdLoadingViewColor    {
    return [self colorFromHex:@"#FF9A9E"];
}

+(UIColor *)returnHasntMadeBioYetColor    {
    
    return [self colorFromHex:@"#FF6A6A"];
        return [self colorFromHex:@"#f96161"];
    
    return [UIColor redColor];;
}

+(UIColor *)returnHasntMadeSecondPicYetColor    {
        return [self colorFromHex:@"#FF6A6A"];
    return [self colorFromHex:@"#f96161"];

    return [UIColor redColor];;
}

+(UIColor *)returnHasntMadeSecondPicOrMaybeBioSettingsColor    {
    
    return [UIColor redColor];;
}

+(UIColor *)returnDonePickingBirthdayViewColor    {
    return [self colorFromHex:@"#FF7722"];
}

// Location requests:
+(UIColor *)returnAllowLocationButtonColor    {
    return [self colorFromHex:@"#1FBAD6"];
}

// Location requests:
+(UIColor *)returnGoPersonalControllerNextColor    {
        return [self colorFromHex:@"#FF7722"];
}


+(UIColor *)returnPlayingCustomSegmentColor    {
        NSString * hexString=@"#FF7722";
    return [self colorFromHex:hexString];
//    return [self colorFromHex:@"#1FBAD6"];
}

+(UIColor *)returnNavBarTintInLive    {
        return [self colorFromHex:@"#FF7722"];

}

+(UIColor *)returnProfSliderTints    {
    return [self colorFromHex:@"#FF7722"];
    
}

+(UIColor *)returnTheySentMessageDiscolure    {
    NSString * hexString=@"#FF7722";
    return [self colorFromHex:hexString];
    //    return [self colorFromHex:@"#1FBAD6"];
}

+(UIColor *)returnRequestLocationBackgroundColor    {
    return [self colorFromHex:@"#509EEA"];
}
//////////////////////////

+(UIColor *)colorFromHex:(NSString *)hex {
    unsigned int c;
    if ([hex characterAtIndex:0] == '#') {
        [[NSScanner scannerWithString:[hex substringFromIndex:1]] scanHexInt:&c];
    } else {
        [[NSScanner scannerWithString:hex] scanHexInt:&c];
    }
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0
                           green:((c & 0xff00) >> 8)/255.0
                            blue:(c & 0xff)/255.0 alpha:1.0];
}



@end

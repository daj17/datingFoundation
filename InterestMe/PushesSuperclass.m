//
//  PushesSuperclass.m
//  Written by DJAX
//Uses OpenSignal

#import "PushesSuperclass.h"
#import <Parse/Parse.h>
#import <OneSignal/OneSignal.h>

@interface PushesSuperclass ()

@end

@implementation PushesSuperclass

// Send a push to the recipient of the message
+(void)sendMessagePushToPlayerIds:(NSMutableArray *)playerIds withOneSignalObject:(OneSignal *)oneSignal   {
    NSMutableString * message=[[NSMutableString alloc] init];
    [message appendString:[PFUser currentUser][@"first_name"]];
    [message appendString:@" sent you a message!"];
    
    [oneSignal postNotification:@ {
        @"contents" : @{@"en": message},
        @"include_player_ids": playerIds,
        @"ios_badgeCount": @1,
        @"ios_badgeType": @"Increase"

     }];
}

@end

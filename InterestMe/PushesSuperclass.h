//
//  PushesSuperclass.h
//  InterestMe
//
//  Created by Portanos on 8/1/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneSignal/OneSignal.h>

@interface PushesSuperclass : UIViewController

+(void)sendMessagePushToPlayerIds:(NSMutableArray *)playerIds withOneSignalObject:(OneSignal *)oneSignal;

@end

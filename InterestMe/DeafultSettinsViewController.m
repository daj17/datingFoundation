//
//  DeafultSettinsViewController.m
//  InterestMe
//
//  Created by Portanos on 6/12/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "DeafultSettinsViewController.h"

@interface DeafultSettinsViewController ()

@end

@implementation DeafultSettinsViewController

+(NSNumber *)returnDeafultSearchRadius   {
    return [NSNumber numberWithInteger:50];
}

+(NSNumber *)returnMinSearchRadius   {
    return [NSNumber numberWithInteger:1];
}

+(NSNumber *)returnMaxSearchRadius   {
    return [NSNumber numberWithInteger:100];
}

@end

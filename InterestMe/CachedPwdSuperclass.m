//
//  CachedPwdSuperclass.m
//  InterestMe
//
//  Created by Portanos on 7/27/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "CachedPwdSuperclass.h"

@interface CachedPwdSuperclass ()

@end

@implementation CachedPwdSuperclass

+(NSString *)returnUniversalPassword    { // As this is an early prototype I've assigned just on universal password to all accounts, since accounts are created with FB this helps with easy login. If the product proves worth continuing implementing a more robust and secure system would just take one additional page where a user could choose a password.
    return @"kj86SDH$kjsdfjk(23uioA4";
}

@end

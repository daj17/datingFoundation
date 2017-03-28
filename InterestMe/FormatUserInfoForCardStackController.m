//
//  FormatUserInfoForCardStackController.m
//  InterestMe
//
//  Created by Portanos on 7/10/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "FormatUserInfoForCardStackController.h"
#import "AgeCalcSuperclass.h"
#import <Parse/Parse.h>

@interface FormatUserInfoForCardStackController ()

@end

@implementation FormatUserInfoForCardStackController

// Formats the common interests of two users
+(NSString * )returnCommonInterestStringInfoBetweenMe:(PFUser *)me andUser:(PFUser *)otherPerson {
    
    NSMutableArray * myInterests=me[@"commonInterests"];
    NSMutableArray * secondUsersInterests=otherPerson[@"commonInterests"];
    
    NSMutableString * firstPieceFormatted=[[NSMutableString alloc] init];
    [firstPieceFormatted appendString:@"Common Interests: ("];
    
    NSMutableString * formattedCommonInterestInfo=[[NSMutableString alloc] init];
    
    NSInteger commonInterestsNum=0;
    for (int i=0;i<[myInterests count];i++) {
        NSString * myInterest=[myInterests objectAtIndex:i];
        if ([secondUsersInterests containsObject:myInterest])   {
            //it's a common interest
            [formattedCommonInterestInfo appendString:myInterest];
            
            if (i==[myInterests count]-2)   {
                [formattedCommonInterestInfo appendString:@" and "];
            }
            else if (i<[myInterests count]-2)   {
                [formattedCommonInterestInfo appendString:@", "];
            }
            
            commonInterestsNum=commonInterestsNum+1;
            
        }
    }
    
    //    if (commonInterestsNum==0)  {
    
    NSMutableArray * arrayOfQuips=[[NSMutableArray alloc] init]; // just some funny quips
    
    //make the strings
    NSString * firstPosibilityString=@"What are you waiting for?";
    NSString * secondPosibilityString=@"It's now or never!";
    //NSString * thirdPosibilityString=@"Maybe this is the new soulmate you've been dreaming of!";
    NSString * fourthPosibilityString=@"Go ahead, say hey!";
    NSString * fifthPosibilityString=@"You're only getting older!";
    NSString * sixthPosibilityString=@"Go for it!";
    NSString * seventhPosibilityString=@"What have you got to lose?";
    NSString * eigthPosibilityString=@"Sometimes all it takes is hello.";
    NSString * ninthPosibilityString=@"Careful, you might catch the feels!";
    NSString * tenthPosibilityString=@"Take a chance!";
//    NSString * eleventhPosibilityString=@"Your kids will love the story of how you met!";
    NSString * twelfthPosibilityString=@"Netflix And Chill is just a chat away.";
    
    //now add them
    [ arrayOfQuips addObject:firstPosibilityString];
    [ arrayOfQuips addObject:secondPosibilityString];
    //[ arrayOfQuips addObject:thirdPosibilityString];
    [ arrayOfQuips addObject:fourthPosibilityString];
    [ arrayOfQuips addObject:fifthPosibilityString];
    [ arrayOfQuips addObject:sixthPosibilityString];
    [ arrayOfQuips addObject:seventhPosibilityString];
    [ arrayOfQuips addObject:eigthPosibilityString];
    [ arrayOfQuips addObject:ninthPosibilityString];
    [ arrayOfQuips addObject:tenthPosibilityString];
//    [ arrayOfQuips addObject:eleventhPosibilityString];
    [ arrayOfQuips addObject:twelfthPosibilityString];
    
    float low_bound = 0;
    float high_bound = [arrayOfQuips count]-1;
    float rndValue = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
    
    
    int intRndValue = (int)(rndValue + 0.5);
    
    
    
    
    return [arrayOfQuips objectAtIndex:intRndValue];
    
    
    //        return messageString;
    //    }
    
    [firstPieceFormatted appendString:[NSString stringWithFormat:@"%ld",commonInterestsNum]];
    
    [firstPieceFormatted appendString:@"): "];
    
    //Now append the first piece and the second together to get the final string and then return it:
    return [firstPieceFormatted stringByAppendingString:formattedCommonInterestInfo];
    
}

+(NSString * )returnMainInfoForUser:(PFUser *)user  {
    
    NSNumber * userAge=[NSNumber numberWithInteger:[AgeCalcSuperclass returnAgeUsingBirthDate:user[@"birthday"]]];
    NSString * ageString=[userAge stringValue];
    
    NSMutableString * mainString=[[NSMutableString alloc] init];
    [mainString appendString:user[@"first_name"]];
    [mainString appendString:@" ("];
    [mainString appendString:ageString];
    [mainString appendString:@")"];
    
    return mainString;
    
}

@end

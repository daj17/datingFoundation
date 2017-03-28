//
//  TwitterManagerController.m
//  InterestMe
//
//  Created by Portanos on 10/11/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "TwitterManagerController.h"
#import <Parse/Parse.h>

@interface TwitterManagerController ()

@end

@implementation TwitterManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)partTweetObjects:(NSMutableArray * )tweetObjects usingWord:(NSString *) word {
    for (PFObject * tweetObject in tweetObjects)    {
        NSString * content=tweetObject[@"text"]
    }
}






-(NSString *)onTweet:(NSString *)tweetIdentifier   {
    PFQuery * query=[PFQuery queryWithClassName:@"TweetContent"];
    [query whereKey:@"UUID" equalTo:tweetIdentifier];
    
    __block NSString  * tweetString;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * tweetArrayHolder, NSError *error) {
        if (!error) {
            //success
            
            
            PFObject * tweetObject=[tweetArrayHolder objectAtIndex:0];
            
            tweetString =tweetObject[@"text"];
            
            return tweetString; //tweetString;
            
            
            
        } else{
            return nil;
            NSLog(@"Error: %@",error);
        }
        
        
        
    }];
    
    return nil;

    
}



@end

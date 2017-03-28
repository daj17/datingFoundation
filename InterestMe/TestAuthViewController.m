//
//  TestAuthViewController.m
//  InterestMe
//
//  Created by Portanos on 8/20/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "TestAuthViewController.h"
#import "OLFacebookAlbumRequest.h"
#import "OLFacebookPhotosForAlbumRequest.h"
#import "OLFacebookAlbum.h"
#import "OLFacebookImage.h"
#import "OLFacebookImagePickerController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface TestAuthViewController ()

@end

@implementation TestAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions = @[@"public_profile",  @"user_photos"];
    CGRect f = loginButton.frame;
    f.origin.x = (self.view.frame.size.width - f.size.width) / 2;
    f.origin.y = (self.view.frame.size.height - f.size.height) / 2;
    loginButton.frame = f;
    [self.view addSubview:loginButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

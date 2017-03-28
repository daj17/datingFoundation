//
//  FacebookImagePickerController.m
//  FacebookImagePicker
//
//  Created by Deon Botha on 16/12/2013.
//  Copyright (c) 2013 Deon Botha. All rights reserved.
//

#import "OLFacebookImagePickerController.h"
#import "OLAlbumViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MBProgressHUD.h"
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface OLFacebookImagePickerController () <OLAlbumViewControllerDelegate>
@property (nonatomic, strong) OLAlbumViewController *albumVC;
@property (assign, nonatomic) BOOL haveSeenViewDidAppear;
@end

@implementation OLFacebookImagePickerController

@dynamic delegate;

- (id)init {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked)];
    if (self = [super initWithRootViewController:vc]) {
        _shouldDisplayLogoutButton = YES;
        if ([FBSDKAccessToken currentAccessToken]){
            [self showAlbumList];
        }
    }
    
    return self;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)cancelButtonClicked {

//    [self.navigationController popToViewController:self.parentViewController animated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate facebookImagePicker:self didFinishPickingImages:@[]];
}

- (void)viewDidAppear:(BOOL)animated{
    if (![FBSDKAccessToken currentAccessToken] && !self.haveSeenViewDidAppear){
        self.haveSeenViewDidAppear = YES;
        
        //Workaround so that we dont include FBSDKLoginKit
        NSArray *permissions = @[@"public_profile", @"user_photos"];
        Class FBSDKLoginManagerClass = NSClassFromString (@"FBSDKLoginManager");
        id login = [[FBSDKLoginManagerClass alloc] init];
        
        SEL aSelector = NSSelectorFromString(@"logInWithReadPermissions:fromViewController:handler:");
        
        if([login respondsToSelector:aSelector]) {
            void (*imp)(id, SEL, id, id, id) = (void(*)(id,SEL,id,id, id))[login methodForSelector:aSelector];
            if( imp ) imp(login, aSelector, permissions, self, ^(id result, NSError *error) {
                if (error) {
                    [self.delegate facebookImagePicker:self didFailWithError:error];
                } else if ([result isCancelled]) {
                    [self.delegate facebookImagePicker:self didFinishPickingImages:@[]];
                } else {
                    [self showAlbumList];
                }
            });
        }
    }
}

-(void)viewDidLoad  {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelButtonClicked) name:@"cancelFacebookPhotoChoose" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callDoneManually:) name:@"callDoneManually" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProgressIndicator) name:@"savingImageShowProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideProgressIndicator) name:@"doneSavingImageRemoveIndicator" object:nil];
    
}

-(void)showProgressIndicator    {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideProgressIndicator    {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}






- (void)showAlbumList{
    OLAlbumViewController *albumController = [[OLAlbumViewController alloc] init];
    self.albumVC = albumController;
    self.albumVC.delegate = self;
    self.albumVC.shouldDisplayLogoutButton = self.shouldDisplayLogoutButton;
    self.viewControllers = @[albumController];
}

- (void)setSelected:(NSArray *)selected {
    self.albumVC.selected = selected;
}

- (NSArray *)selected {
    return self.albumVC.selected;
}

- (void)setShouldDisplayLogoutButton:(BOOL)shouldDisplayLogoutButton
{
    _shouldDisplayLogoutButton = shouldDisplayLogoutButton;
    self.albumVC.shouldDisplayLogoutButton = self.shouldDisplayLogoutButton;
}

#pragma mark - OLAlbumViewControllerDelegate methods

- (void)albumViewControllerDoneClicked:(OLAlbumViewController *)albumController {
    [self.delegate facebookImagePicker:self didFinishPickingImages:albumController.selected];
}

-(void)callDoneManually:(NSNotification *)notification {
    NSDictionary * dict=notification.userInfo;
    NSString * urlString=[dict objectForKey:@"urlStr"];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSData * data=[NSData dataWithContentsOfURL:url];
    
    
    UIImage * image = [UIImage imageWithData:data];
    [self.delegate facebookImagePicker:self didFinishPickingImages:@[image]];
}


- (void)albumViewController:(OLAlbumViewController *)albumController didFailWithError:(NSError *)error {
    [self.delegate facebookImagePicker:self didFailWithError:error];
}

- (void)albumViewController:(OLAlbumViewController *)albumController didSelectImage:(OLFacebookImage *)image{
    if ([self.delegate respondsToSelector:@selector(facebookImagePicker:didSelectImage:)]){
        [self.delegate facebookImagePicker:self didSelectImage:image];
    }
}

- (BOOL)albumViewController:(OLAlbumViewController *)albumController shouldSelectImage:(OLFacebookImage *)image{
    if ([self.delegate respondsToSelector:@selector(facebookImagePicker:shouldSelectImage:)]){
        return [self.delegate facebookImagePicker:self shouldSelectImage:image];
    }
    else{
        return YES;
    }
}

@end

//
//  RequestLocationAccessController.m
//  Portanos
//
//  Created by Portanos on 12/7/15.
//  Copyright © 2015 Portanos LLC. All rights reserved.
//

#import "RequestLocationAccessController.h"
#import <CoreLocation/CoreLocation.h>
#import "ColorSuperclass.h"
//#import "userNameAndPasswordViewController.h"
#import "AppDelegate.h"

@interface RequestLocationAccessController ()
@end

@implementation RequestLocationAccessController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.descriptionTextView.userInteractionEnabled=NO;
    [self.descriptionTextView setTextColor:[UIColor whiteColor]];
    
//    [self.descriptionTextView setBackgroundColor:[ColorSuperclass returnRequestContactsBackgroundColor]];
    [self.view setBackgroundColor:[ColorSuperclass returnRequestLocationBackgroundColor]];
    [self.allowButton setBackgroundColor:[ColorSuperclass returnAllowLocationButtonColor]];
//    [self.dontAllowButton setBackgroundColor:[ColorSuperclass returnDontAllowContactsButtonColor]];
}

-(void)viewWillAppear:(BOOL)animated    {
    self.navigationController.navigationBar.hidden=YES;
}

- (IBAction)allowLocationTapped:(UIButton *)sender {
    
    AppDelegate * appDelegate = ( AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate setUpCurrentLocationTracking];
    //perform the segue.
    if ([appDelegate returnLocationManager].location) {
        //we can has their location while they use the app, just let the thread continue...
    } else{
        //show them an alert view explaining why we need their location.
        [[appDelegate returnLocationManager] requestWhenInUseAuthorization];
        NSLog(@"They pressed the button, requesting access.");
    }
    [self performSegueWithIdentifier:@"goToPersonalInfoSegue" sender:self];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

//- (IBAction)doNotAllowLocationAccess:(UIButton *)sender {
//    AppDelegate * appDelegate = ( AppDelegate *)[[UIApplication sharedApplication]delegate];
//    
//    [appDelegate setUpCurrentLocationTracking];
//    [self performSegueWithIdentifier:@"goToUsernameAndPasswordController" sender:self];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//}


@end

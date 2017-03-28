//
//  FeedbackViewController.m
//  Portanos
//
//  Created by Portanos on 12/21/15.
//  Copyright © 2015 Portanos LLC. All rights reserved.
//

#import "FeedbackViewController.h"
#import "AppDelegate.h"
#import "ColorSuperclass.h"
#import "SIAlertView.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"


@interface FeedbackViewController () <UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSString * placeHolderString;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedbackTextView.scrollEnabled=NO;
    self.feedbackTextView.returnKeyType=UIReturnKeySend;
    
    self.feedbackTextView.delegate=self;
    // Do any additional setup after loading the view.
    [self.feedbackTextView setBackgroundColor:[UIColor clearColor]];
    
    [self.navigationItem setTitle:@"Bio"];
    [self makeSendFeedbackButton];
    [self.feedbackTextView setTextColor:[UIColor grayColor]];
    
    self.placeHolderString=@"Tap here to write a brief bio! Press save in the upper right when you're done 🙌";
    self.feedbackTextView.text=self.placeHolderString;
}

-(void)makeSendFeedbackButton   {
    UIBarButtonItem *btnPrvw = [[UIBarButtonItem alloc]
                                initWithTitle:@"Save"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(saveFeedback)];
    self.navigationItem.rightBarButtonItem=btnPrvw;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(BOOL)returnIsThereInternet    {
    [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate returnInternetConnectionAvailable];
}

-(void)showNoInternet    {
    
    NSString * titleString=@"Oops!";
    NSString * messageString=@"Your device isn't connected to the internet. Connect your device to save your bio.";
    NSString * optionString=@"Ok"; //only one option.
    
    // Custom forked alert class.
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:messageString];
    
    [alertView addButtonWithTitle:optionString
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              // Don't need to do anything, It's on the user to connect their device.
                          }];
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

BOOL SAVING_BIO;
-(void)saveFeedback {
    if (!SAVING_BIO)   {
        [self.feedbackTextView resignFirstResponder];
        
        if (![self returnIsThereInternet])    {
            SAVING_BIO=NO;
            [self showNoInternet];
            return;
        }
        
        if ([self.feedbackTextView.text isEqualToString:@""] || [[self.feedbackTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])  {
            [self showNoFeedback];
            SAVING_BIO=NO;
            return;
        }
        
        [self showProgressIndicator];
        
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        activityIndicator.color=[ColorSuperclass returnSavingBioIndicatorColor];
        //[self navigationItem].rightBarButtonItem = barButton;
        //[activityIndicator startAnimating];
        [PFUser currentUser][@"bio"]=self.feedbackTextView.text; // Save new bio...
        SAVING_BIO=YES;
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL successful, NSError *error) {
            if (!error) {
                //all good
                [self.feedbackTextView resignFirstResponder];
                [self hideProgressIndicator];
                SAVING_BIO=NO;

                [self.navigationController popViewControllerAnimated:NO];
            } else{
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                [self makeSendFeedbackButton];
                [self hideProgressIndicator];

                NSLog(@"error: %@",error);
                SAVING_BIO=NO;
            }
        }];
        
    }
}

-(void)viewWillAppear:(BOOL)animated    {
    if ([PFUser currentUser][@"bio"]) self.feedbackTextView.text=[PFUser currentUser][@"bio"];
}

-(void)showProgressIndicator    {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideProgressIndicator    {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"] && [textView isEqual:self.feedbackTextView]) { //no return characters allowed
        [self saveFeedback];
        return NO;
    }
    
    return textView.text.length + (text.length - range.length) <= 200;
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    if ([textView.text isEqualToString:self.placeHolderString])  {
        textView.text=@"";
    }
}

-(void)showNoFeedback   {
    NSString * titleString=@"Oops!";
    NSString * messageString=@"Please enter a new bio to save changes.";
    NSString * optionString=@"Ok"; //only one option.
    
    // Custom forked alert class.
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:messageString];
    
    [alertView addButtonWithTitle:optionString
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self.feedbackTextView becomeFirstResponder];
                          }];
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
    
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

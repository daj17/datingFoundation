//
//  PersonalInfoController.m
//  InterestMe
//
//  Created by Portanos on 6/17/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "PersonalInfoController.h"
#import "ColorSuperclass.h"
#import "ActionSheetStringPicker.h"
#import "CachedPwdSuperclass.h"
#import "SIAlertView.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "AgeCalcSuperclass.h"
#import <Parse/Parse.h>

@interface PersonalInfoController ()

// Person's attributes
@property (nonatomic, strong) NSMutableArray * ageArray;
@property (nonatomic, strong) NSMutableArray * genderArray;
@property (nonatomic, strong) NSMutableArray * genderInterestsArray;

// These buttons are how the user fills in each field on signup
@property (weak, nonatomic) IBOutlet UIButton *ageButton;
@property (weak, nonatomic) IBOutlet UIButton *genderButton;
@property (weak, nonatomic) IBOutlet UIButton *genderInterestsButton;

@property (strong, nonatomic) UIDatePicker * datePicker;
@property (strong, nonatomic) UIView * doneView;
@property (strong, nonatomic) UIButton * doneButton;



@end

@implementation PersonalInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *barButtonAppearance = [UIBarButtonItem appearance];
    [barButtonAppearance setTintColor:[ColorSuperclass returnActivityIndicatorTint]];
    
    //    [self.view setBackgroundColor:[ColorSuperclass returnRequestLocationBackgroundColor]];
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor grayColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:25.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
    
    // Do any additional setup after loading the view.
    
    self.ageArray=[[NSMutableArray alloc] init];
    self.genderArray=[[NSMutableArray alloc] init];
    self.genderInterestsArray=[[NSMutableArray alloc] init];
    // Age range, oldest person in the world is 116
    for (NSUInteger i = 13; i < 117; i++)
    {
        NSString * ageString=[NSString stringWithFormat:@"%d",i];
        [self.ageArray addObject:ageString];
    }
    NSLog(@"array: %@",self.ageArray);
    
    // Now we need to build up the array of the genders you can choose from
    [self.genderArray addObject:@"Male"];
    [self.genderArray addObject:@"Female"];
    [self.genderArray addObject:@"Other"];
    
    // Now we need to build up gender interest array
    [self.genderInterestsArray addObject:@"Men"];
    [self.genderInterestsArray addObject:@"Women"];
    [self.genderInterestsArray addObject:@"Men And Women"];
    [self.genderInterestsArray addObject:@"Other"];
    
    [self.ageButton setTitle:@"Choose your birthday" forState:UIControlStateNormal];
    [self.genderButton setTitle:@"Choose your gender" forState:UIControlStateNormal];
    [self.genderInterestsButton setTitle:@"Gender Interests" forState:UIControlStateNormal];
    
    //    [self.view setBackgroundColor:[UIColor grayColor]];
    
    self.navigationItem.title=@"About me";
    
    [self.ageButton setBackgroundColor:[ColorSuperclass returnPersonalInfoBackgroundColorForViews]];
    [self.genderButton setBackgroundColor:[ColorSuperclass returnPersonalInfoBackgroundColorForViews]];
    [self.genderInterestsButton setBackgroundColor:[ColorSuperclass returnPersonalInfoBackgroundColorForViews]];
    [self.ageButton setTitleColor:[ColorSuperclass returnPersonalInfoTextFieldsTextColor] forState:UIControlStateNormal];
    [self.genderInterestsButton setTitleColor:[ColorSuperclass returnPersonalInfoTextFieldsTextColor] forState:UIControlStateNormal];
    [self.genderButton setTitleColor:[ColorSuperclass returnPersonalInfoTextFieldsTextColor] forState:UIControlStateNormal];
    
    [self.genderButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:25.0]];
    
    [self.ageButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:25.0]];
    
    [self.genderInterestsButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:25.0]];
    
    
    
    // Here we do some initial setup
    //    [self setUpFields];
    
    // Here we add a custom Navigation bar
    [self addNavHeaderWithWidth:self.view.frame.size.width];
}

// When you tap to choose your age
-(IBAction)showAges:(id)sender {
    
    [self createDatePicker];
    
//    //     NSArray * ageArray=[self.ageArray  copy];
//    ActionSheetStringPicker *countryPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"Choose your age"
//                                                                                       rows:self.ageArray
//                                                                           initialSelection:[self.ageArray indexOfObject:@"21"]
//                                                                                  doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//                                                                                      
//                                                                                      NSMutableString * genderString=[[NSMutableString alloc] initWithString:@"I am: "];
//                                                                                      //                                                                                  [genderString appendString:@""];
//                                                                                      //update the UI
//                                                                                      [genderString appendString:selectedValue];
//                                                                                      [genderString appendString:@" years old"];
//                                                                                      
//                                                                                      [self.ageButton setTitle:genderString forState:UIControlStateNormal];
//                                                                                      
//                                                                                      
//                                                                                      NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//                                                                                      f.numberStyle = NSNumberFormatterDecimalStyle;
//                                                                                      NSNumber *myNumber = [f numberFromString:selectedValue];
//                                                                                      
//                                                                                      [PFUser currentUser][@"age"]=myNumber;
//                                                                                      
//                                                                                  }
//                                                                                cancelBlock:nil
//                                                                                     origin:sender];
//    
//    //[countryPicker setDoneButton:self.pickerFinishedBarButton];
//    //[countryPicker setCancelButton:self.pickerCanceledBarButton];
//    [countryPicker showActionSheetPicker];
}

// When you tap on to choose a gender
-(IBAction)showGenders:(id)sender {
    
        if (SHOWING_DATE_PICKER) return;
    
    ActionSheetStringPicker *countryPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"Choose Your Gender"
                                                                                       rows:self.genderArray
                                                                           initialSelection:[self.genderArray indexOfObject:@"Male"]
                                                                                  doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                                      
                                                                                      NSMutableString * genderString=[[NSMutableString alloc] initWithString:@"I am: "];
                                                                                      //                                                                                  [genderString appendString:@""];
                                                                                      //update the UI
                                                                                      [genderString appendString:selectedValue];
                                                                                      
                                                                                      [self.genderButton setTitle:genderString forState:UIControlStateNormal];
                                                                                      
                                                                                      [PFUser currentUser][@"gender"]=selectedValue;
                                                                                      
                                                                                      
                                                                                  }
                                                                                cancelBlock:nil
                                                                                     origin:sender];

    [countryPicker showActionSheetPicker];
}



// When you tap on to choose a gender interest
-(IBAction)showGenderInterests:(id)sender {
    
    if (SHOWING_DATE_PICKER) return;
    
    NSString * predictedInterest=@"Women";
    if ([self.genderButton.titleLabel.text containsString:@"Female"]) {
        predictedInterest=@"Men";
    };
    if ([self.genderButton.titleLabel.text containsString:@"Other"]) {
        predictedInterest=@"Men And Women";
    };
    ActionSheetStringPicker *countryPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"Interested In:"
                                                                                       rows:self.genderInterestsArray
                                                                           initialSelection:[self.genderInterestsArray indexOfObject:predictedInterest]
                                                                                  doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                                      
                                                                                      NSMutableString * genderString=[[NSMutableString alloc] initWithString:@"Interested in: "];
                                                                                      //                                                                                  [genderString appendString:@""];
                                                                                      //update the UI
                                                                                      [genderString appendString:selectedValue];
                                                                                      
                                                                                      //update the UI
                                                                                      [self.genderInterestsButton setTitle:genderString forState:UIControlStateNormal];
                                                                                      
                                                                                      NSMutableArray * genderInterestsArray=[[NSMutableArray alloc] init];
                                                                                      
                                                                                      if ([selectedValue isEqualToString:@"Men And Women"])   {
                                                                                          [genderInterestsArray addObject:@"Female"];
                                                                                          [genderInterestsArray addObject:@"Male"];
                                                                                      } else if ([selectedValue isEqualToString:@"Men"])  {
                                                                                          [genderInterestsArray addObject:@"Male"];
                                                                                      } else if ([selectedValue isEqualToString:@"Other"])  {
                                                                                          [genderInterestsArray addObject:@"Other"];
                                                                                      } else{
                                                                                          [genderInterestsArray addObject:@"Female"];
                                                                                      }
                                                                                      [PFUser currentUser][@"genderInterests"]=genderInterestsArray;
                                                                                      
                                                                                  }
                                                                                cancelBlock:nil
                                                                                     origin:sender];
    
    //[countryPicker setDoneButton:self.pickerFinishedBarButton];
    //[countryPicker setCancelButton:self.pickerCanceledBarButton];
    [countryPicker showActionSheetPicker];
}

-(void)addNavHeaderWithWidth:(CGFloat)width {
    
    UIView * navView=[[UIView alloc] init];
    
    CGFloat navBarHeight=100;
    CGRect navBarFrame=CGRectMake(0, 0, width, navBarHeight);
    [navView setFrame:navBarFrame];
    
    [navView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.1]];
    
    CGFloat forwardBackDisplacement=0.0f;
    
    //    UIButton * backButton=[[UIButton alloc] init];
    //    //    [backButton setBackgroundColor:[UIColor blueColor]];
    //    CGRect backButtonFrame=CGRectMake(forwardBackDisplacement*.2, 0, navBarHeight*1.9, navBarHeight);
    //    [backButton setFrame:backButtonFrame];
    //    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    //    [backButton setTitleColor:[ColorSuperclass returnNavigationBarTintColor] forState:UIControlStateNormal];
    //    [backButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f]];
    
    UIButton * forwardButton=[[UIButton alloc] init];
    
    [forwardButton setTitleColor:[ColorSuperclass returnNavigationBarTintColor] forState:UIControlStateNormal];
    
    
    //    [forwardButton setBackgroundColor:[UIColor greenColor]];
    CGFloat forwardButtonWidth=self.view.frame.size.width;
    CGFloat forwardButtonHeight=80;
    
    CGFloat forwardButtonYValue=self.view.frame.size.height-forwardButtonHeight;
    
    CGRect forwardButtonFrame=CGRectMake(0, forwardButtonYValue, forwardButtonWidth, forwardButtonHeight);
    [forwardButton setFrame:forwardButtonFrame];
    //    [forwardButton setBackgroundColor:[UIColor redColor]];
    
    [forwardButton setTitle:@"Go" forState:UIControlStateNormal];
    [forwardButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:30.0f]];
    [forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forwardButton setBackgroundColor:[ColorSuperclass returnGoPersonalControllerNextColor]];
    
    UILabel * titleView=[[UILabel alloc] initWithFrame:navBarFrame];
    [titleView setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:40.0f]];
    titleView.text=@"Info";
    titleView.textAlignment=NSTextAlignmentCenter;
    [titleView setBackgroundColor:[UIColor clearColor]];
    [navView addSubview:titleView];
    
    [titleView setTextColor:[ColorSuperclass returnNavigationBarTintColor]];
    
    //    [navView addSubview:backButton];
    [self.view addSubview:forwardButton];
    
    //    [self.view addSubview:navView];
    //
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController)];
    //    [backButton addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tapforward = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextTapped)];
    [forwardButton addGestureRecognizer:tapforward];
    
}

-(void)viewWillAppear:(BOOL)animated    {
    self.navigationController.navigationBar.hidden=NO;
}

-(void)showProgressIndicator    {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideProgressIndicator    {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

BOOL SAVING_INFO=NO;
//When the user wants to advance to next controller (aka they should have chosen all the fields)
-(void)nextTapped   {
    
    if (SAVING_INFO)   return;
    SAVING_INFO=YES;
    // First check to make sure we have Internet connection
    
    if (![self returnInternetAvailable]) {
        [self showNoInternetAvailable];
        SAVING_INFO=NO;
        return;
    }
    
    if (![PFUser currentUser][@"birthday"])  {
        [self showPleaseChooseYourAge];
        SAVING_INFO=NO;
    }
    else if (![PFUser currentUser][@"gender"])  {
        [self showPleaseChooseGender];
        SAVING_INFO=NO;
    }
    else if (!([[PFUser currentUser][@"genderInterests"] count]>0))  {
        [self showPleaseChooseGenderInterests];
        SAVING_INFO=NO;
        
    }
    else {
        [self showProgressIndicator];
        
        
        //Calculate the appriate default age filter
        
        NSInteger deafultSearchRange=4; //default search range
        
        //also note, no one under 13 can have a Facebook and therefore we don't have to worry about them being on the platform (unless Facebook changes that policy).
        
        NSInteger userAge= [AgeCalcSuperclass returnAgeUsingBirthDate:[PFUser currentUser][@"birthday"]];
        
        [PFUser currentUser][@"age"]=[NSNumber numberWithInteger:userAge];

        if (userAge<18) {
            
            //show them 13-17
            [PFUser currentUser][@"lowerAgeLimit"]=[NSNumber numberWithInt:13];
            [PFUser currentUser][@"upperAgeLimit"]=[NSNumber numberWithInt:17];
            
        } else if ((userAge-deafultSearchRange)<18) { //no people above 18 talking to people below 18
            
            [PFUser currentUser][@"lowerAgeLimit"]=[NSNumber numberWithInt:18];
            [PFUser currentUser][@"upperAgeLimit"]=[NSNumber numberWithInt:userAge+deafultSearchRange];
            
        } else {
            
            [PFUser currentUser][@"lowerAgeLimit"]=  [NSNumber numberWithInt:userAge-deafultSearchRange];
            [PFUser currentUser][@"upperAgeLimit"]=[NSNumber numberWithInt:userAge+deafultSearchRange];
            
        }
        [PFUser currentUser][@"finishedSetup"]=@"YES";
        
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
            if(!error)
            {
                
                [[PFUser currentUser] setPassword:[CachedPwdSuperclass returnUniversalPassword]];
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error)
                    {
                        NSLog(@"Saved user info!");
                        
                        
                        NSString * currentUsername=[PFUser currentUser].username;
                        NSString * password=[CachedPwdSuperclass returnUniversalPassword];
                        
                        
                        [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
                            if (!error) {
                                [PFUser logInWithUsernameInBackground:currentUsername password:password
                                                                block:^(PFUser *user, NSError *error) {
                                                                    if (user) {
                                                                        SAVING_INFO=NO;
                                                                        [self hideProgressIndicator];
                                                                        
                                                                        [self performSegueWithIdentifier:@"segueToLiveController" sender:self];
                                                                    } else {
                                                                        NSLog(@"error: %@",error);
                                                                        [self hideProgressIndicator];
                                                                        
                                                                        [self showErrorSavingUserInfo];
                                                                        SAVING_INFO=NO;
                                                                    }
                                                                }];
                                
                            } else  {
                                NSLog(@"error: %@",error);
                                [self hideProgressIndicator];
                                
                                [self showErrorSavingUserInfo];
                                SAVING_INFO=NO;
                            }
                        }];
                        
                        
                        
                        
                    } else {
                        NSLog(@"error: %@",error);
                        [self hideProgressIndicator];
                        
                        [self showErrorSavingUserInfo];
                        SAVING_INFO=NO;
                    }
                }];
                
                
            }
            else {
                NSLog(@"error: %@",error);
                [self hideProgressIndicator];
                
                [self showErrorSavingUserInfo];
                SAVING_INFO=NO;
            }
        }];
    }
}

BOOL SHOWING_DATE_PICKER=NO;
-(void)createDatePicker  {
    if (SHOWING_DATE_PICKER) return;
    SHOWING_DATE_PICKER=YES;
    
    
    CGFloat datePickerHeight=220.0f;
    CGFloat datePickerWidth=self.view.frame.size.width;
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-datePickerHeight, datePickerWidth, datePickerHeight)];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:-13];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:-116];
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
//    NSDateComponents *defaultComps = [[NSDateComponents alloc] init];
//    [defaultComps setYear:-21];
    
//    NSDate *defualtDate = [calendar dateFromComponents:defaultComps];
//    self.datePicker.date = defualtDate;
//    [self.datePicker setDate:defualtDate];

    
    [self.datePicker setMaximumDate:maxDate];
    [self.datePicker setMinimumDate:minDate];
    


    
    [self.view addSubview:self.datePicker];

    
    //now we need to set up the other view that the use can use to say that they're done picking their birthday...
    CGFloat doneViewHeight=60.0f;
    CGFloat doneViewWidth=self.view.frame.size.width;
    
    CGRect frame=CGRectMake(0, self.view.frame.size.height-datePickerHeight-doneViewHeight, doneViewWidth, doneViewHeight);
    UIView * doneView=[[UIView alloc] initWithFrame:frame];
    [doneView setBackgroundColor:[ColorSuperclass returnDonePickingBirthdayViewColor]];
    [self.view addSubview:doneView];
    
    UIButton * doneButton=[[UIButton alloc] initWithFrame:frame];
    [doneButton addTarget:self action:@selector(doneButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundColor:[UIColor clearColor]];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton=doneButton;
    [doneButton.titleLabel setTextColor:[UIColor lightGrayColor]];
    doneButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22.0]];

    [self.view addSubview:doneButton];
    self.doneView=doneView;
    
    // now we need to add the titlelabel and the done button...
    [doneView setAlpha:0.0];
    [self.datePicker setAlpha:0.0];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.datePicker setAlpha:1.0];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [doneView setAlpha:1.0];
    [UIView commitAnimations];
}

-(void)doneButtonSelected   {

    NSDate * date=self.datePicker.date;
    if ([self.datePicker.maximumDate timeIntervalSinceDate:date] <= 0) return;
    if ([self.datePicker.minimumDate timeIntervalSinceDate:date] >= 0) return;
    
    [PFUser currentUser][@"birthday"]=date;
    //now animate the dissapearance of the views.
    
    
//    NSString *dateString=[NSDate string
//    [self.ageButton setTitle:[[NSDate stringFro
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    NSInteger year = [components year];
    NSInteger day = [components day];
     NSInteger monthIndex=[components month];
    
    NSArray * monthsArray=@[@"January", @"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    
    NSString * monthsString=[monthsArray objectAtIndex:monthIndex-1];
    
    NSString * yearString=[NSString stringWithFormat:@"%ld",year];
    NSString * dayString=[NSString stringWithFormat:@"%ld",day];
    
    NSMutableString * dateStringMutable=[[NSMutableString alloc] init];
    [dateStringMutable appendString:monthsString];
    
    
    [dateStringMutable appendString:@" "];

    [dateStringMutable appendString:dayString];

    [dateStringMutable appendString:@" "];

    [dateStringMutable appendString:yearString];

    
    [self.ageButton setTitle:dateStringMutable forState:UIControlStateNormal];

    
    
    [UIView animateWithDuration:.3f animations:^{
        
        [self.doneView setAlpha:0.1f];
        [self.datePicker setAlpha:0.1f];
        [self.doneButton setAlpha:0.1f];

        
    } completion:^(BOOL finished) {
         [self.datePicker removeFromSuperview];
        [self.doneView removeFromSuperview];
        [self.doneButton removeFromSuperview];
        
    }];
    
    SHOWING_DATE_PICKER=NO;
    
    
    
    
    
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{

    
    // When `setDate:` is called, if the passed date argument exactly matches the Picker's date property's value, the Picker will do nothing. So, offset the passed date argument by one second, ensuring the Picker scrolls every time.
    
    NSDate* oneSecondAfterPickersDate = [self.datePicker.date dateByAddingTimeInterval:1] ;
    if ( [self.datePicker.date compare:self.datePicker.minimumDate] == NSOrderedSame ) {
        NSLog(@"date is at or below the minimum") ;
        self.datePicker.date = oneSecondAfterPickersDate ;
    }
    else if ( [self.datePicker.date compare:self.datePicker.maximumDate] == NSOrderedSame ) {
        NSLog(@"date is at or above the maximum") ;
        self.datePicker.date = oneSecondAfterPickersDate ;
    } else{
        [PFUser currentUser ][@"birthday"]=datePicker.date;
        NSLog(@"Just set birthday!");
    }
}



-(void)showPleaseChooseYourAge  {
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"Hang on!";
    NSString * message=@"Please choose your birthday.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
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

-(void)showPleaseChooseGender  {
    
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"Hang on!";
    NSString * message=@"Please choose your gender.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
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

-(void)showPleaseChooseGenderInterests  {
    
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"Hang on!";
    NSString * message=@"Please choose your gender interests.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
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

-(void)showErrorSavingUserInfo  {
    
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"Uh-oh";
    NSString * message=@"There was a problem saving your personal info. Please try again.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
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

-(BOOL)returnInternetAvailable  {
    [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate returnInternetConnectionAvailable];
}

-(void)showNoInternetAvailable  {
    
    //Either use the fancy subclassed alert view to show that internet isn't available, or possibly show your own fancy UI.
    NSString * titleString=@"Oops!";
    NSString * message=@"Please connect you device to a network to save your personal info.";
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString andMessage:message];
    
    [alertView addButtonWithTitle:@"Got it"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
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

// Set up the fields for choosing these different parameters.
-(void)setUpFields  {
    //
    //    UIColor * backgroundColor=[ColorSuperclass returnPersonalInfoBackgroundColorForViews];
    //    UIColor * textColor=[ColorSuperclass returnPersonalInfoTextFieldsTextColor];
    //    UIColor * borderViewsColor=[ColorSuperclass returnPersonalInfoBetweenColor];
    //
    //    // Age Label
    //    CGFloat ageFrameHeight=100;
    //    CGFloat verticalDisplacementAgeLabel=100;
    //    CGRect ageFrame=CGRectMake(0, verticalDisplacementAgeLabel, self.view.frame.size.width, ageFrameHeight);
    //    UIButton * ageLabel=[[UIButton alloc] initWithFrame:ageFrame];
    ////    ageLabel.text=@"  Choose your age";
    //    [ageLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:30.0f]];
    ////    [ageLabel setTextColor:textColor];
    //    [ageLabel setBackgroundColor:backgroundColor];
    //    self.ageLabel=ageLabel;
    //    [self.view addSubview:ageLabel];
    //
    //    CGFloat betweenDisplacement=2; // Gives little borders between the UIButtons.
    //
    //    UIView * firstBorderView=[[UIView alloc] init];
    //    CGRect firstBorderViewFrame=CGRectMake(0, verticalDisplacementAgeLabel+ageFrameHeight, self.view.frame.size.width, betweenDisplacement);
    //    [firstBorderView setBackgroundColor:borderViewsColor];
    //    [firstBorderView setFrame:firstBorderViewFrame];
    //    [firstBorderView setBackgroundColor:[UIColor grayColor]];
    //    [self.view addSubview:firstBorderView];
    //
    //    // Gender Label
    //    CGFloat genderButtonHeight=100;
    //    CGRect genderFrame=CGRectMake(0, verticalDisplacementAgeLabel+ageFrameHeight+betweenDisplacement, self.view.frame.size.width, genderButtonHeight);
    ////        CGRect genderFrame=CGRectMake(0, 0, 200, 200);
    //    UIButton * genderButton=[[UIButton alloc] initWithFrame:genderFrame];
    ////    [genderButton setTextColor:textColor];
    //    [genderButton setBackgroundColor:[UIColor redColor]];
    //    [genderButton setTitle:@"Gender" forState:UIControlStateNormal];
    //    [self.view addSubview:genderButton];
    ////    [genderButton setBackgroundColor:backgroundColor];
    ////    [gender0Button setFont:[UIFont fontWithName:@"Helvetica-Light" size:30.0f]];
    ////    [self.view addSubview:genderButton];
    //    [genderButton addTarget:self action:@selector(showGenders:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIView * secondBorderView=[[UIView alloc] init];
    //    CGRect secondBorderViewFrame=CGRectMake(0, verticalDisplacementAgeLabel+ageFrameHeight+genderButtonHeight+betweenDisplacement, self.view.frame.size.width, betweenDisplacement);
    //    [secondBorderView setFrame:secondBorderViewFrame];
    //    [secondBorderView setBackgroundColor:borderViewsColor];
    //    [secondBorderView setBackgroundColor:[UIColor grayColor]];
    ////    [self.view addSubview:secondBorderView];
    //
    //
    ////    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGenders)];
    ////    tapGestureRecognizer.numberOfTapsRequired = 1;
    ////    [genderButton addGestureRecognizer:tapGestureRecognizer];
    ////    [genderButton setTarget:self];
    ////    [genderButton setAction:@selector(showGenders:)];
    ////   genderButton.userInteractionEnabled = YES;
    //
    //    // Gender Label
    //    CGFloat genderInterestsLabelHeight=100;
    //    CGRect genderInterestsFrame=CGRectMake(0, verticalDisplacementAgeLabel+ageFrameHeight+betweenDisplacement+genderInterestsLabelHeight+betweenDisplacement, self.view.frame.size.width, genderInterestsLabelHeight);
    //    UIButton * genderInterestsLabel=[[UIButton alloc] initWithFrame:genderInterestsFrame];
    //    [genderInterestsLabel.titleLabel setText:@"  Gender Interests"];
    //    [genderInterestsLabel setTitleColor:textColor forState:UIControlStateNormal];
    //    self.genderInterestsLabel=genderInterestsLabel;
    //
    //    [genderInterestsLabel setBackgroundColor:backgroundColor];
    //    [genderInterestsLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:30.0f]];
    //    [self.view addSubview:genderInterestsLabel];
    //
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

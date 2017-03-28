//
//  AgeRangeCell.m
//  InterestMe
//
//  Created by Portanos on 5/29/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "AgeRangeCell.h"
#import <Parse/Parse.h>
#import "AgeCalcSuperclass.h"

@implementation AgeRangeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userAge=[AgeCalcSuperclass returnAgeUsingBirthDate:[PFUser currentUser][@"birthday"]];
    
    [self setUpSlider];
    
    //also got to add target method to slider
    
    [self.ageSlider addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void) buttonAction
{
    NSLog(@"buttonpressed");
    [self.delegateListener didPressButton:self];
}
/////////////////////////////////////////////////////////////////////
//These are called when the user changes the position of the slider.
-(NSInteger)returnUpperAgeForNewSliderPosition   {
    NSInteger numberOfYearsAvailable=self.maxAge-self.minAge;
    //this will get casted to NSInteger, which is what you want for an age.
    CGFloat upperPiece=self.ageSlider.upperValue*numberOfYearsAvailable;
    return self.minAge+[self roundFloat:upperPiece];
}
- (IBAction)sliderChanged:(NMRangeSlider *)sender {
    // actually we're going to use delegates
}

-(NSInteger)returnLowerAgeForNewSliderPosition   {
    NSInteger numberOfYearsAvailable=self.maxAge-self.minAge;
    //this will get casted to NSInteger, which is what you want for an age.
    CGFloat upperPiece=self.ageSlider.lowerValue*numberOfYearsAvailable;
    NSInteger lowerValue=self.minAge+[self roundFloat:upperPiece];
    NSLog(@"lower value in Return: %ld",lowerValue);
    return self.minAge+[self roundFloat:upperPiece];
}

//theres a bug in the age range, can't quite find out where at the moment, but move it above your age and below the next one, and youll see the bug when you restart it'

-(CGFloat) roundFloat:(CGFloat )aFloat
{
    return (int)(aFloat + 0.5);
}


/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
-(void)setUpSlider  {
    //sets up slider based on user's age etc.
    
    [self.ageSlider setBackgroundColor:[UIColor whiteColor]];
    
    NSInteger grownUpAgeSearchRange=25; //25 above or below my current age, on the requirement that I can't talk to lower than 18
    
    //also note, no one under 13 can have a Facebook and therefore we don't have to worry about them being on the platform (unless Facebook changes that policy).
    
    NSInteger minYearsRange=4;
    
    if (self.userAge<18) {
        
        //show them 13-17
        self.minAge=13;
        self.maxAge=17;
        self.ageSlider.lowerValue = 0.0;
        self.ageSlider.upperValue = 1.0; //they can see all ages 13 to 17, that makes sense for a starter range. Could be optimized later.

        
    } else if ((self.userAge-grownUpAgeSearchRange)<18) { //no people above 18 talking to people below 18
        
        self.minAge=18;
        self.maxAge=self.userAge+grownUpAgeSearchRange;
       
        NSInteger numberOfYearsAvailable=self.maxAge-self.minAge;
        
        CGFloat unitDistance=1.0/numberOfYearsAvailable;
        
        CGFloat myAgePos=(self.userAge-self.minAge)*unitDistance;
        
        if ((self.userAge-minYearsRange)<=18)    {
            
            self.ageSlider.lowerValue = 0.0;

        } else{
            self.ageSlider.lowerValue = myAgePos-minYearsRange*unitDistance;
        }
        
        self.ageSlider.upperValue = myAgePos+minYearsRange*unitDistance;
        
    } else{
        self.minAge=self.userAge-grownUpAgeSearchRange;
        self.maxAge=self.userAge+grownUpAgeSearchRange;
        
        NSInteger numberOfYearsAvailable=self.maxAge-self.minAge;
        CGFloat unitDistance=1.0/numberOfYearsAvailable;
        
        CGFloat myAgePos=(self.userAge-self.minAge)*unitDistance;
        
        self.ageSlider.lowerValue = myAgePos-minYearsRange*unitDistance;
        self.ageSlider.upperValue = myAgePos+minYearsRange*unitDistance;
    }
    
    NSInteger numberOfYearsAvailable=self.maxAge-self.minAge;
    CGFloat unitDistance=1.0/numberOfYearsAvailable;
    self.ageSlider.minimumRange=unitDistance*minYearsRange;
    
    self.ageSlider.stepValue=unitDistance; //So it snaps to nearest age.
    self.ageSlider.stepValueContinuously=NO;
    
    if (self.userAge<18)    {
        self.ageSlider.minimumRange=unitDistance*(minYearsRange-1);
    }
    
    /////////////////////////////////////////////////////////////////////////////// SERVER AGE PREFS /////////////////////////////
    // This code in the AgeRangeCell so far calculates the appropriate age range, without checking against server-saved age prefs.
    // But there's also a chance that the PFUser currentUser already has a couple of age prefs. So let's add this:
//    NSLog(@"minAge: %ld",self.minAge);
//    NSLog(@"maxAge: %ld",self.maxAge);

    
    NSInteger lowerAgeLim=[self roundNSNumber:[PFUser currentUser][@"lowerAgeLimit"] ];
    NSInteger upperAgeLim=[self roundNSNumber:[PFUser currentUser][@"upperAgeLimit"] ];

    
    // Make sure first they haven't aged out of saved age range...
    if (lowerAgeLim>=self.minAge && upperAgeLim<=self.maxAge)   {
        
        //If you request to put the lower slider beyond the upper slider, it'll silently ignore your request. That is an annoying implementation by the programmer-ideally they would have had it throw an exception, or at least console a warning!! This is the problem when you fork things. You save time but you run into stuff like this. Not really a huge hassle and can be handled.
        self.ageSlider.upperValue=1;
        
        
        

            NSLog(@"%@",[PFUser currentUser][@"lowerAgeLimit"]);
            CGFloat lowerValForSlider=(lowerAgeLim-self.minAge)*unitDistance;
            NSLog(@"lowerSliderValCalculated: %f",lowerValForSlider);
            
            self.ageSlider.lowerValue =(lowerAgeLim-self.minAge)*unitDistance;

            self.ageSlider.upperValue =(upperAgeLim-self.minAge)*unitDistance;
            

    }
}

-(NSInteger)roundNSNumber:(NSNumber *)numberToRound   {
    CGFloat floatVal=[numberToRound floatValue];
    return [self roundFloat:floatVal];
}

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  AgeRangeCell.h
//  InterestMe
//
//  Created by Portanos on 5/29/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"

@class AgeRangeCell;
@protocol MyTableCellProtocoll <NSObject>

-(void) didPressButton:(AgeRangeCell *)theCell;

@end

@interface AgeRangeCell : UITableViewCell
{
    
    UIButton *myButton;
    
    id<MyTableCellProtocoll> delegateListener;
    
}

@property (nonatomic,assign) id<MyTableCellProtocoll> delegateListener;


@property (weak, nonatomic) IBOutlet UISlider *bottomSlider;
@property (weak, nonatomic) IBOutlet UISlider *topSlider;
@property (weak, nonatomic) IBOutlet NMRangeSlider *ageSlider;
@property (weak, nonatomic) IBOutlet UILabel *ageRangeLabel;

//Methods other interfaces pull from
-(NSInteger)returnUpperAgeForNewSliderPosition   ;
-(NSInteger)returnLowerAgeForNewSliderPosition  ;

//This is what you want to edit from the other interfaces. The cell will logic behind age range etc.
@property NSInteger userAge;

//not to be edited outside of cell.
@property NSInteger minAge;
@property NSInteger maxAge;

@end

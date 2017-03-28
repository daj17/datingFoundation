//
//  DiscoveryPrefsCell.h
//  Written May 2016 DJAX

// This cell changes the search radius the program pulls people from.

#import <UIKit/UIKit.h>

@class DiscoveryPrefsCell;
@protocol DiscoveryRadiusProtocol <NSObject>

-(void) didChangeDiscoveryPrefs:(DiscoveryPrefsCell *)theCell;

@end

@interface DiscoveryPrefsCell : UITableViewCell
{
    UIButton *myButton;
    id<DiscoveryRadiusProtocol> delegateListener;
}

@property (nonatomic,assign) id<DiscoveryRadiusProtocol> delegateListener;

// Properties for varying search radius
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void)configureCell;

-(NSNumber *)returnSearchRadiusAsNSNumber; //For talking to cell

-(void)attemptSearchRadiusPresetWithValue:(NSNumber *)attemptNSNumber;

@end

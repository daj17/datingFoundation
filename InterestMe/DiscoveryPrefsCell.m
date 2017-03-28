//
//  DiscoveryPrefsCell.m

#import "DiscoveryPrefsCell.h"
#import "DeafultSettinsViewController.h"

#define MIN_DISCOVERY_DISTANCE 1
#define MAX_DISCOVERY_DISTANCE 100

@implementation DiscoveryPrefsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.radiusSlider addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)configureCell    {
    CGFloat currentSliderValue=self.radiusSlider.value;
    NSMutableString * radiusString=[[NSMutableString alloc] init];
    CGFloat upperPiece=(MAX_DISCOVERY_DISTANCE-MIN_DISCOVERY_DISTANCE)*currentSliderValue ;
    CGFloat upperVal=[self roundFloat:upperPiece];
    NSInteger currentSearchRadius=MIN_DISCOVERY_DISTANCE+upperVal;
    [radiusString appendString:[NSString stringWithFormat:@"%ld",currentSearchRadius]];
    [radiusString appendString:@"mi."];
    self.resultLabel.text=radiusString;
}

- (void) buttonAction
{
    [self.delegateListener didChangeDiscoveryPrefs:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

// For asking cell for its attributes:
-(NSNumber *)returnSearchRadiusAsNSNumber   {
    CGFloat currentSliderValue=self.radiusSlider.value;
    CGFloat upperPiece=(MAX_DISCOVERY_DISTANCE-MIN_DISCOVERY_DISTANCE)*currentSliderValue;
     NSInteger currentSearchRadius=MIN_DISCOVERY_DISTANCE+[self roundFloat:upperPiece];
    return [NSNumber numberWithInteger:currentSearchRadius];
}

-(CGFloat) roundFloat:(CGFloat )aFloat
{
    return (int)(aFloat + 0.5);
}

// Dealing with searchradius saved to user
-(void)attemptSearchRadiusPresetWithValue:(NSNumber *)attemptNSNumber   { // If max_radius or min_radius options have
    CGFloat roundedFloat=[self roundFloat:[attemptNSNumber floatValue]];
    //changed since then, then we don't want to "force a value" that isn't in our range.
    CGFloat attemptValFloat=(roundedFloat-MIN_DISCOVERY_DISTANCE)/(MAX_DISCOVERY_DISTANCE-MIN_DISCOVERY_DISTANCE);
    if (attemptValFloat>=0 && attemptValFloat<=1) {
        self.radiusSlider.value=attemptValFloat;
    }
}

@end

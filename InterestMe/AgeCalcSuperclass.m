//
//  AgeCalcSuperclass.m
//  InterestMe
//
//forked: http://www.geekslivelonger.com/calculate-age-from-date-of-birth/

#import "AgeCalcSuperclass.h"

@interface AgeCalcSuperclass ()

@end

@implementation AgeCalcSuperclass

+(NSInteger)returnAgeUsingBirthDate:(NSDate *)dateOfBirth {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day])))
    {
        return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
        
    } else {
        
        return [dateComponentsNow year] - [dateComponentsBirth year];
    }
}



@end

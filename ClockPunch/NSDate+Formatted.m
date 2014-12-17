//
//  NSDate+Formatted.m
//  ClockPunch
//
//  Created by Aldo Castro on 17/12/14.
//  Copyright (c) 2014 Aldo Castro. All rights reserved.
//

#import "NSDate+Formatted.h"

@implementation NSDate (Formatted)
+ (NSString *)formattedTimestamp:(NSDate *)timestamp withFormatString:(NSString *)formatStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatStr];
    NSString *formattedTimestamp = [formatter stringFromDate:timestamp];
    return formattedTimestamp;
}
@end

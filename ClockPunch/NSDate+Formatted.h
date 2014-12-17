//
//  NSDate+Formatted.h
//  ClockPunch
//
//  Created by Aldo Castro on 17/12/14.
//  Copyright (c) 2014 Aldo Castro. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kHourFormattedString = @"HH:mm";
static NSString * const kDateFormattedString = @"EEE dd-MM-yyy";

@interface NSDate (Formatted)
+ (NSString *)formattedTimestamp:(NSDate *)timestamp withFormatString:(NSString *)formatStr;
@end

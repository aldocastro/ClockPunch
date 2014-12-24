//
//  Punch.m
//  ClockPunch
//
//  Created by Castro Gonzales Aldo Oriel on 24/12/14.
//  Copyright (c) 2014 Aldo Castro. All rights reserved.
//

#import "Punch.h"


@implementation Punch

@dynamic clockIn;
@dynamic clockOut;
@dynamic date;
@dynamic place;

- (BOOL)shouldCheckout {
    return self.clockIn && !self.clockOut;
}
@end

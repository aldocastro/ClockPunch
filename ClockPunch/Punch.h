//
//  Punch.h
//  ClockPunch
//
//  Created by Castro Gonzales Aldo Oriel on 24/12/14.
//  Copyright (c) 2014 Aldo Castro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Punch : NSManagedObject

@property (nonatomic, retain) NSDate * clockIn;
@property (nonatomic, retain) NSDate * clockOut;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * place;

- (BOOL)shouldCheckout;

@end

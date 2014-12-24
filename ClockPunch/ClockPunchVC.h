//
//  MasterViewController.h
//  ClockPunch
//
//  Created by Aldo Castro on 10/12/14.
//  Copyright (c) 2014 Aldo Castro. All rights reserved.
//

@import UIKit;
@import CoreLocation;
@import CoreData;

@interface ClockPunchVC : UITableViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *clockPunches;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIBarButtonItem *addButton; //    TEST purposes
@property (nonatomic, strong) NSManagedObjectContext *managedObject;
@end

@interface ClockPunchCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *placeName, *clockIn, *clockOut;
@end

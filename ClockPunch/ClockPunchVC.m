//
//  MasterViewController.m
//  ClockPunch
//
//  Created by Aldo Castro on 10/12/14.
//  Copyright (c) 2014 Aldo Castro. All rights reserved.
//

#import "ClockPunchVC.h"
#import "NSDate+Formatted.h"
#import "Punch.h"

@import AddressBookUI;

static NSString * const CellIdentifier = @"Cell";
static NSString * const kLocationRegionIdentifier = @"Unterföhring";
#define kRegionCoordinates CLLocationCoordinate2DMake(48.190729, 11.652848)    // wk

@implementation ClockPunchCell @end

@implementation ClockPunchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestLocationPermissions];
    [self fetchData];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(plusButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isEditing {
    if (![self.tableView isEditing]) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.addButton;
    }
    return [self.tableView isEditing];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.clockPunches ? self.clockPunches.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClockPunchCell *cell = (ClockPunchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Punch *clockPunch = self.clockPunches[indexPath.row];
    cell.placeName.text = clockPunch.place;
    cell.clockIn.text = [NSDate formattedTimestamp:clockPunch.clockIn withFormatString:kHourFormattedString];
    cell.clockOut.text = [NSDate formattedTimestamp:clockPunch.clockOut withFormatString:kHourFormattedString];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Punch *_clockPunch = (Punch *)[self.clockPunches firstObject];
    NSString *headerTitle = [NSDate formattedTimestamp:_clockPunch.date withFormatString:kDateFormattedString];
    return headerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self deleteClockPunchAtIndex:indexPath.row]) {
            [tableView beginUpdates];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [tableView endUpdates];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        //  open settings
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"kReqstLocServcsAlertTitle", nil)
                                                                                 message:NSLocalizedString(@"kReqstLocServcsAlertMessage", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"kReqstLocServcsAlertOkBtn", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"kReqstLocServcsAlertCancelBtn", nil) style:UIAlertActionStyleDefault handler:NULL]];
        [self presentViewController:alertController animated:YES completion:NULL];
    } else {
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:kRegionCoordinates
                                                                     radius:500
                                                                 identifier:kLocationRegionIdentifier];
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        [self.locationManager startMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"failed with error: %@", error.debugDescription);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self updateViewWithLocation:locations[0]];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self insertGeocodedLocation:manager.location];
    [self showLocalNotificationWithMessage:NSLocalizedString(@"kArrivingNow", nil)];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self insertCheckoutAtObject:self.clockPunches[0]];
    [self showLocalNotificationWithMessage:NSLocalizedString(@"kLeavingNow", nil)];
}

#pragma mark - Helpers

- (void)updateViewWithLocation:(CLLocation *)location {
    Punch *_clockPunch = (Punch *)[self.clockPunches firstObject];
    if (_clockPunch && [_clockPunch shouldCheckout]) {
        [self insertCheckoutAtObject:self.clockPunches[0]];
    } else {
        [self insertGeocodedLocation:location];
    }
}

- (void)fetchData {
    if (!self.clockPunches) {
        self.clockPunches = [[NSMutableArray alloc] init];
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Punch"];
    request.predicate = [NSPredicate predicateWithFormat:@"place != nil"];
    NSError *error = nil;
    NSArray *results = [self.managedObject executeFetchRequest:request error:&error];
    if (results && results.count > 0) {
        self.clockPunches = [NSMutableArray arrayWithArray:results];
    }
}

- (void)insertNewObjectWithAddress:(NSString *)address {
    if (!self.clockPunches) {
        self.clockPunches = [[NSMutableArray alloc] init];
    }
    NSDate *nowDate = [NSDate date];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Punch" inManagedObjectContext:self.managedObject];
    Punch *_clockPunch = [[Punch alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObject];
    _clockPunch.place = address;
    _clockPunch.clockIn = nowDate;
    _clockPunch.clockOut = nil;
    _clockPunch.date = nowDate;
    
    NSError *error = nil;
    if (![self.managedObject save:&error]) {
        NSLog(@"Error: %@, %@", error, error.userInfo);
    } else {
        [self.clockPunches insertObject:_clockPunch atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (void)insertCheckoutAtObject:(Punch *)_clockPunch {
    _clockPunch.clockOut = [NSDate date];
    NSError *error = nil;
    if (![self.managedObject save:&error]) {
        NSLog(@"Error: %@, %@", error, error.userInfo);
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)insertGeocodedLocation:(CLLocation *)location {
    if (location) {
        //  geocode location and insert object in array
        [[CLGeocoder new] reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
            if (!error && [placemarks count] > 0) {
                [self insertNewObjectWithAddress:ABCreateStringWithAddressDictionary(((CLPlacemark *)placemarks[0]).addressDictionary, YES)];
            } else {
                NSString *address = [NSString stringWithFormat:@"Latitude: %f\nLongitude:%f",location.coordinate.latitude, location.coordinate.longitude];
                [self insertNewObjectWithAddress:address];
                NSLog(@"decoding string failure: %@", error.debugDescription);
            }
        }];
    }
}

- (BOOL)deleteClockPunchAtIndex:(NSUInteger)index {
    BOOL deleteSucceed = NO;
    Punch *_clockPunch = (Punch *)self.clockPunches[index];
    [self.managedObject deleteObject:_clockPunch];
    NSError *error = nil;
    if (![self.managedObject save:&error]) {
        NSLog(@"Error: %@, %@", error, error.userInfo);
    } else {
        deleteSucceed = YES;
        [self.clockPunches removeObjectAtIndex:index];
    }
    return deleteSucceed;
}

- (void)requestLocationPermissions {
    if (![CLLocationManager locationServicesEnabled]) return;
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
}

- (IBAction)plusButtonPressed:(id)sender {
    [self updateViewWithLocation:self.locationManager.location];
}

- (void)showLocalNotificationWithMessage:(NSString *)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = @"Ok";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end

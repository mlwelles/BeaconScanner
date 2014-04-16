//
//  HGBeaconController.h
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 4/9/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGBeaconViewController : NSViewController
@property(nonatomic,strong) NSMutableArray *beacons;
@property (nonatomic, strong) NSArray *beaconSortDescriptors;
@property(nonatomic,weak) IBOutlet NSButton *scanToggleButton;
@property(nonatomic,weak) IBOutlet NSTextField *scannerStatusTextField;
@property(nonatomic,weak) IBOutlet NSTextField *bluetoothStatusTextField;
@property(nonatomic, weak) IBOutlet NSTableView *tableView;
@end

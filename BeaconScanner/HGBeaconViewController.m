//
//  HGBeaconController.m
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 4/9/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//
#import "HGBeaconViewController.h"
#import "HGBeaconScanner.h"
#import "HGBeacon.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import <BlocksKit/BlocksKit.h>
#import <libextobjc/EXTScope.h>
#import "HGBeaconHistory.h"
#import "HGBluetoothState.h"
#define HGBeaconTimeToLiveInterval 15
@interface HGBeaconViewController()
@property (strong) RACSignal *housekeepingSignal;
@property (strong) HGBeaconHistory *beaconHistory;
@property (strong) HGBeacon *lastSelectedBeacon;
@property BOOL isRecording;
@end
@implementation HGBeaconViewController



- (void) awakeFromNib {
    [self.tableView setAllowsEmptySelection:YES];
    [self.tableView setAllowsColumnSelection:NO];
}

- (id)init {
    self = [super init];
    if (self) {
        self.beacons = [NSMutableArray array];
        RACSignal *beaconSignal = [[HGBeaconScanner sharedBeaconScanner] beaconSignal];
        _beaconHistory = [[HGBeaconHistory alloc] initWithBeaconSignal:beaconSignal];
        @weakify(self)
        // Subscribe to beacons detected by the manager, modify beacon list that is bound to the table view array
        [[beaconSignal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(HGBeacon *beacon) {
            @strongify(self)
            BOOL shouldReselect  = (self.tableView.selectedRow >= 0);
            NSUInteger existingBeaconIndex = [self rowForBeacon:beacon];
            if (existingBeaconIndex != NSNotFound) {
                HGBeacon *existingBeacon = [self.beacons objectAtIndex:existingBeaconIndex];
                [self removeObjectFromBeaconsAtIndex:existingBeaconIndex];
                existingBeacon.measuredPower = beacon.measuredPower;
                existingBeacon.RSSI = beacon.RSSI;
                existingBeacon.lastUpdated = beacon.lastUpdated;
                [self insertObject:existingBeacon inBeaconsAtIndex:existingBeaconIndex];
            } else {
                [self addBeaconsObject:beacon];
            }
            if (shouldReselect) {
                [self selectRowForBeacon:self.lastSelectedBeacon];
            }

        }];
        
        // Setup a interval signal that will purge expired beacons (determined by a last update longer than HGBeaconTimeToLiveInterval) from the displayed list
        self.housekeepingSignal = [RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
        [self.housekeepingSignal subscribeNext:^(NSDate *now) {
            @strongify(self);
            if ([[HGBeaconScanner sharedBeaconScanner] scanning]) {
                BOOL shouldReselect  = (self.tableView.selectedRow >= 0);
                BOOL didChange = NO;
                NSArray *beaconsCopy = [NSArray arrayWithArray:self.beacons];
                for (HGBeacon *candidateBeacon in beaconsCopy) {
                    NSTimeInterval age = [now timeIntervalSinceDate:candidateBeacon.lastUpdated];
                    if (age > HGBeaconTimeToLiveInterval) {
                        NSUInteger index = 0;
                        for (HGBeacon *beacon in self.beacons) {
                            NSLog(@"is recording: %@", (self.isRecording ? @"true" : @"false"));
                            if ([beacon isEqualToBeacon:candidateBeacon] && ! self.isRecording) {
                               [self removeObjectFromBeaconsAtIndex:index];
                                didChange = YES;
                                break;
                            }
                            index++;
                        }
                    }
                }
                if (didChange && shouldReselect) {
                    [self selectRowForBeacon:self.lastSelectedBeacon];
                }
                if ([self.scannerStatusTextField.stringValue isEqualToString:@"Scanning..."]) {
                    self.scannerStatusTextField.stringValue = @"Scanning....";
                } else {
                    self.scannerStatusTextField.stringValue = @"Scanning...";
                    
                }
            }
        }];
        
        
        // Subscribe to bluetooth state change signals from the beacon scanner
        [[[[HGBeaconScanner sharedBeaconScanner] bluetoothStateSignal] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *const bluetoothState) {
            @strongify(self)
            self.bluetoothStatusTextField.stringValue = HGBluetoothStateDescription(bluetoothState);
            [self.scanToggleButton setEnabled:(bluetoothState == HGGBluetoothStatePoweredOn)];
            
        }];
        
        // Sort descriptors to use, bound in MainMenu.xib to the array controller for the table view and the table view
        self.beaconSortDescriptors = @[
                                       [[NSSortDescriptor alloc] initWithKey:@"proximityUUID.UUIDString" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"major" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"minor" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"RSSI" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"lastUpdated" ascending:NO]
                                       ];
        
        

        [[RACObserve(self, recordCheckboxButton) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSButton *button) {
            button.state = (self.isRecording ? NSOffState : NSOnState);
            @strongify(self)
            button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSButton *button) {
                @strongify(self)
                self.isRecording = !(button.state == NSOnState);
                return [RACSignal empty];
            }];
        }];
     
        
        // When IB binds the scanToggleButton, set it to toggle the scanning state in the beacon manager on press
        [[RACObserve(self, scanToggleButton) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSButton *button) {
            @strongify(self)
            if ([[HGBeaconScanner sharedBeaconScanner] bluetoothState] != HGGBluetoothStatePoweredOn ) {
                self.scannerStatusTextField.stringValue = @"Not scanning";
                button.title = @"Start Scanning";
                [button setEnabled:NO];
            }
            
            button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSButton *button) {
                if ([[HGBeaconScanner sharedBeaconScanner] scanning]) {
                    [[HGBeaconScanner sharedBeaconScanner] stopScanning];
                } else {
                    [[HGBeaconScanner sharedBeaconScanner] startScanning];
                }
                return [RACSignal empty];
            }];
        }];
        
        
        // When scanning state in the beacon manager changes, change UI to show new state
        [[RACObserve(HGBeaconScanner.sharedBeaconScanner, scanning) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *isScanningNumber) {
            @strongify(self)
            if ([isScanningNumber boolValue]) {
                self.scanToggleButton.title = @"Stop";
                self.scannerStatusTextField.stringValue = @"Scanning...";
            } else {
                self.scanToggleButton.title = @"Start Scanning";
                self.scannerStatusTextField.stringValue = @"Not scanning";
            }
        }];
        
        [[HGBeaconScanner sharedBeaconScanner] startScanning];
    }

    return self;
}

-(void)selectRowForBeacon:(HGBeacon *)beaconToSelect{
    //If we had a row selected, re-select it
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger selectedRow = [self rowForBeacon:beaconToSelect];
        if ( selectedRow != NSNotFound ) {
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:selectedRow];
            [self.tableView selectRowIndexes:indexSet byExtendingSelection:false];
        }
    });
    
}
-(NSInteger)rowForBeacon:(HGBeacon *)beacon {
    return [self.arrayController.arrangedObjects indexOfObjectPassingTest:^BOOL(HGBeacon *otherBeacon, NSUInteger idx, BOOL *stop) {
        return [beacon isEqualToBeacon:otherBeacon];
    }];

}
-(HGBeacon *)beaconForRow:(NSInteger) row {
    HGBeacon *beacon = nil;
    if ( row >= 0 &&
        row < [self.arrayController.arrangedObjects count]) {
        beacon = (HGBeacon *)self.arrayController.arrangedObjects[row];
    }
    return beacon;
}

#pragma mark - NSTableView delegate 
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = (NSTableView *)[notification object];
    HGBeacon *newBeacon = [self beaconForRow:tableView.selectedRow];
    if (newBeacon) {
        self.lastSelectedBeacon = newBeacon;
    }
}


- (void)tableView:(NSTableView *)tableView
didClickTableColumn:(NSTableColumn *)tableColumn {
    if (self.tableView.selectedRow == -1) {
        self.lastSelectedBeacon = nil;
    } else {
        [self selectRowForBeacon:self.lastSelectedBeacon];
    }
}


#pragma mark - NSWindowController delegate
- (IBAction) copy:(id)sender
{
    HGBeacon *beacon = self.lastSelectedBeacon;
    if (!beacon) {
        return;
    }
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[NSStringPboardType]
               owner:nil];
    [pasteboard setString:beacon.proximityUUID.UUIDString forType:NSStringPboardType];
}

#pragma mark - KVO Compliance for beacons
-(void)insertObject:(HGBeacon *)object inBeaconsAtIndex:(NSUInteger)index {
    [self.beacons insertObject:object atIndex:index];
}

-(void)removeObjectFromBeaconsAtIndex:(NSUInteger)index {
    [self.beacons removeObjectAtIndex:index];
}


-(void)addBeaconsObject:(HGBeacon *)beacon {
    [self insertObject:beacon inBeaconsAtIndex:[self.beacons count]];
}
@end

//
//  HGBeaconController.m
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 4/9/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import "HGBeaconViewController.h"
#import "HGBeaconManager.h"
#import "HGBeacon.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "BlocksKit.h"
#import "EXTScope.h"
#define HGBeaconTimeToLiveInterval 15
@interface HGBeaconViewController()
@property (strong) RACSignal *housekeepingSignal;
@end
@implementation HGBeaconViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.beacons = [NSMutableArray array];

        @weakify(self)

        // Subscribe to beacons detected by the manager, modify beacon list that is bound to the table view array controller
        [[[[HGBeaconManager sharedBeaconManager] beaconSignal] deliverOn:[RACScheduler mainThreadScheduler] ] subscribeNext:^(HGBeacon *beacon) {
            @strongify(self)
            NSUInteger existingBeaconIndex = [self.beacons indexOfObjectPassingTest:^BOOL(HGBeacon *otherBeacon, NSUInteger idx, BOOL *stop) {
                return [beacon isEqualToBeacon:otherBeacon];
            }];
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
        }];
        
        // Setup a interval signal that will purge expired beacons (determined by a last update longer than HGBeaconTimeToLiveInterval) from the displayed list
        self.housekeepingSignal = [RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]];
        [self.housekeepingSignal subscribeNext:^(NSDate *now) {
            @strongify(self);
            NSArray *beaconsCopy = [NSArray arrayWithArray:self.beacons];
            for (HGBeacon *candidateBeacon in beaconsCopy) {
                NSTimeInterval age = [now timeIntervalSinceDate:candidateBeacon.lastUpdated];
                if (age > HGBeaconTimeToLiveInterval) {
                    NSUInteger index = 0;
                    for (HGBeacon *beacon in self.beacons) {
                        if ([beacon isEqualToBeacon:candidateBeacon]) {
                            [self removeObjectFromBeaconsAtIndex:index];
                            break;
                        }
                        index++;
                    }
                }
            }
            if ([[HGBeaconManager sharedBeaconManager] scanning]) {
                if ([self.statusTextField.stringValue isEqualToString:@"Scanning..."]) {
                      self.statusTextField.stringValue = @"Scanning....";
                } else {
                    self.statusTextField.stringValue = @"Scanning...";

                }
            }
        }];
        // Sort descriptors to use, bound in MainMenu.xib to the array controller for the table view and the table view
        self.beaconSortDescriptors = @[
                                       [[NSSortDescriptor alloc] initWithKey:@"proximityUUID.UUIDString" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"major" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"minor" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"RSSI" ascending:NO],
                                       [[NSSortDescriptor alloc] initWithKey:@"lastUpdated" ascending:NO]
                                       ];
        
        
        // When IB binds the scanToggleButton, set it to toggle the scanning state in the beacon manager on press
        [RACObserve(self, scanToggleButton) subscribeNext:^(NSButton *button) {
            button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSButton *button) {
                if ([[HGBeaconManager sharedBeaconManager] scanning]) {
                    [[HGBeaconManager sharedBeaconManager] stopScanning];
                } else {
                    [[HGBeaconManager sharedBeaconManager] startScanning];
                }
                return [RACSignal empty];
            }];
        }];
        
        

        // When scanning state in the beacon manager changes, change UI to show new state
        [[RACObserve(HGBeaconManager.sharedBeaconManager, scanning) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *isScanningNumber) {
            @strongify(self)
            if ([isScanningNumber boolValue]) {
                self.scanToggleButton.title = @"Stop";
                self.statusTextField.stringValue = @"Scanning...";
            } else {
                self.scanToggleButton.title = @"Start Scanning";
                self.statusTextField.stringValue = @"Stopped";
            }
        }];
         
        [[HGBeaconManager sharedBeaconManager] startScanning];
    }
    return self;
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

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
        
        // Subscribe to bluetooth state change signals from the beacon scanner
        [[[[HGBeaconScanner sharedBeaconScanner] bluetoothStateSignal] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSString *const bluetoothState) {
            @strongify(self)
            self.bluetoothStatusTextField.stringValue = (^{
                if (bluetoothState == HGBeaconScannerBluetoothStateUnknown) {
                    return @"Blutooth state unknown.";
                } else if (bluetoothState == HGBeaconScannerBluetoothStateResetting) {
                    return @"Bluetooth is resetting.";
                } else if (bluetoothState == HGBeaconScannerBluetoothStateUnsupported) {
                    return @"Your hardware does not support Bluetooth Low Energy";
                } else if (bluetoothState == HGBeaconScannerBluetoothStateUnauthorized) {
                    return @"Application not authorized to use Bluetooth Low Energy";
                } else if (bluetoothState == HGBeaconScannerBluetoothStatePoweredOff) {
                    return @"Bluetooth is powered off";
                } else if (bluetoothState == HGBeaconScannerBluetoothStatePoweredOn) {
                    return @"Bluetooth is on and available";
                } else {
                    return @"Bluetooth state unknown";
                }
            }());
            
            [self.scanToggleButton setEnabled:(bluetoothState == HGBeaconScannerBluetoothStatePoweredOn)];
            
        }];
        // Subscribe to beacons detected by the manager, modify beacon list that is bound to the table view array controller
        [[[[HGBeaconScanner sharedBeaconScanner] beaconSignal] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(HGBeacon *beacon) {
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
            if ([[HGBeaconScanner sharedBeaconScanner] scanning]) {
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
                if ([self.scannerStatusTextField.stringValue isEqualToString:@"Scanning..."]) {
                    self.scannerStatusTextField.stringValue = @"Scanning....";
                } else {
                    self.scannerStatusTextField.stringValue = @"Scanning...";
                    
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
        [[RACObserve(self, scanToggleButton) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSButton *button) {
            @strongify(self)
            if ([[HGBeaconScanner sharedBeaconScanner] bluetoothState] != HGBeaconScannerBluetoothStatePoweredOn ) {
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

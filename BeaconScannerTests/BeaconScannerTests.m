//
//  DesktopBeaconTests.m
//  DesktopBeaconTests
//
//  Created by HUGE | Mike Welles on 4/4/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HGBeaconScanner.h"
#import "HGBeacon.h"

@interface DesktopBeaconTests : XCTestCase

@end

@implementation DesktopBeaconTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testManagerScanningStart
{
    // Give Bluetooth time to initialize
    HGBeaconScanner *scanner = [HGBeaconScanner sharedBeaconScanner];

    // Brief wait for CBCentralManager to report state
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:2.0];
    while (scanner.bluetoothState == nil && [timeout timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    // Skip test if Bluetooth state isn't available or isn't powered on
    XCTSkipIf(scanner.bluetoothState == nil, @"Bluetooth state not available");
    XCTSkipIf(scanner.bluetoothState != HGGBluetoothStatePoweredOn, @"Bluetooth not powered on");

    [scanner startScanning];
    XCTAssertTrue(scanner.scanning, @"Manager can start scanning");
}

- (void)testManagerScanningStop
{
    [[HGBeaconScanner sharedBeaconScanner] stopScanning];
    XCTAssertFalse([[HGBeaconScanner sharedBeaconScanner] scanning], @"Manager can stop scanning");
}

@end

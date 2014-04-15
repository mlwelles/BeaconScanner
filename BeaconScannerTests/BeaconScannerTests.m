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
    [[HGBeaconScanner sharedBeaconScanner] startScanning];
    XCTAssertTrue([[HGBeaconScanner sharedBeaconScanner] scanning], @"Manager can start scanning");
}

- (void)testManagerScanningStop
{
    [[HGBeaconScanner sharedBeaconScanner] stopScanning];
    XCTAssertFalse([[HGBeaconScanner sharedBeaconScanner] scanning], @"Manager can stop scanning");
}

@end

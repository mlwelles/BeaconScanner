//
//  DesktopBeaconTests.m
//  DesktopBeaconTests
//
//  Created by HUGE | Mike Welles on 4/4/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HGBeaconManager.h"
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
    [[HGBeaconManager sharedBeaconManager] startScanning];
    XCTAssertTrue([[HGBeaconManager sharedBeaconManager] scanning], @"Manager can start scanning");
}

- (void)testManagerScanningStop
{
    [[HGBeaconManager sharedBeaconManager] stopScanning];
    XCTAssertFalse([[HGBeaconManager sharedBeaconManager] scanning], @"Manager can stop scanning");
}

@end

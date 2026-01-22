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
#import <ReactiveCocoa/ReactiveCocoa.h>

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
    HGBeaconScanner *scanner = [HGBeaconScanner sharedBeaconScanner];

    // Use XCTestExpectation with the reactive signal for proper async handling
    XCTestExpectation *expectation = [self expectationWithDescription:@"Bluetooth state received"];
    __block NSString *receivedState = nil;

    // Subscribe to bluetooth state signal - RACReplaySubject will replay last value
    [[scanner.bluetoothStateSignal take:1] subscribeNext:^(NSString *state) {
        receivedState = state;
        [expectation fulfill];
    }];

    // Wait up to 10 seconds for Bluetooth to report state
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:10.0];

    // Skip if we didn't receive state in time
    XCTSkipIf(result != XCTWaiterResultCompleted, @"Bluetooth state not available (timeout)");
    XCTSkipIf(receivedState != HGGBluetoothStatePoweredOn, @"Bluetooth not powered on (state: %@)", receivedState);

    [scanner startScanning];
    XCTAssertTrue(scanner.scanning, @"Manager can start scanning");
}

- (void)testManagerScanningStop
{
    [[HGBeaconScanner sharedBeaconScanner] stopScanning];
    XCTAssertFalse([[HGBeaconScanner sharedBeaconScanner] scanning], @"Manager can stop scanning");
}

#pragma mark - Help Menu Tests

- (void)testHelpBookFolderConfigured
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *helpBookFolder = [bundle objectForInfoDictionaryKey:@"CFBundleHelpBookFolder"];
    XCTAssertNotNil(helpBookFolder, @"CFBundleHelpBookFolder should be configured in Info.plist");
    XCTAssertEqualObjects(helpBookFolder, @"BeaconScanner.help", @"Help book folder should be BeaconScanner.help");
}

- (void)testHelpBookNameConfigured
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *helpBookName = [bundle objectForInfoDictionaryKey:@"CFBundleHelpBookName"];
    XCTAssertNotNil(helpBookName, @"CFBundleHelpBookName should be configured in Info.plist");
    XCTAssertEqualObjects(helpBookName, @"nyc.welles.BeaconScanner.help", @"Help book name should match bundle identifier");
}

- (void)testHelpBundleExists
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *helpBookFolder = [bundle objectForInfoDictionaryKey:@"CFBundleHelpBookFolder"];
    XCTAssertNotNil(helpBookFolder, @"Help book folder must be configured");

    NSString *helpPath = [[bundle resourcePath] stringByAppendingPathComponent:helpBookFolder];
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:helpPath isDirectory:&isDirectory];

    XCTAssertTrue(exists, @"Help bundle should exist at %@", helpPath);
    XCTAssertTrue(isDirectory, @"Help bundle should be a directory");
}

- (void)testHelpIndexExists
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *helpBookFolder = [bundle objectForInfoDictionaryKey:@"CFBundleHelpBookFolder"];
    XCTAssertNotNil(helpBookFolder, @"Help book folder must be configured");

    NSString *helpPath = [[bundle resourcePath] stringByAppendingPathComponent:helpBookFolder];
    NSString *indexPath = [helpPath stringByAppendingPathComponent:@"Contents/Resources/en.lproj/index.html"];

    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:indexPath];
    XCTAssertTrue(exists, @"Help index.html should exist at %@", indexPath);
}

- (void)testHelpContentNotEmpty
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *helpBookFolder = [bundle objectForInfoDictionaryKey:@"CFBundleHelpBookFolder"];
    XCTAssertNotNil(helpBookFolder, @"Help book folder must be configured");

    NSString *helpPath = [[bundle resourcePath] stringByAppendingPathComponent:helpBookFolder];
    NSString *indexPath = [helpPath stringByAppendingPathComponent:@"Contents/Resources/en.lproj/index.html"];

    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:indexPath encoding:NSUTF8StringEncoding error:&error];

    XCTAssertNil(error, @"Should be able to read help content: %@", error);
    XCTAssertNotNil(content, @"Help content should not be nil");
    XCTAssertGreaterThan(content.length, 100, @"Help content should have substantial content");
    XCTAssertTrue([content containsString:@"BeaconScanner"], @"Help content should mention BeaconScanner");
    XCTAssertTrue([content containsString:@"iBeacon"], @"Help content should mention iBeacon");
}

@end

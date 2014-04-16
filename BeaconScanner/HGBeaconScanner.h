//
//  HGBeaconScanner.h
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ReactiveCocoa/ReactiveCocoa.h"

/**
 *  State unknown, update imminent.
 */
extern NSString *const HGBeaconScannerBluetoothStateUnknown;

/**
 *  The connection with the system service was momentarily lost, update imminent.
 */
extern NSString *const HGBeaconScannerBluetoothStateResetting;

/**
 *  The platform doesn't support Bluetooth Low Energy.
 */
extern NSString *const HGBeaconScannerBluetoothStateUnsupported;

/**
 *  The app is not authorized to use Bluetooth Low Energy.
 */
extern NSString *const HGBeaconScannerBluetoothStateUnauthorized;

/**
 *  Bluetooth is powered off
 */
extern NSString *const HGBeaconScannerBluetoothStatePoweredOff;

/**
 *  Bluetooth is currently powered on and available to use.
 */
extern NSString *const HGBeaconScannerBluetoothStatePoweredOn;


@interface HGBeaconScanner : NSObject
/**
 *  Signal that send an HGBeacon to subscribers every time a beacon is detected (or redetected)
 */
@property (nonatomic, readonly) RACSignal *beaconSignal;

/**
 *  Signal that will send one of the HGBeconScannerBluetoothState prefexed consts
 *  defined above when bluetooth state changes
 */
@property (nonatomic, readonly) RACSignal *bluetoothStateSignal;
/**
 *  Value will be one of the HGBeconScannerBluetoothState prefexed consts
 *  defined above when bluetooth state changes
 */
@property (nonatomic, readonly) NSString *const bluetoothState;

@property (nonatomic, readonly) BOOL scanning;
/**
 *  Starts scanning for beacons
 */
-(void)startScanning;
/**
 *  Stops scanning for beacons
 */
-(void)stopScanning;
-(NSNumber *)bluetoothLMPVersion;

+(HGBeaconScanner *)sharedBeaconScanner;
@end

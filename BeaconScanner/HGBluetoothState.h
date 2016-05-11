//
//  HGBluetoothState.h
//  BeaconScanner
//
//  Created by Mike Welles on 5/11/16.
//  Copyright © 2016 Huge, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const HGGBluetoothStateUnknown;
extern NSString *const HGGBluetoothStateResetting;
extern NSString *const HGGBluetoothStateUnsupported;
extern NSString *const HGGBluetoothStateUnauthorized;
extern NSString *const HGGBluetoothStatePoweredOff;
extern NSString *const HGGBluetoothStatePoweredOn;
NSString *HGBluetoothStateDescription(NSString *const bluetoothState);
//
//  HGBluetoothState.m
//  BeaconScanner
//
//  Created by Mike Welles on 5/11/16.
//  Copyright © 2016 Huge, Inc. All rights reserved.
//

#import "HGBluetoothState.h"
NSString *const HGGBluetoothStateUnknown = @"HGGBluetoothStateUnknown";
NSString *const HGGBluetoothStateResetting = @"HGGBluetoothStateResetting";
NSString *const HGGBluetoothStateUnsupported = @"HGGBluetoothStateUnsupported";
NSString *const HGGBluetoothStateUnauthorized = @"HGGBluetoothStateUnauthorized";
NSString *const HGGBluetoothStatePoweredOff = @" HGGBluetoothStatePoweredOff";
NSString *const HGGBluetoothStatePoweredOn = @"HGGBluetoothStatePoweredOn";
NSString *HGBluetoothStateDescription(NSString *const bluetoothState) {
    if (bluetoothState == HGGBluetoothStateUnknown) {
        return @"Blutooth state unknown.";
    } else if (bluetoothState == HGGBluetoothStateResetting) {
        return @"Bluetooth is resetting.";
    } else if (bluetoothState == HGGBluetoothStateUnsupported) {
        return @"Your hardware does not support Bluetooth Low Energy";
    } else if (bluetoothState == HGGBluetoothStateUnauthorized) {
        return @"Application not authorized to use Bluetooth Low Energy";
    } else if (bluetoothState == HGGBluetoothStatePoweredOff) {
        return @"Bluetooth is powered off";
    } else if (bluetoothState == HGGBluetoothStatePoweredOn) {
        return @"Bluetooth is on and available";
    } else {
        return @"Bluetooth state unknown";
    }
}

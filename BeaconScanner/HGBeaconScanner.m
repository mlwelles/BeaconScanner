//
//  BCBeaconScanner.m
//  Beecon
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//
#import "HGBeaconScanner.h"
#import <CoreLocation/CoreLocation.h>
#import <IOBluetooth/IOBluetooth.h>
#import "HGBeacon.h"
#import "libextobjc/EXTScope.h"
#import "BlocksKit.h"

NSString *const HGBeaconScannerBluetoothStateUnknown = @"HGBeaconScannerBluetoothStateUnknown";
NSString *const HGBeaconScannerBluetoothStateResetting = @"HGBeaconScannerBluetoothStateResetting";
NSString *const HGBeaconScannerBluetoothStateUnsupported = @"HGBeaconScannerBluetoothStateUnsupported";
NSString *const HGBeaconScannerBluetoothStateUnauthorized = @"HGBeaconScannerBluetoothStateUnauthorized";
NSString *const HGBeaconScannerBluetoothStatePoweredOff = @" HGBeaconScannerBluetoothStatePoweredOff";
NSString *const HGBeaconScannerBluetoothStatePoweredOn = @"HGBeaconScannerBluetoothStatePoweredOn";

@interface HGBeaconScanner () <CBPeripheralManagerDelegate, CLLocationManagerDelegate,CBCentralManagerDelegate>
@property (strong,nonatomic) CBCentralManager *centralManager;
@property (nonatomic, strong) dispatch_queue_t managerQueue;
@property (nonatomic, strong) RACSubject *beaconSignal;
@property (nonatomic, strong) RACSubject *bluetoothStateSignal;
@property (nonatomic, assign) NSString *const bluetoothState;
@property (nonatomic, strong) RACSignal*housekeepingIntervalSignal;
@property (nonatomic, assign) BOOL scanning;
@end
@implementation HGBeaconScanner
#pragma mark - beacon
-(id)init {
    self  = [super init];
    if (self) {
        
        self.managerQueue = dispatch_queue_create("com.huge.DesktopBeacon.centralManagerQueue", NULL);
        
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                   queue:self.managerQueue];
        
        self.beaconSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        self.bluetoothStateSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        
    }
    return self;
}

-(void)stopScanning {
    [self.centralManager stopScan];
    self.scanning = NO;
}

-(void)startScanning {
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    self.scanning = YES;
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"Peripheral manager did update state: %@", peripheral);
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *state = nil;
    switch (central.state) {
        case CBCentralManagerStateResetting:
            state = HGBeaconScannerBluetoothStateResetting;
            break;
        case CBCentralManagerStateUnsupported:
            state = HGBeaconScannerBluetoothStateUnsupported;
            break;
        case CBCentralManagerStateUnauthorized:
            state = HGBeaconScannerBluetoothStateUnauthorized;
            break;
        case CBCentralManagerStatePoweredOff:
            state = HGBeaconScannerBluetoothStatePoweredOff;
            break;
        case CBCentralManagerStatePoweredOn:
            state = HGBeaconScannerBluetoothStatePoweredOn;
            break;
        default:
            state = HGBeaconScannerBluetoothStateUnknown;
            break;
            
    }
    if (state != HGBeaconScannerBluetoothStatePoweredOn) {
        if (self.scanning) {
            [self stopScanning];
        }
    }
    self.bluetoothState = state;
    [(RACSubject *)self.bluetoothStateSignal sendNext:state];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    HGBeacon *beacon = [HGBeacon beaconWithAdvertismentDataDictionary:advertisementData];
    beacon.RSSI = RSSI;
    if (beacon) {
        [(RACSubject *)self.beaconSignal sendNext:beacon];
    }
}

+(HGBeaconScanner *)sharedBeaconScanner {
    static HGBeaconScanner *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HGBeaconScanner alloc] init];
    });
    return sharedManager;
}
@end

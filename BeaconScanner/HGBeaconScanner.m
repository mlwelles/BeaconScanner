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


@interface HGBeaconScanner () <CLLocationManagerDelegate,CBCentralManagerDelegate>
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
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
        self.scanning = YES;
    }

}


-(NSNumber *)bluetoothLMPVersion {
    static NSNumber *bluetoothLMPVersion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSPipe *outputPipe = [[NSPipe alloc] init];
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/bin/bash";
        task.arguments = @[ @"-c", @"system_profiler -detailLevel full SPBluetoothDataType | grep 'LMP Version:' | awk '{print $3}'"];
        task.standardOutput = outputPipe;
        [task launch];
        [task waitUntilExit];
        NSData *output = [[outputPipe fileHandleForReading] availableData];
        NSString *outputString = [[[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n"withString:@""];
        NSScanner *outputScanner = [NSScanner scannerWithString:outputString];
        unsigned int outputInt = 0;
        [outputScanner scanHexInt:&outputInt];
        bluetoothLMPVersion = [NSNumber numberWithUnsignedInteger:outputInt];
    });
    return bluetoothLMPVersion;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *state = nil;
    switch (central.state) {
        case CBCentralManagerStateResetting:
            state = HGGBluetoothStateResetting;
            break;
        case CBCentralManagerStateUnsupported:
            state = HGGBluetoothStateUnsupported;
            break;
        case CBCentralManagerStateUnauthorized:
            state = HGGBluetoothStateUnauthorized;
            break;
        case CBCentralManagerStatePoweredOff:
            //LMP version of 0x4 reports itself off, even though its' actually unsupported;
            if ([[self bluetoothLMPVersion] integerValue] < 6) {
                state = HGGBluetoothStateUnsupported;
            } else {
                state = HGGBluetoothStatePoweredOff;
            }
            break;
        case CBCentralManagerStatePoweredOn:
            state = HGGBluetoothStatePoweredOn;
            break;
        default:
            state = HGGBluetoothStateUnknown;
            break;
            
    }
    NSLog(@"CBluetooth central manager reported new state: %@", state);
    if (state != HGGBluetoothStatePoweredOn) {
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

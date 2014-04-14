//
//  BCBeaconManager.m
//  Beecon
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import "HGBeaconManager.h"
#import <CoreLocation/CoreLocation.h>
#import <IOBluetooth/IOBluetooth.h>
#import "HGBeacon.h"
#import "libextobjc/EXTScope.h"
#import "BlocksKit.h"
@interface HGBeaconManager () <CBPeripheralManagerDelegate, CLLocationManagerDelegate,CBCentralManagerDelegate>
@property (strong,nonatomic) CBCentralManager *centralManager;
@property (nonatomic, strong) dispatch_queue_t managerQueue;
@property (nonatomic, strong) RACSubject *beaconSignal;
@property (nonatomic, strong) RACSignal*housekeepingIntervalSignal;
@property (nonatomic, assign) BOOL scanning;
@end
@implementation HGBeaconManager
#pragma mark - beacon
-(id)init {
    self  = [super init];
    if (self) {

        self.managerQueue = dispatch_queue_create("com.huge.DesktopBeacon.centralManagerQueue", NULL);
     
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                   queue:self.managerQueue];

        self.beaconSignal = [RACReplaySubject replaySubjectWithCapacity:1];
        
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
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"centralManager did power on: %ld", central.state);
            break;
        default:
            NSLog(@"centralManager did update: %ld", central.state);
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    HGBeacon *beacon = [HGBeacon beaconWithAdvertismentDataDictionary:advertisementData];
    beacon.RSSI = RSSI;
    if (beacon) {
        [(RACSubject *)self.beaconSignal sendNext:[beacon copy]];
    }
}

+(HGBeaconManager *)sharedBeaconManager {
    static HGBeaconManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HGBeaconManager alloc] init];
    });
    return sharedManager;
}
@end

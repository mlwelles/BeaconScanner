//
//  HGBeaconManager.h
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
@interface HGBeaconManager : NSObject
@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic, readonly) RACSignal *beaconSignal;
@property (nonatomic, readonly) BOOL scanning;
-(void)startScanning;
-(void)stopScanning;

+(HGBeaconManager *)sharedBeaconManager;
@end

//
//  HGBeaconScanner.h
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
@interface HGBeaconScanner : NSObject
@property (nonatomic, readonly) RACSignal *beaconSignal;
@property (nonatomic, readonly) BOOL scanning;
-(void)startScanning;
-(void)stopScanning;

+(HGBeaconScanner *)sharedBeaconScanner;
@end

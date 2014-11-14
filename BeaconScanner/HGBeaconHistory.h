//
//  HGBeaconHistory.h
//  BeaconScanner
//
//  Created by Mike Welles on 11/14/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;
@class HGBeacon;
@interface HGBeaconHistory : NSObject
- (void)addBeacon:(HGBeacon *)beacon;
- (id)initWithBeaconSignal:(RACSignal *)beaconSignal maximumHistorySize:(NSUInteger) max;
- (id)initWithBeaconSignal:(RACSignal *)beaconSignal;
@end

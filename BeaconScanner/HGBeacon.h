//
//  HGBeacon.h
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ReactiveCocoa/ReactiveCocoa.h"
@interface HGBeacon : NSObject

@property (strong,nonatomic) NSUUID *proximityUUID;
//uint16_t minor;@property (assign,nonatomic) uint16_t major;
@property (strong,nonatomic) NSNumber *major;
//@property (assign,nonatomic) uint16_t minor;
@property (strong,nonatomic) NSNumber *minor;
//@property (assign,nonatomic) int8_t measuredPower;
@property (strong,nonatomic) NSNumber *measuredPower;
@property (strong,nonatomic) NSNumber *RSSI;
@property (strong,nonatomic) NSDate *lastUpdated;
- (id)initWithProximityUUID:(NSUUID *)proximityUUID
                      major:(NSNumber *)major
                      minor:(NSNumber *)minor
              measuredPower:(NSNumber *)power;


+(HGBeacon *)beaconWithAdvertismentDataDictionary:(NSDictionary *)dictionary;
+(HGBeacon *)beaconWithManufacturerAdvertisementData:(NSData *)data;
-(BOOL)isEqualToBeacon:(HGBeacon *)otherBeacon;

- (NSDictionary *)advertismentDictionary;

@end

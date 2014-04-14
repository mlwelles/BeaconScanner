//
//  HGBeacon.h
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//
//  Portions of this code are from BLCBeaconAdvertisement.m, part of BeaconOSX  and copyright (c) 2013, Matthew Robinson
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  3. Neither the name of Blended Cocoa nor the names of its contributors may
//     be used to endorse or promote products derived from this software without
//     specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//
//
//  BLCBeaconAdvertisementData.m
//  BeaconOSX
//
//  Created by Matthew Robinson on 1/11/2013.
//#import <Foundation/Foundation.h>
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

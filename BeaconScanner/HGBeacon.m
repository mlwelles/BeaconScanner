//
//  HGBeacon.m
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 2/27/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//
#import "HGBeacon.h"
#import <IOBluetooth/IOBluetooth.h>
#import "stdint.h"
#import "EXTScope.h"
NSString *const HGBeaconAdvertismentManufacturerDataKey = @"kCBAdvDataAppleBeaconKey";
@implementation HGBeacon

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor measuredPower:(NSNumber *)power {
    self = [super init];
    
    if (self) {
        self.proximityUUID = proximityUUID;
        self.major = major;
        self.minor = minor;
        self.measuredPower = power;
        self.lastUpdated = [NSDate date];
    }
    return self;
}


+(HGBeacon *)beaconWithAdvertismentDataDictionary:(NSDictionary *)advertisementDataDictionary {
    NSData *data = (NSData *)[advertisementDataDictionary objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (data) {
        return [self beaconWithManufacturerAdvertisementData:data];
    }
    return nil;
}



+(HGBeacon *)beaconWithManufacturerAdvertisementData:(NSData *)data {
    if ([data length] != 25) {
        return nil;
    }

    u_int16_t companyIdentifier,major,minor = 0;

    int8_t measuredPower,dataType, dataLength = 0;
    char uuidBytes[17] = {0};

    NSRange companyIDRange = NSMakeRange(0,2);
    [data getBytes:&companyIdentifier range:companyIDRange];
    if (companyIdentifier != 0x4C) {
        return nil;
    }
    NSRange dataTypeRange = NSMakeRange(2,1);
    [data getBytes:&dataType range:dataTypeRange];
    if (dataType != 0x02) {
        return nil;
    }
    NSRange dataLengthRange = NSMakeRange(3,1);
    [data getBytes:&dataLength range:dataLengthRange];
    if (dataLength != 0x15) {
        return nil;
    }
    
    NSRange uuidRange = NSMakeRange(4, 16);
    NSRange majorRange = NSMakeRange(20, 2);
    NSRange minorRange = NSMakeRange(22, 2);
    NSRange powerRange = NSMakeRange(24, 1);
    [data getBytes:&uuidBytes range:uuidRange];
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDBytes:(const unsigned char*)&uuidBytes];
    [data getBytes:&major range:majorRange];
    major = (major >> 8) | (major << 8);
    [data getBytes:&minor range:minorRange];
    minor = (minor >> 8) | (minor << 8);
    [data getBytes:&measuredPower range:powerRange];
    HGBeacon *beaconAdvertisementData = [[HGBeacon alloc] initWithProximityUUID:proximityUUID
                                                                          major:[NSNumber numberWithUnsignedInteger:major]
                                                                          minor:[NSNumber numberWithUnsignedInteger:minor]
                                                                  measuredPower:[NSNumber numberWithShort:measuredPower]];
    return beaconAdvertisementData;
}


-(NSData *)manufacturerAdvertismentData {
    unsigned char advertisementBytes[21] = {0};
    [self.proximityUUID getUUIDBytes:(unsigned char *)&advertisementBytes];
    u_int16_t major16 = [self.major shortValue];
    u_int16_t minor16 = [self.minor shortValue];
    advertisementBytes[16] = (unsigned char)(major16 >> 8);
    advertisementBytes[17] = (unsigned char)(major16 & 0xFF);
    advertisementBytes[18] = (unsigned char)(minor16 >> 8);
    advertisementBytes[19] = (unsigned char)(minor16 & 0xFF);
    advertisementBytes[20] = (int8_t)[self.measuredPower shortValue];
    NSData *data = [NSData dataWithBytes:advertisementBytes length:21];
    return data;
}

- (NSDictionary *)advertismentDictionary {
    return [NSDictionary dictionaryWithObject:[self manufacturerAdvertismentData] forKey:HGBeaconAdvertismentManufacturerDataKey];
}

-(BOOL)isEqualToBeacon:(HGBeacon *)otherBeacon {
    return ([self.proximityUUID isEqualTo:otherBeacon.proximityUUID] &&
            [self.major isEqualToNumber:otherBeacon.major] &&
            [self.minor isEqualToNumber:otherBeacon.minor]);
}

-(BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[HGBeacon class]]) {
        HGBeacon *otherBeacon = (HGBeacon *)object;
        return [self isEqualToBeacon:otherBeacon];
    }
    return [super isEqualTo:object];
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone {
    HGBeacon *beaconCopy = [[HGBeacon allocWithZone:zone] initWithProximityUUID:self.proximityUUID major:self.major minor:self.minor measuredPower:self.measuredPower];
    beaconCopy.lastUpdated = self.lastUpdated;
    beaconCopy.RSSI = self.RSSI;
    return beaconCopy;
}

@end

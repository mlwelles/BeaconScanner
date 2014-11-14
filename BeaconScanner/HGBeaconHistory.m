//
//  HGBeaconHistory.m
//  BeaconScanner
//
//  Created by Mike Welles on 11/14/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import "HGBeaconHistory.h"
#import "HGBeacon.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "BlocksKit.h"
#import "EXTScope.h"

static const NSUInteger HGBeaconHistoryDefaultMaximumSize = 300;
@interface HGBeaconHistory()
@property(nonatomic, strong) NSMutableDictionary *beaconSubjectMap;
@property(nonatomic, assign) NSUInteger maximumHistorySize;
//@property(nonatomic, strong) RACSignal *beaconSignal;
@end

@implementation HGBeaconHistory

-(id)initWithBeaconSignal:(RACSignal *)beaconSignal {
    return [self initWithBeaconSignal:beaconSignal maximumHistorySize:HGBeaconHistoryDefaultMaximumSize];
}

-(id)initWithBeaconSignal:(RACSignal *)beaconSignal maximumHistorySize:(NSUInteger)maximumHistorySize{
    self = [super init];
    if (self) {
        _maximumHistorySize = maximumHistorySize;
        _beaconSubjectMap = [[NSMutableDictionary alloc] init];
        @weakify(self)
        [beaconSignal subscribeNext:^(HGBeacon *beacon) {
            @strongify(self)
            [self addBeacon:beacon];
        }];
    }
    return self;
}

- (RACSubject *)subjectForBeacon:(HGBeacon *)beacon {
    NSString *key = [NSString stringWithFormat:@"%@-%@-%@", beacon.proximityUUID, beacon.major, beacon.minor];
    RACReplaySubject *beaconSubject = self.beaconSubjectMap[key];
    if (! beaconSubject ) {
        beaconSubject = [RACReplaySubject replaySubjectWithCapacity:self.maximumHistorySize];
        self.beaconSubjectMap[key] = beaconSubject;
    }
    return beaconSubject;
}

- (RACSignal *)signalForBeacon:(HGBeacon *)beacon {
    return (RACSignal *)[self subjectForBeacon:beacon];
}

-(void)addBeacon:(HGBeacon *)beacon {
    [[self subjectForBeacon:beacon] sendNext:beacon];
}





@end

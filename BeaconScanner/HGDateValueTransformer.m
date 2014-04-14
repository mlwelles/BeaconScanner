//
//  HGDateValueTransformer.m
//  Beacon Scanner
//
//  Created by HUGE | Mike Welles on 4/10/14.
//  Copyright (c) 2014 Huge, Inc. All rights reserved.
//

#import "HGDateValueTransformer.h"

@implementation HGDateValueTransformer


+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd HH:mm:ss"];
    });

    NSDate *sourceDate = (NSDate *)value;
    NSString *formattedDateString = [dateFormatter stringFromDate:sourceDate];
    return formattedDateString;
}


@end

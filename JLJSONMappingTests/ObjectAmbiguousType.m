//
//  ObjectAmbiguousType.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/27/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "ObjectAmbiguousType.h"

@implementation ObjectAmbiguousType
+ (NSDateFormatter *)dateFormatterForPropertyNamed:(NSString *)propertyName;
{
    //default date formatter
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS Z"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
        [df setTimeZone:tz];
        [df setLocale:locale];
    });
    return df;
}
@end

//
//  SimpleTestMappingObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 8/9/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "SimpleTestMappingObject.h"

@implementation SimpleTestMappingObject

+ (NSDictionary *)propertyNameMap
{
    return @{@"integer":@"someOtherNameOfInteger",
             @"dictionary" : @"myDictionary",
             @"testMappingObject" : @"someTestingObject",
             @"dictionaryOfSimpleObjects" : @"dictionaryOfSimpleTestMappingObjects",
             @"arrayOfTestObjects" : @"array"
             };
}

+ (NSDictionary *)propertyTypeMap
{
    return @{@"dictionaryOfSimpleObjects": [SimpleTestMappingObject class],
             @"arrayOfTestObjects":[SimpleTestMappingObject class]
             };
}


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

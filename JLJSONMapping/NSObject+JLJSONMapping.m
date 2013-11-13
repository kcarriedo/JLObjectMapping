//
//  NSObject+JLJSONMapping.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "NSObject+JLJSONMapping.h"


@implementation NSObject (JLJSONMapping)

+ (NSDateFormatter *)dateFormatterForPropertyNamed:(NSString*)propertyName
{
    //ignoring propertyName
    static dispatch_once_t once;
    static id dateFormatter;
    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setDateFormat:@"MM-dd-yyyy 'T'HH:mm:ss.SSS Z"];
        [dateFormatter setLocale:locale];
    });
    return dateFormatter;
}

+ (NSDictionary *)propertyNameMap
{
    return @{};
}

+ (NSDictionary *)propertyTypeMap
{
    return @{};
}

-(void)didDeserialize:(NSDictionary *)jsonDictionary
{
    
}

-(void)willSerialize
{
    
}
@end

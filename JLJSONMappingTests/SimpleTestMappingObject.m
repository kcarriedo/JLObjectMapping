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

@end

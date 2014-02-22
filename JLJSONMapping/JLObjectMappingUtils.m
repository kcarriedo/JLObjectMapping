//
//  JLObjectMappingUtils.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/22/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLObjectMappingUtils.h"

@implementation JLObjectMappingUtils

+ (BOOL)isBasicType:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]){
        return YES;
    }else if ([obj isKindOfClass:[NSNumber class]]){
        return YES;
    }else if ([obj isKindOfClass:[NSNull class]]){
        return YES;
    }else{
        return NO;
    }
}

+ (Class)classFromPropertyProperties:(NSString*)propertiesString
{
//    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSArray *attributes = [propertiesString componentsSeparatedByString:@","];
    NSString *typeItem = [attributes objectAtIndex:0];
    if ([typeItem hasPrefix:@"T@"]){
        //is class
        NSRange range = [typeItem rangeOfString:@"T@\""];
        if (range.location != NSNotFound)
        {
            NSInteger startIndex = range.location + range.length;
            NSRange typeRange = NSMakeRange(startIndex, ([typeItem length] - 1) -startIndex);
            NSString *typeString = [typeItem substringWithRange:typeRange];
            Class classOfProperty = NSClassFromString(typeString);
//            NSLog(@"classFromPropertyProperties time: %f string:%@", CFAbsoluteTimeGetCurrent() - start, propertiesString);
            return classOfProperty;
        }
    }
//    NSLog(@"classFromPropertyProperties time: %f string:%@", CFAbsoluteTimeGetCurrent() - start, propertiesString);
    return nil;
}


/*
 Returns the Type for a given property
 */
+ (BOOL)isValueType:(NSString *)propertyProperties
{
    NSArray *attributes = [propertyProperties componentsSeparatedByString:@","];
    NSString *propertyType = [attributes objectAtIndex:1];
    if (![propertyType isEqualToString:@"&"]){
        return YES;
    }
    return NO;
}

//returns the string representation of a basic object
+ (NSString *)stringForBasicType:(NSObject *)object
{
    if ([object isKindOfClass:[NSString class]]){
        return [NSString stringWithFormat:@"\"%@\"", object];
    }else if ([object isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@", object];
    }else{
        return @"null";
    }
}

@end

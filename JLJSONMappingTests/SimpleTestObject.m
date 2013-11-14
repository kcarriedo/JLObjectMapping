//
//  SimpleTestObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "SimpleTestObject.h"

@implementation SimpleTestObject

+ (SimpleTestObject*)newSimpleTestObject
{
    SimpleTestObject *testObject = [[SimpleTestObject alloc] init];
    [testObject setBoolean:YES];
    [testObject setCgfloat:CGFLOAT_MAX-1.0];
    [testObject setDate:[NSDate dateWithTimeIntervalSince1970:1234567890.012]];
    [testObject setInteger:NSIntegerMax-1];
    [testObject setNumber:[[NSNumber alloc] initWithLongLong:LONG_LONG_MAX-1]];
    [testObject setPBoolean:true];
    [testObject setPChar:'*'];
    [testObject setPDouble:DBL_MAX-1];
    [testObject setPFloat:FLT_MAX-1];
    [testObject setPInt16:INT16_MAX-1];
    [testObject setPInt32:INT32_MAX-1];
    [testObject setPInt64:INT64_MAX-1];
    [testObject setPInt:INT_MAX-1];
    [testObject setPLong:LONG_MAX-1];
    [testObject setPLongLong:LONG_LONG_MAX-1];
    [testObject setPShort:SHRT_MAX-1];
    [testObject setPUnsignedChar:254];
    [testObject setPUnsignedInt:UINT_MAX-1];
    [testObject setPUnsignedLong:ULONG_MAX - 1];
    [testObject setPUnsignedLongLong:ULONG_LONG_MAX-1];
    [testObject setPUnsignedShort:USHRT_MAX-1];
    [testObject setString:@"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº"];
    [testObject setUInteger:UINT_MAX-1];
    return  testObject;    
}


- (NSUInteger)hash
{
    
    NSUInteger objectsHash = ([self number]?[[self number] hash]:0);
    objectsHash ^= ([self date]?[[self date] hash]:0);
    objectsHash ^= ([self string]?[[self string] hash]:0);
    NSMutableString *primativeString = [[NSMutableString alloc]init];

    [primativeString appendString:[NSString stringWithFormat:@"%c", [self pBoolean]]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", [self pChar]]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", [self boolean]]];
    [primativeString appendString:[NSString stringWithFormat:@"%f", [self pDouble]]];
    [primativeString appendString:[NSString stringWithFormat:@"%f", [self pFloat]]];
    [primativeString appendString:[NSString stringWithFormat:@"%i", [self pInt]]];
    [primativeString appendString:[NSString stringWithFormat:@"%ld", [self pLong]]];
    [primativeString appendString:[NSString stringWithFormat:@"%lld", [self pLongLong]]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", [self pShort]]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", [self pUnsignedChar]]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", [self pUnsignedInt]]];
    [primativeString appendString:[NSString stringWithFormat:@"%lu", [self pUnsignedLong]]];
    [primativeString appendString:[NSString stringWithFormat:@"%llu", [self pUnsignedLongLong]]];
    [primativeString appendString:[NSString stringWithFormat:@"%i", [self pUnsignedShort]]];
    [primativeString appendString:[NSString stringWithFormat:@"%hi", [self pInt16]]];
    [primativeString appendString:[NSString stringWithFormat:@"%i", [self pInt32]]];
    [primativeString appendString:[NSString stringWithFormat:@"%lld", [self pInt64]]];
    [primativeString appendString:[NSString stringWithFormat:@"%f", [self cgfloat]]];
    [primativeString appendString:[NSString stringWithFormat:@"%li", (long)[self integer]]];
    [primativeString appendString:[NSString stringWithFormat:@"%li", (unsigned long)[self uInteger]]];
    NSUInteger primativesHash = [primativeString hash];
    return primativesHash ^ objectsHash;
}

- (BOOL)isEqual:(id)object
{
    BOOL theyEqual = YES;
    
    //Objects
    if (theyEqual && ([self number] != [object number] && ![(id)[self number] isEqual:[object number]]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self date] != [object date] && ![(id)[self date] isEqual:[object date]]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self string] != [object string] && ![(id)[self string] isEqual:[object string]]))
    {
        theyEqual = NO;
    }
    
    //primatives    
    if (theyEqual && ([self pBoolean] != [object pBoolean]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pChar] != [object pChar]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self boolean] != [object boolean]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pDouble] != [object pDouble]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pFloat] != [object pFloat]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pInt] != [object pInt]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pLong] != [object pLong]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pLongLong] != [object pLongLong]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pShort] != [object pShort]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pUnsignedChar] != [object pUnsignedChar]))
    {
        theyEqual = NO;
    }

    if (theyEqual && ([self pUnsignedInt] != [object pUnsignedInt]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pUnsignedLong] != [object pUnsignedLong]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pUnsignedLongLong] != [object pUnsignedLongLong]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pUnsignedShort] != [object pUnsignedShort]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pInt16] != [object pInt16]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pInt32] != [object pInt32]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self pInt64] != [object pInt64]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self cgfloat] != [object cgfloat]))
    {
        theyEqual = NO;
    }
    
    if (theyEqual && ([self integer] != [object integer]))
    {
        theyEqual = NO;
    }

    if (theyEqual && ([self uInteger] != [object uInteger]))
    {
        theyEqual = NO;
    }
    
    return theyEqual;
}

@end

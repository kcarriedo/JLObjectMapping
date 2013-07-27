//
//  JLObjectSerializerSimpleTests.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLObjectSerializerSimpleTests.h"
#import "JLObjectSerializer.h"
#import "SimpleTestObject.h"
@implementation JLObjectSerializerSimpleTests
{
    JLObjectSerializer *serializer;
}

- (void)setUp
{
    serializer = [[JLObjectSerializer alloc] init];
    [super setUp];
}

- (void)tearDown
{
    serializer = nil;
    [super tearDown];
}


- (void)testFullObjectTranscode
{
    SimpleTestObject *newObject = [SimpleTestObject newSimpleTestObject];
    NSString *objectData = [serializer JSONStringWithObject:newObject];
    STAssertTrue([objectData isEqualToString:@"{\"pBoolean\":true,\"boolean\":1,\"pLongLong\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\",\"pInt64\":9223372036854775806,\"cgfloat\":3.402823e+38,\"pInt16\":32766,\"pUnsignedChar\":254,\"date\":\"02-13-2009 T15:31:30.012 -0800\",\"pLong\":2147483646,\"uInteger\":4294967294,\"pUnsignedLong\":4294967294,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"integer\":2147483646,\"pUnsignedInt\":4294967294,\"pChar\":42,\"pDouble\":1.797693134862316e+308,\"pInt\":2147483646,\"pInt32\":2147483646,\"pFloat\":3.402823e+38,\"pShort\":32766,\"pUnsignedLongLong\":18446744073709551614}"], @"Simple object default values weren't set properly in the resulting JSON");
}



//Sanity test
- (void)testSimpleObjectsEqual
{
    SimpleTestObject *newObject1 = [SimpleTestObject newSimpleTestObject];
    SimpleTestObject *newObject2 = [SimpleTestObject newSimpleTestObject];
    STAssertEqualObjects(newObject1, newObject2, @"Both simple objects should be equal, nothing was done other than creating a new one");
}



@end

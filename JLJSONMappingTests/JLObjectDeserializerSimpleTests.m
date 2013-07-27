//
//  JLObjectDeserializerSimpleTests.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLObjectDeserializerSimpleTests.h"
#import "JLObjectDeserializer.h"
#import "JLObjectSerializer.h"
#import "SimpleTestObject.h"
#import "AnotherSimpleTestObject.h"
#import "ObjectAmbiguousType.h"
#include <asl.h>

@implementation JLObjectDeserializerSimpleTests
{
    JLObjectDeserializer *deserializer;
    JLObjectSerializer *serializer;
}

- (void) setUp
{
    deserializer = [[JLObjectDeserializer alloc] init];
    serializer = [[JLObjectSerializer alloc] init];
    [super setUp];
}

- (void) tearDown
{
    deserializer = nil;
    serializer = nil;
    [super tearDown];
}


-(void) testSimpleObjectDeserialize
{
    SimpleTestObject *newSimpleObject = [[SimpleTestObject alloc] init];
    [newSimpleObject setInteger:54];
    NSString *objectJSON = [serializer JSONStringWithObject:newSimpleObject];
    SimpleTestObject *objectFromString = [deserializer objectWithString:objectJSON targetClass:[SimpleTestObject class]];
    STAssertEqualObjects(objectFromString, newSimpleObject, @"Both objects should be the same");
}

- (void) testJLDeserializerIgnoreMissingProperties
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerReportMissingProperties];
    NSString *jsonWithExtraProperty = @"{\"turtle\":\"yes\"}";
    STAssertThrows([deserializer objectWithString:jsonWithExtraProperty targetClass:[AnotherSimpleTestObject class]], @"this should throw an exception because the JSON doesn't match the object's properties");    
}


- (void) testJLDeserializerIgnoreMissingPropertiesDontError
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerIgnoreMissingProperties];
    NSString *jsonWithExtraProperty = @"{\"turtle\":\"yes\"}";
    STAssertNoThrow([deserializer objectWithString:jsonWithExtraProperty targetClass:[AnotherSimpleTestObject class]], @"this should throw an exception because the JSON doesn't match the object's properties");
}

- (void) testDictionaryJLDeserializerErrorOnAmbiguousTypeDontError
{
    NSString *jsonWithExtraProperty = @"{\"someDictionary\":{\"someInt\":5}}";
    STAssertNoThrow([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void) testDictionaryJLDeserializerErrorOnAmbiguousType
{
        deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerErrorOnAmbiguousType];
    NSString *jsonWithExtraProperty = @"{\"someDictionary\":{\"someInt\":5}}";
    STAssertThrows([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void) testArrayJLDeserializerErrorOnAmbiguousTypeDontError
{
    NSString *jsonWithExtraProperty = @"{\"someArray\":[{\"someInt\":5}]}";
    STAssertNoThrow([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void) testArrayJLDeserializerErrorOnAmbiguousType
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerErrorOnAmbiguousType];
    NSString *jsonWithExtraProperty = @"{\"someArray\":[{\"someInt\":5}]}";
    STAssertThrows([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");

}
@end

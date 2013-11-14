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
#import "SimpleTestMappingObject.h"
#import "AnotherSimpleTestObject.h"
#import "ObjectAmbiguousType.h"
#include <asl.h>

@implementation JLObjectDeserializerSimpleTests
{
    JLObjectDeserializer *deserializer;
    JLObjectSerializer *serializer;
}

- (void)setUp
{
    deserializer = [[JLObjectDeserializer alloc] init];
    serializer = [[JLObjectSerializer alloc] init];
    [super setUp];
}

- (void)tearDown
{
    deserializer = nil;
    serializer = nil;
    [super tearDown];
}


- (void)testSimpleObjectDeserialize
{
    SimpleTestObject *newSimpleObject = [[SimpleTestObject alloc] init];
    [newSimpleObject setUInteger:0x54];
    NSString *objectJSON = [serializer JSONStringWithObject:newSimpleObject];
    SimpleTestObject *objectFromString = [deserializer objectWithString:objectJSON targetClass:[SimpleTestObject class]];
    STAssertEqualObjects(objectFromString, newSimpleObject, @"Both objects should be the same");
}


- (void)testPropertyNameMapping
{
    //tests nested object, dictionary, and property
    NSString *objectJSON = @"{\"someOtherNameOfInteger\":12345, \"myDictionary\":{\"turtles\":\"yes\"}, \"someTestingObject\" : {\"someOtherNameOfInteger\":9876, \"myDictionary\":{\"turtles\":\"nope\"}, \"someTestingObject\" : {}}}";
    NSLog(@"%@", objectJSON);
    SimpleTestMappingObject *objectFromString = [deserializer objectWithString:objectJSON targetClass:[SimpleTestMappingObject class]];
    STAssertEquals([objectFromString integer], 12345, @"simple property should have transcoded");
    STAssertEqualObjects([[objectFromString dictionary] objectForKey:@"turtles"], @"yes", @"dictionary property should have transcoded");
    STAssertEquals([[objectFromString testMappingObject] integer], 9876, @"nested object simple property should have transcoded");
    STAssertEqualObjects([[[objectFromString testMappingObject] dictionary]objectForKey:@"turtles"] , @"nope", @"nested object dictionary property should have transcoded");
}

- (void)testMoreComplicatedPropertyNameMapping
{
    NSString *objectJSON = @"{\"someOtherNameOfInteger\":12345, \"myDictionary\":{\"turtles\":\"yes\"}, \"someTestingObject\" : {\"someOtherNameOfInteger\":9876, \"myDictionary\":{\"turtles\":\"nope\"}, \"someTestingObject\" : {}}, \"dictionaryOfSimpleTestMappingObjects\" :{\"oneObject\":{\"someOtherNameOfInteger\":101, \"myDictionary\":{\"turtles\":\"yup\"}, \"someTestingObject\" : {}}}, \"array\" : [{\"someOtherNameOfInteger\":202, \"myDictionary\":{\"turtles\":\"yar\"}, \"someTestingObject\" : {}}]}";
    SimpleTestMappingObject *objectFromString = [deserializer objectWithString:objectJSON targetClass:[SimpleTestMappingObject class]];
    
    STAssertEquals([objectFromString integer], 12345, @"simple property should have transcoded");
    STAssertEqualObjects([[objectFromString dictionary] objectForKey:@"turtles"], @"yes", @"dictionary property should have transcoded");
    STAssertEquals([[objectFromString testMappingObject] integer], 9876, @"nested object simple property should have transcoded");
    STAssertEqualObjects([[[objectFromString testMappingObject] dictionary]objectForKey:@"turtles"] , @"nope", @"nested object dictionary property should have transcoded");
    
    //test objects that were packaged in a dictionary that went by a different name
    SimpleTestMappingObject *objectFromDict = [[objectFromString dictionaryOfSimpleObjects] objectForKey:@"oneObject"];
    STAssertEquals([objectFromDict integer], 101, @"nested object in dict simple property should have transcoded");
    STAssertEqualObjects([[objectFromDict dictionary] objectForKey:@"turtles"], @"yup", @"nested object in dictionary property should have transcoded");

    
    //test objects that were packaged in an array that went by a different name
    SimpleTestMappingObject *objectFromArray = [[objectFromString arrayOfTestObjects] objectAtIndex:0];
    
    STAssertEquals([objectFromArray integer], 202, @"nested object in dict simple property should have transcoded");
    STAssertEqualObjects([[objectFromArray dictionary] objectForKey:@"turtles"], @"yar", @"nested object in dictionary property should have transcoded");
}

- (void)testJLDeserializerIgnoreMissingProperties
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerReportMissingProperties];
    NSString *jsonWithExtraProperty = @"{\"turtle\":\"yes\"}";
    STAssertThrows([deserializer objectWithString:jsonWithExtraProperty targetClass:[AnotherSimpleTestObject class]], @"this should throw an exception because the JSON doesn't match the object's properties");    
}


- (void)testJLDeserializerIgnoreMissingPropertiesDontError
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerIgnoreMissingProperties];
    NSString *jsonWithExtraProperty = @"{\"turtle\":\"yes\"}";
    STAssertNoThrow([deserializer objectWithString:jsonWithExtraProperty targetClass:[AnotherSimpleTestObject class]], @"this should throw an exception because the JSON doesn't match the object's properties");
}

- (void)testDictionaryJLDeserializerErrorOnAmbiguousTypeDontError
{
    NSString *jsonWithExtraProperty = @"{\"someDictionary\":{\"someInt\":5}}";
    STAssertNoThrow([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void)testDictionaryJLDeserializerErrorOnAmbiguousType
{
        deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerErrorOnAmbiguousType];
    NSString *jsonWithExtraProperty = @"{\"someDictionary\":{\"someInt\":5}}";
    STAssertThrows([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void)testArrayJLDeserializerErrorOnAmbiguousTypeDontError
{
    NSString *jsonWithExtraProperty = @"{\"someArray\":[{\"someInt\":5}]}";
    STAssertNoThrow([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void)testArrayJLDeserializerErrorOnAmbiguousType
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerErrorOnAmbiguousType];
    NSString *jsonWithExtraProperty = @"{\"someArray\":[{\"someInt\":5}]}";
    STAssertThrows([deserializer objectWithString:jsonWithExtraProperty targetClass:[ObjectAmbiguousType class]], @"not defining what the class of the someDictionary object is expecting should throw an exception");

}
@end

//
//  JLObjectSerializerSimpleTests.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLObjectSerializerSimpleTests.h"
#import "JLObjectSerializer.h"
#import "JLObjectDeserializer.h"
#import "SimpleTestObject.h"
#import "SimpleTestMappingObject.h"
@implementation JLObjectSerializerSimpleTests
{
    JLObjectSerializer *serializer;
    JLObjectDeserializer *deserializer;
}

- (void)setUp
{
    serializer = [[JLObjectSerializer alloc] init];
    deserializer = [[JLObjectDeserializer alloc] init];
    [super setUp];
}

- (void)tearDown
{
    serializer = nil;
    deserializer = nil;
    [super tearDown];
}

- (void)testPropertyNameMapping
{
    SimpleTestMappingObject *simpleObject = [[SimpleTestMappingObject alloc] init];
    [simpleObject setInteger:12345];//
    [simpleObject setDictionary:@{@"turtles":@"nope"}];//
    SimpleTestMappingObject *simpleDictionaryObject = [[SimpleTestMappingObject alloc] init];
    [simpleDictionaryObject setInteger:101];//
    [simpleDictionaryObject setDictionary:@{@"turtles":@"yup"}];//
    
    NSDictionary *testDictionary = @{@"oneObject":simpleDictionaryObject};
    [simpleObject setDictionaryOfSimpleObjects:testDictionary];
    
    SimpleTestMappingObject *arrayObject = [[SimpleTestMappingObject alloc] init];
    [arrayObject setInteger:202];
    [arrayObject setDictionary:@{@"turtles":@"huh?"}];
    [simpleObject setArrayOfTestObjects:@[arrayObject]];
    
    NSString *json =@"{\"myDictionary\":{\"turtles\":\"nope\"},\"someOtherNameOfInteger\":12345,\"dictionaryOfSimpleTestMappingObjects\":{\"oneObject\":{\"someOtherNameOfInteger\":101,\"myDictionary\":{\"turtles\":\"yup\"}}},\"array\":[{\"someOtherNameOfInteger\":202,\"myDictionary\":{\"turtles\":\"huh?\"}}]}";;
    SimpleTestMappingObject *transcodedObject = [deserializer objectWithString:json targetClass:[SimpleTestMappingObject class]];
    
    //test that simple properties can be transcoded
    STAssertEquals([simpleObject integer], [transcodedObject integer], @"simple properties couldn't be transcoded");
    
    //test that dictionaries with simple values can be transcoded
    STAssertEqualObjects([[simpleObject dictionary] objectForKey:@"turtles"], [[transcodedObject dictionary] objectForKey:@"turtles"], @"dictionaries with simple values couldn't be transcoded");
    
    //test that dictionaries containing objects can be transcoded
    STAssertEquals([[[simpleObject dictionaryOfSimpleObjects] objectForKey:@"oneObject"] integer], [[[transcodedObject dictionaryOfSimpleObjects] objectForKey:@"oneObject"] integer], @"dictionaries containing objects couldn't be transcoded");
    
    STAssertEqualObjects([[[[simpleObject dictionaryOfSimpleObjects] objectForKey:@"oneObject"] dictionary] objectForKey:@"turtles"], [[[[transcodedObject dictionaryOfSimpleObjects] objectForKey:@"oneObject"] dictionary] objectForKey:@"turtles"], @"dictionaries with complicated objects as values that contain other dictionaries couldn't be transcoded");
    
    //test that arrays of objects can be transcoded with the property name map
    STAssertEquals([[[simpleObject arrayOfTestObjects] objectAtIndex:0] integer], [[[transcodedObject arrayOfTestObjects] objectAtIndex:0] integer], @"objects with arrays with complicated objects as values couldn't be transcoded");
    
    STAssertEqualObjects([[[[simpleObject arrayOfTestObjects] objectAtIndex:0] dictionary] objectForKey:@"turtles"], [[[[transcodedObject arrayOfTestObjects] objectAtIndex:0] dictionary] objectForKey:@"turtles"], @"objects with arrays with complicated objects in them that also contains dictionaries whose values couldn't be transcoded");
}


- (void)testFullObjectTranscodeNSJSONSerializer
{
    SimpleTestObject *newObject = [SimpleTestObject newSimpleTestObject];
    serializer = [[JLObjectSerializer alloc] initWithSerializerOptions:JLSerializerDefaultOptionsMask | JLSerializerUseNSJSONSerilizer];
    NSString *objectData = [serializer JSONStringWithObject:newObject];
    STAssertTrue([objectData isEqualToString:@"{\"pBoolean\":true,\"boolean\":1,\"pLongLong\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\",\"pInt64\":9223372036854775806,\"cgfloat\":3.402823e+38,\"pInt16\":32766,\"pUnsignedChar\":254,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"pLong\":2147483646,\"uInteger\":4294967294,\"pUnsignedLong\":4294967294,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"integer\":2147483646,\"pUnsignedInt\":4294967294,\"pChar\":42,\"pDouble\":1.797693134862316e+308,\"pInt\":2147483646,\"pInt32\":2147483646,\"pFloat\":3.402823e+38,\"pShort\":32766,\"pUnsignedLongLong\":18446744073709551614}"], @"Simple object default values weren't set properly in the resulting JSON");
}

- (void)testFullObjectTranscodeCustomSerializer
{
    SimpleTestObject *newObject = [SimpleTestObject newSimpleTestObject];
    NSString *objectData = [serializer JSONStringWithObject:newObject];
    STAssertTrue([objectData isEqualToString:@"{\"pBoolean\":1,\"boolean\":1,\"pLongLong\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\",\"pInt64\":9223372036854775806,\"cgfloat\":3.402823e+38,\"pInt16\":32766,\"pUnsignedChar\":254,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"pLong\":2147483646,\"uInteger\":4294967294,\"pUnsignedLong\":4294967294,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"integer\":2147483646,\"pUnsignedInt\":4294967294,\"pChar\":42,\"pDouble\":1.797693134862316e+308,\"pInt\":2147483646,\"pInt32\":2147483646,\"pFloat\":3.402823e+38,\"pShort\":32766,\"pUnsignedLongLong\":18446744073709551614}"], @"Simple object default values weren't set properly in the resulting JSON");
}


//Sanity test
- (void)testSimpleObjectsEqual
{
    SimpleTestObject *newObject1 = [SimpleTestObject newSimpleTestObject];
    SimpleTestObject *newObject2 = [SimpleTestObject newSimpleTestObject];
    STAssertEqualObjects(newObject1, newObject2, @"Both simple objects should be equal, nothing was done other than creating a new one");
}



@end

//
//  ComplicatedTestObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SimpleTestObject;
@interface ComplicatedTestObject : NSObject
@property (nonatomic, strong) SimpleTestObject *simpleTestObject;
@property (nonatomic, strong) NSArray *arrayOfSimpleTestObjects;
@property (nonatomic, strong) NSSet *setOfSimpleTestObjects;
@property (nonatomic, strong) NSDictionary *dictionaryOfSimpleTestObjects;

+ (ComplicatedTestObject*) newComplicatedTestObject;

- (SimpleTestObject *)simpleObjectWithIntegerValue:(NSInteger)value;


@end

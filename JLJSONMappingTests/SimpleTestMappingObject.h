//
//  SimpleTestMappingObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 8/9/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleTestMappingObject : NSObject
@property (nonatomic, assign)NSInteger integer;
@property (nonatomic, strong)NSDictionary *dictionary;
@property (nonatomic, strong)NSDictionary *dictionaryOfSimpleObjects;
@property (nonatomic, strong)SimpleTestMappingObject *testMappingObject;
@property (nonatomic, strong)NSArray *arrayOfTestObjects;

@end

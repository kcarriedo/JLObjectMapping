//
//  ComplicatedTestObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "ComplicatedTestObject.h"
#import "SimpleTestObject.h"

@implementation ComplicatedTestObject

+ (ComplicatedTestObject*) newComplicatedTestObject
{
    ComplicatedTestObject *object = [[ComplicatedTestObject alloc] init];
    [object setSimpleTestObject:[SimpleTestObject newSimpleTestObject]];
    
    
    [object setArrayOfSimpleTestObjects:@[[object simpleObjectWithIntegerValue:0],
                                          [object simpleObjectWithIntegerValue:1],
                                          [object simpleObjectWithIntegerValue:2],
                                          [object simpleObjectWithIntegerValue:3],
                                          [object simpleObjectWithIntegerValue:4],
          
                                          [object simpleObjectWithIntegerValue:5]
     ]];
    
    [object setSetOfSimpleTestObjects: [NSSet setWithArray: @[[object simpleObjectWithIntegerValue:10],
                                       [object simpleObjectWithIntegerValue:11],
                                       [object simpleObjectWithIntegerValue:12],
                                       [object simpleObjectWithIntegerValue:13],
                                       [object simpleObjectWithIntegerValue:14],

                                       [object simpleObjectWithIntegerValue:15]
                                       ]]
     ];
    
    [object setDictionaryOfSimpleTestObjects: @{@"0": [object simpleObjectWithIntegerValue:0],
                                                @"1": [object simpleObjectWithIntegerValue:1],
                                                @"2": [object simpleObjectWithIntegerValue:2],
                                                @"3": [object simpleObjectWithIntegerValue:3],
                                                @"4": [object simpleObjectWithIntegerValue:4],
                                                @"5": [object simpleObjectWithIntegerValue:5]}
     ];
    
    return object;
    
}

- (SimpleTestObject *)simpleObjectWithIntegerValue:(NSInteger)value
{
    SimpleTestObject *simpleObject = [SimpleTestObject newSimpleTestObject];
    [simpleObject setInteger:value];
    return simpleObject;
}


- (BOOL)isEqual:(id)someObject
{
    if ([someObject isKindOfClass:[self class]]) {
        ComplicatedTestObject *object= (ComplicatedTestObject *)someObject;
        if ([[object arrayOfSimpleTestObjects] count] != [[self arrayOfSimpleTestObjects] count]){
            return NO;
        }else
        {
            for (int i = 0; [[object arrayOfSimpleTestObjects] count]< [[object arrayOfSimpleTestObjects] count] ; i++)
            {
                if (![[[object arrayOfSimpleTestObjects] objectAtIndex:i] isEqual:[[self arrayOfSimpleTestObjects] objectAtIndex:i]])
                {
                    return NO;
                }
            }
        }
        
        if ([[object setOfSimpleTestObjects] count] != [[self setOfSimpleTestObjects] count]){
            return NO;
        }else
        {
            NSEnumerator *enumerator = [[object setOfSimpleTestObjects] objectEnumerator];
            id object;
            while ((object = [enumerator nextObject])) {
                if (![[self setOfSimpleTestObjects] containsObject:object])
                {
                    return NO;
                }
            }
        }
        
        if ([[object dictionaryOfSimpleTestObjects] count] != [[self dictionaryOfSimpleTestObjects] count]){
            return NO;
        }else
        {
            NSEnumerator *enumerator = [[object dictionaryOfSimpleTestObjects]objectEnumerator];
            for(NSString *aKey in enumerator) {
                SimpleTestObject *simpleObject = [[object dictionaryOfSimpleTestObjects] valueForKey:aKey];
                SimpleTestObject *simpleObject2 = [[self dictionaryOfSimpleTestObjects] objectForKey:aKey];
                if (![simpleObject isEqual:simpleObject2])
                {
                    return NO;
                }
            }
        }
        return YES;
    }
    return NO;
}
@end

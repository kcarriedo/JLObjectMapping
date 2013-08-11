//
//  JLObjectSerializer.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//
#import <objc/runtime.h>

#import "JLObjectMapper.h"
#import "JLObjectMappingUtils.h"
#import "JLObjectSerializer.h"
#import "JLTimer.h"


@interface JLObjectSerializer()
@property(nonatomic, strong)NSSet *serializableClasses;
@end

@implementation JLObjectSerializer
{
    JLSerializerOptionMask optionMask;
    NSMutableDictionary *classPropertiesNameMap;
}
@synthesize serializableClasses;

-(id)initWithSerializerOptions:(JLSerializerOptionMask)options
{
    self = [super init];
    if (self)
    {
        optionMask = options;
        classPropertiesNameMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        optionMask = JLSerializerDefaultOptionsMask;
        classPropertiesNameMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - API

//primary entry point (api, sorts out object)
-(NSString *)JSONStringWithObject:(NSObject *)object
{
    id jsonObject = [self JSONObjectWithObject:object];
    NSError *error;
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

//primary entry point (api, sorts out object)
-(id)JSONObjectWithObject:(NSObject *)object
{
    id returnObject;
    if ([object isKindOfClass:[NSDictionary class]]){
        returnObject = [self dictionaryFromObjectDictionary:(NSDictionary*)object];
    }else if ([object isKindOfClass:[NSArray class]]){
        returnObject = [self arrayFromObjectArray:(NSArray*)object];
    }else if ([object isKindOfClass:[NSSet class]]){
        returnObject = [self arrayFromObjectSet:(NSSet*)object];
    }else if ([object class] == [NSDate class]){
        NSDateFormatter *dateFormatter = [[object class] dateFormatterForPropertyNamed:nil];
        returnObject = [dateFormatter stringFromDate:(NSDate *)object];
    }else if ([JLObjectMappingUtils isBasicType:object]){
        //we have a simple object that can be trancoded by NSJSONSerialization so just return it
        returnObject = object;
    }else{
        returnObject = [self dictionaryFromObject:object];
    }    
    return returnObject;
}

#pragma mark - 

-(NSArray *)arrayFromObjectArray:(NSArray *)array
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id object = [self JSONObjectWithObject:obj];
        [jsonArray addObject:object];
    }];
    return jsonArray;
}

-(NSArray *)arrayFromObjectSet:(NSSet *)set
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:[set count]];
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id jsonObject = [self JSONObjectWithObject:obj];
        [jsonArray addObject:jsonObject];            
    }];
    return jsonArray;
}

-(NSDictionary *)dictionaryFromObjectDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id object = [self JSONObjectWithObject:obj];
        [jsonDictionary setObject:object forKey:key];
    }];
    return jsonDictionary;
}


-(NSSet *) loadPropertyMapForClass:(Class) class
{
    JLTimer *timer = [self timerForMethodNamed:@"loadPropertyMapForClass"];
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    NSMutableSet *classProperties;
    if (properties){
        classProperties = [[NSMutableSet alloc] initWithCapacity:count*1.7];//1.7 to give us a little more assurance we will avoid collisions
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
            [classProperties addObject:key];
        }
    }
    if (!classProperties)
    {
        [classPropertiesNameMap setObject:[[NSSet alloc] initWithArray:@[]] forKey:NSStringFromClass(class)];
    }else
    {
        [classPropertiesNameMap setObject:classProperties forKey:NSStringFromClass(class)];
    }
    
    free(properties);
    [timer recordTime:nil];
    return classProperties;
}


-(NSDictionary *)dictionaryFromObject:(NSObject *)obj
{
    if (!obj){
        return nil;
    }
    NSString *currentClassName = NSStringFromClass([obj class]);
    JLTimer *timer = [self timerForMethodNamed:@"dictionaryFromObject"];
    NSSet *propertySet = [classPropertiesNameMap objectForKey:currentClassName];
    if (!propertySet)
    {
        propertySet = [self loadPropertyMapForClass:[obj class]];
        [self logVerbose:[NSString stringWithFormat:@"loaded properties from class:%@\n", currentClassName]];
    }
    else
    {
        [timer recordTime:[NSString stringWithFormat:@"Cached properties returned for class %@",currentClassName]];
        [self logVerbose:[NSString stringWithFormat:@"using cached properties from class:%@\n", currentClassName]];
    }
    [timer recordTime:[NSString stringWithFormat:@"Super class:%@",[[obj class] superclass]]];
    [obj willSerialize];
    NSMutableDictionary *newJSONDictionary = [NSMutableDictionary dictionary];
    NSDictionary *propertyNameMap = [[obj class] propertyNameMap];
    if (propertySet)
    {
        [propertySet enumerateObjectsUsingBlock:^(id propertyKey, BOOL *stop) {
            id propertyJSONValue = [obj valueForKey:propertyKey];
            [self logVerbose: [NSString stringWithFormat:@"key:%@ class: %@ value: %@\n", propertyKey, [propertyJSONValue class], propertyJSONValue]];
            if (propertyJSONValue != nil)
            {
                if ([propertyJSONValue isKindOfClass:[NSArray class]]){
                    propertyJSONValue = [self arrayFromObjectArray:(NSArray*)propertyJSONValue];
                }else if ([propertyJSONValue isKindOfClass:[NSDictionary class]]){
                    propertyJSONValue = [self dictionaryFromObjectDictionary:(NSDictionary*)propertyJSONValue];
                }else if ([propertyJSONValue isKindOfClass:[NSSet class]]){
                    propertyJSONValue = [self arrayFromObjectSet:(NSSet*)propertyJSONValue];
                }else if ([propertyJSONValue isKindOfClass:[NSDate class]]){
                    NSDateFormatter *df = [[obj class] dateFormatterForPropertyNamed:propertyKey];
                    propertyJSONValue = [df stringFromDate:(NSDate*)propertyJSONValue];
                }else if (![JLObjectMappingUtils isBasicType:propertyJSONValue]){
                    propertyJSONValue = [self dictionaryFromObject:propertyJSONValue];
                }
                if (propertyJSONValue){
                    NSString *jsonFieldName = [propertyNameMap objectForKey:propertyKey];
                    if (jsonFieldName)
                    {
                        //if we have a property name to JSON field mapping, use it
                        propertyKey = jsonFieldName;
                    }
                    [newJSONDictionary setObject:propertyJSONValue forKey:propertyKey];
                }
            }else
            {
                [self logVerbose:[NSString stringWithFormat:@"nil value for property:%@ on class:%@\n", propertyKey, currentClassName]];
            }
        }];
    }
    return [NSDictionary dictionaryWithDictionary:newJSONDictionary];
}

#pragma mark - Serialization options
-(BOOL) isVerbose
{
    return (optionMask & JLSerializerVerboseOutput);
}

-(BOOL) isReportTimers
{
    return (optionMask & JLSerializerReportTimers);
}

#pragma mark - generic class stuff

-(void)dealloc
{
    classPropertiesNameMap = nil;
}
@end

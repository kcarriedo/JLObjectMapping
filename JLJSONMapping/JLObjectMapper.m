//
//  JLObjectMapper.m
//  JLJSONMapping
//
//  Convenience class, you can control the serializer/deserializer individually if you'd like.
//  Uses default options for the init
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLObjectMapper.h"
#import "JLObjectSerializer.h"
#import "JLObjectDeserializer.h"

@interface JLObjectMapper()
@property(nonatomic, strong) JLObjectSerializer *serializer;
@property(nonatomic, strong) JLObjectDeserializer *deserializer;
@end


@implementation JLObjectMapper
@synthesize serializer, deserializer;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setSerializer:[[JLObjectSerializer alloc] init]];
        [self setDeserializer:[[JLObjectDeserializer alloc] init]];
    }
    return self;
}

- (NSString *)JSONStringWithObject:(NSObject *)object
{
    return [serializer JSONStringWithObject:object];
}

- (id)JSONObjectWithObject:(NSObject *)object
{
    return [serializer JSONObjectWithObject:object];
}


- (id)objectWithJSONObject:(id)obj targetClass:(Class)class
{
    return [deserializer objectWithJSONObject:obj targetClass:class];
}

- (id)objectWithString:(NSString *)objectString targetClass:(Class)class
{
    return [deserializer objectWithString:objectString targetClass:class];
}

@end

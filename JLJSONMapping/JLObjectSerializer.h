//
//  JLObjectSerializer.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLObjectMapper.h"
#import "JLTranscodingBase.h"

typedef NS_OPTIONS(NSInteger, JLSerializerOptionMask) {
    JLSerializerVerboseOutput = 1 << 0,
    JLSerializerReportTimers = 1 << 1,
    JLSerializerDefaultOptionsMask = 0x0
};

@interface JLObjectSerializer : JLTranscodingBase

- (id)initWithSerializerOptions:(JLSerializerOptionMask)options;

- (id)JSONObjectWithObject:(NSObject *)object;
- (NSString *)JSONStringWithObject:(NSObject *)object;

@end

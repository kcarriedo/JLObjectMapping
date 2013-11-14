//
//  JLObjectDeserializer.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLObjectMapper.h"
#import "JLTranscodingBase.h"

typedef NS_OPTIONS(NSInteger, JLDeserializerOptionMask) {
    JLDeserializerIgnoreMissingProperties = 1 << 0,
    JLDeserializerErrorOnAmbiguousType = 1 << 1,    //This should be used for development only
    JLDeserializerReportMissingProperties = 1 << 2,
    JLDeserializerReportNilProperties = 1 << 3,     //Good for development as well
    JLDeserializerReportTimers = 1 << 4,
    JLDeserializerVerboseOutput = 1 << 5,
    JLDeserializerDefaultOptionMask = JLDeserializerReportMissingProperties | JLDeserializerIgnoreMissingProperties | JLDeserializerReportTimers | JLDeserializerReportNilProperties
};

@interface JLObjectDeserializer : JLTranscodingBase

- (id)initWithDeserializerOptions:(JLDeserializerOptionMask) options;

- (id)objectWithJSONObject:(id)obj targetClass:(Class)class;
- (id)objectWithString:(NSString *)objectString targetClass:(Class)class;

@end

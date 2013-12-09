//
//  JLObjectDeserializer.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <objc/runtime.h>
#import "JLObjectDeserializer.h"
#import "JLObjectMappingUtils.h"
#import "JLTimer.h"

@implementation JLObjectDeserializer
{
    JLDeserializerOptionMask optionMask;
}

- (id)initWithDeserializerOptions:(JLDeserializerOptionMask)options
{
    self = [super init];
    if (self)
    {
        optionMask = options;
    }
    return self;    
}

- (id)init
{
    self = [super init];
    if (self)
    {
        optionMask = JLDeserializerDefaultOptionMask;
    }
    return self;
}

- (id)objectWithJSONObject:(id)obj targetClass:(Class)class
{
    if ([obj isKindOfClass:[NSDictionary class]]){
        return [self newObjectFromJSONDictionary:obj targetClass:class];
    }else if ([obj isKindOfClass:[NSArray class]]){
        return [self newArrayObjectFromJSONArray:obj targetClass:class];
        ///TODO:Need to add set processing
    }else{
        NSLog(@"Got object of type %@. That's not an NSArray or NSDictionary. Your code is bad and you should fix it. Returning nil for now, in the future this might cause a crash.", NSStringFromClass(class));
    }
    return nil;
}

- (id)objectWithString:(NSString *)objectString targetClass:(Class)class
{
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[objectString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error){
        [NSException raise:@"JSON string probably not properyly formed" format:@"JSON String: %@", objectString];
    }
    return [self objectWithJSONObject:jsonObject targetClass:class];
}

#pragma mark - JSON to Object utility methods, the guts of the transcoding
- (id)newArrayObjectFromJSONArray:(NSArray *)obj targetClass:(Class)class
{
    NSMutableArray *objectArray = [[NSMutableArray alloc] initWithCapacity:[obj count]];
    for (id object in obj) {
        id newObject = [self objectWithJSONObject:object targetClass:class];
        [objectArray addObject:newObject];
    }
    return objectArray;
}

//Collects the properties of the super classes then collects the current class', overwriting any duplicates with subclassed versions
- (NSMutableDictionary *)collectPropertiesOfClass:(Class)class
{
    unsigned count;
    NSMutableDictionary *collectedProperties = [[NSMutableDictionary alloc] init];
    objc_property_t *properties = class_copyPropertyList(class, &count);
    if ([class superclass] != [NSObject class]){
        NSLog(@"Super class:%@",[class superclass]);
        NSMutableDictionary *superProperties = [self collectPropertiesOfClass:[class superclass]];
        if (superProperties && [superProperties count]>0){
            [superProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [collectedProperties setObject:obj forKey:key];
            }];
        }
    }
    for (int i=0; i<count; i++) {
        const char *propertyProperties = property_getAttributes(properties[i]);
        NSString *propertiesString = [NSString stringWithUTF8String:propertyProperties];
        NSString *propertyNameKey = [NSString stringWithUTF8String:property_getName(properties[i])];
        [collectedProperties setObject:propertiesString forKey:propertyNameKey];
    }
    free(properties);
    return collectedProperties;
}




- (id)newObjectFromJSONDictionary:(NSDictionary *)obj targetClass:(Class)class
{
    id newObject = [[class alloc] init];
    NSDictionary *collectedProperties = [self collectPropertiesOfClass:class];
    if ([collectedProperties count]== 0 && obj){
        //I shouldn't have gotten here, maybe passing in NSDate will do it?
         [NSException raise:@"Class has no properties, can't deserialize" format:@"Class %@ missing properties", class];
    }
    if ([collectedProperties count]>0 && obj){
        NSArray *extras = [self reportExtraJSONFields:obj classProperties:collectedProperties];
        if ([extras count]>0){
            if ((optionMask & JLDeserializerReportMissingProperties) != NO)
            {
                NSLog(@"JSON object representing a %@ contained extra field(s):%@\n full object graph:\n%@", class, extras, obj);
            }
            if ((optionMask & JLDeserializerIgnoreMissingProperties) == NO)
            {
                [NSException raise:@"JSON to Object mismatch, JSON has extra fields" format:@"Class %@ missing properties: %@", class, extras];
            }
        }
    }
    NSDictionary *propertyNameMap = [class propertyNameMap];
    [collectedProperties enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *propertyProperties = value;
        NSString *JSONpropertyNameKey = [propertyNameMap objectForKey:key];
        NSString *objectPropertyName = key;
        //if we have no overrides, just assume JSON field names match property names
        if (!JSONpropertyNameKey)
        {
            JSONpropertyNameKey = key;
        }
        Class propertyType = [JLObjectMappingUtils classFromPropertyProperties:propertyProperties];
        if (!propertyType){
            if ([JLObjectMappingUtils isValueType:propertyProperties]){
                id propertyValue = [obj objectForKey:JSONpropertyNameKey];
                if (propertyValue){
                    [newObject setValue:propertyValue forKey:objectPropertyName];
                }
            }
        }else{
            [self transcodeProperty:obj
                 objectPropertyName:objectPropertyName
                   JSONpropertyName:JSONpropertyNameKey
                       propertyType:propertyType
                       owningObject:newObject];
        }
        
    }];
    [newObject didDeserialize:obj];
    return newObject;
}

#pragma mark - Object transcoding methods
- (void)transcodeArrayProperty:(NSArray *)array
            objectPropertyName:(NSString *)objectPropertyName
                  owningObject:(id)newObject
{
    if (array && [array count] >0){
        NSDictionary *propertyMappings = [[newObject class] propertyTypeMap];
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
        [newObject setValue:newArray forKey:objectPropertyName];
        Class arrayObjectType = [propertyMappings objectForKey:objectPropertyName];
        if (arrayObjectType){
            for (id someObject in array) {
                id object = [self objectWithJSONObject:someObject targetClass:arrayObjectType];
                [newArray addObject:object];
            }
        }else {
            if ((optionMask & JLDeserializerErrorOnAmbiguousType) != NO)
            {
                [NSException raise:@"Ambiguous array of objects, missing propertyTypeMap for property" format:@"Property name:%@", objectPropertyName];
            }
            for (id someObject in array) {
                if ([JLObjectMappingUtils isBasicType:someObject]){
                    [newArray addObject:someObject];
                }
            }
        }
    }
}

//Transcode a dictionary, either a JSON dictionary (appropriate for NSJSONSerialization) or a dictionary that contains model objects.
- (void)transcodeDictionaryProperty:(NSDictionary *)dict
                 objectPropertyName:(NSString *)objectPropertyName
                    dictionaryClass:(Class)type
                       owningObject:(id)newObject
{
    if (![type isSubclassOfClass:[NSDictionary class]])
    {
        id someObject = [self objectWithJSONObject:dict targetClass:type];
        [newObject setValue:someObject forKey:objectPropertyName];
    }
    else if (dict && [dict count] >0){
        NSDictionary *propertyMappings = [[newObject class] propertyTypeMap];
        NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
        [newObject setValue:newDictionary forKey:objectPropertyName];
        Class dictionaryObjectType = [propertyMappings objectForKey:objectPropertyName];
        if (!dictionaryObjectType)
        {
            //we've gone down the tree to the leaves and transcoded. Now just set objects.
            if ((optionMask & JLDeserializerErrorOnAmbiguousType) != NO)
            {
                [NSException raise:@"Ambiguous dictionary of objects, missing propertyTypeMap for property" format:@"Property name:%@", objectPropertyName];
            }
            dictionaryObjectType = type;
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([JLObjectMappingUtils isBasicType:obj]){
                    [newDictionary setObject:obj forKey:key];
                }else{
                    //if no, then we're hosed.
                    NSLog(@"Can't transcode object in dictionary with key:%@, no mapping defined", key);
                }
            }];
        }else{
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                id object = [self objectWithJSONObject:obj targetClass:dictionaryObjectType];
                [newDictionary setObject:object forKey:key];
            }];
        }
    }
}

/*
 Given a property name, the type it should be, and the parent who owns this property, it will transcode your jsonObject (array, or dictionary representation) into the expected property value
 */
- (void)transcodeProperty:(id)jsonObject
       objectPropertyName:(NSString *)objectPropertyName
         JSONpropertyName:(NSString *)JSONpropertyName
             propertyType:(Class)type
             owningObject:(id)newObject
{
    id propertyValue = [jsonObject objectForKey:JSONpropertyName];
    //bail on null
    if ([propertyValue isKindOfClass:[NSNull class]] || propertyValue == nil){
        [newObject setValue:nil forKey:objectPropertyName];
        return;
    }
    
    if ([propertyValue isKindOfClass:[NSArray class]]){
        [self transcodeArrayProperty:propertyValue
                  objectPropertyName:objectPropertyName
                        owningObject:newObject];
        
    }else if ([propertyValue isKindOfClass:[NSDictionary class]] && type){
        [self transcodeDictionaryProperty:propertyValue
                       objectPropertyName:objectPropertyName
                          dictionaryClass:type
                             owningObject:newObject];
        
    }else if ([type isSubclassOfClass:[NSDate class]]){
        NSDateFormatter *df = [[newObject class] dateFormatterForPropertyNamed:objectPropertyName];
        [newObject setValue:[df dateFromString:propertyValue] forKey:objectPropertyName];
        
    }else if ([JLObjectMappingUtils isBasicType:propertyValue]){
        [newObject setValue:propertyValue forKey:objectPropertyName];
        
    }else if (propertyValue){
        [self transcodeProperty:propertyValue
             objectPropertyName:objectPropertyName
               JSONpropertyName:JSONpropertyName
                   propertyType:type
                   owningObject:newObject];
    }else{
        if ((optionMask & JLDeserializerReportNilProperties) != NO)
        {
            NSLog(@"Expected property value for property %@ of type %@ had no matching property %@ in the JSON", objectPropertyName, JSONpropertyName, type);
        }
    }
}


#pragma mark - Reporting/Logging/Other options
/*
 If your JSON has more fields in it than you were expecting, this will report the extras (can happen with old app, new api)
 */
- (NSArray *)reportExtraJSONFields:(id)jsonObj classProperties:(NSDictionary *)collectedProperties
{
    NSMutableSet *jsonProperties;
    if (![jsonObj isKindOfClass:[NSDictionary class]]){
        NSLog(@"JSON object isn't a dictionary, can't report extra data from json. This will be an exception in the future. Please fix.");
        return nil;
    }
    //Might be able to remove this
    jsonProperties = [[NSMutableSet alloc] init];
    [collectedProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [jsonProperties addObject:key];
    }];
    //and just search through dictionary
    NSMutableArray *extras = [[NSMutableArray alloc] init];
    [(NSDictionary*)jsonObj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![jsonProperties containsObject:key]){
            [extras addObject:key];
        }
    }];
    return [extras copy];
}


#pragma mark - Deserialization options

- (BOOL)isReportTimers
{
    return optionMask & JLDeserializerReportTimers;
}

- (BOOL)isVerbose
{
    return optionMask & JLDeserializerVerboseOutput;
}

@end

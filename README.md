JLObjectMapping
===============

Simple JSON to object and object to JSON mapping inspired by Jackson JSON Processor for Java.


To start using, check out this project and add all the source files to your project.

Add the NSObject+JLJSONMapping.h category to your project's .pch file.

You're done. 



**To assist with serialization/deserialization, there are sevral methods in NSObject+JLJSONMapping.h you should know about:**

**\+ (NSDictionary *)propertyTypeMap;**
Implement this method in your model object if your objects have properties that are arrays or dictionaries. This is because you'll need to tell the deserializer what class you expect the objects to be when it's done. An example would be if you have an NSArray named "people". A single person might be a JLPerson object. So you'd return: @{@"people":[JLPerson class]} from this method.

 
**\+ (NSDictionary *)propertyNameMap;**
Implement this method if your JSON objects have properties that map to different names on your model object. An example would be if you have a property on your model named "firstname" but the JSON representation was "first", you'd return: @{@"firstname":@"first"} from this method.
Note: This particular feature only currently supports mapping JSON fields to differently named object properties during deserialization.


**\+ (NSDateFormatter *)dateFormatterForPropertyNamed:(NSString*)propertyName;**
Implement this method if you pass dates around. Right now only passing dates as a string is supported (not as a Long, yet). Return a dateformatter object you that matches the date string you are expecting for the given property.
An example would be if you have a property named "endDate", you would return @{@"endDate":<my dateformatter here>}


**Serialization and Deserialization callbacks**
JLObjectMapping currently supports two callbacks:

**\-(void)didDeserialize:(NSDictionary *)jsonDictionary;** Called after a JSON object or JSONString was deserialized into an object. The receiving object is the new object created. 
This allows you to massage your date further, if needed.

**\-(void)willSerialize;** Called before serialization on the object you are about to serialize. This allows you to massage your data or do validation before serialization.


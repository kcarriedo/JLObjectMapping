//
//  JLTimer.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/23/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLTimer : NSObject

- (id)initWithStartTimerName:(NSString *)name;

//can be called multiple times, only responds with time between invocations after responding with time between start timer and first invocation
- (void)recordTime:(NSString *) message;

//call at the end if you called recordTime multiple times for elapsed time.
- (CFAbsoluteTime)totalElapsedTime;//call at the end if you called recordTime multiple times for elapsed time.
@end

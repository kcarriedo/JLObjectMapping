//
//  JLTimer.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/23/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLTimer.h"

@implementation JLTimer
{
    NSString *_timerName;
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _totalTime;
}

- (id)initWithStartTimerName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _totalTime = 0.0f;
        _timerName = name;
        _startTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"Timer: %@, Start", name);
    }
    return self;
}

- (void)recordTime:(NSString *)message
{
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime taskTime = (endTime - _startTime);
    _totalTime += taskTime;
    if (message)
    {
        NSLog(@"Timer: %@, %f,%@", _timerName, taskTime, message);
    } else{
        NSLog(@"Timer: %@, %f", _timerName, taskTime);
    }
    //reset for next recording
    _startTime = endTime;
}

- (CFAbsoluteTime)totalElapsedTime
{
    return _totalTime;
}

@end

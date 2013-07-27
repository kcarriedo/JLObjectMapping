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
    NSString *timerName;
    CFAbsoluteTime startTime;
    CFAbsoluteTime totalTime;

}

- (id)initWithStartTimerName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        totalTime = 0.0f;
        timerName = name;
        startTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"Timer: %@, Start", name);
    }
    return self;
}

- (void)recordTime:(NSString *) message
{
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime taskTime = (endTime - startTime);
    totalTime += taskTime;
    if (message)
    {
        NSLog(@"Timer: %@, %f,%@", timerName, taskTime, message);
    } else{
        NSLog(@"Timer: %@, %f", timerName, taskTime);
    }
    //reset for next recording
    startTime = endTime;
}

- (CFAbsoluteTime) totalElapsedTime
{
    return totalTime;
}

@end

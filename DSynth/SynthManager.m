//
//  SynthManager.m
//  DSynth3
//
//  Created by David Kendall on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SynthManager.h"

@implementation SynthManager
@synthesize activeNotes = _activeNotes;
@synthesize scaleGen = _scaleGen;

- (id)init {
    self = [super init];
    if (self) {
        self.scaleGen = [NSMutableArray arrayWithObjects:
                         [NSNumber numberWithFloat:8.0], 
                         [NSNumber numberWithFloat:9.0], 
                         [NSNumber numberWithFloat:10.0], 
                         [NSNumber numberWithFloat:11.0], 
                         [NSNumber numberWithFloat:12.0],
                         [NSNumber numberWithFloat:14.0], 
                         nil];

        self.activeNotes = [[NSMutableArray alloc] init];
        centerFreq = 440.0;
        dispatcher = [[PdDispatcher alloc] init];
        [PdBase setDelegate:dispatcher];
        void *patch = [PdBase openFile:@"dsynth.pd" path:[[NSBundle mainBundle] resourcePath]];
        if (!patch) {
            NSLog(@"failed to open patch");
        }
        
    }
    
    return self;
}

- (void)sendScaleToPd {
    int numNotes = pow([self.scaleGen count], 2);
    float tratios[numNotes];
    int i = 0;
    for (NSNumber *uval in self.scaleGen) {
        for (NSNumber *oval in self.scaleGen) {
            tratios[i] = [oval floatValue] / [uval floatValue];
            ++i;
        }
    }
    [PdBase copyArray:tratios toArrayNamed:@"freqtable" withOffset:0 count:numNotes];
}

- (void)noteOn:(int)noteNum {
    bool fresh = YES;
    // don't start a new note on if that note is already active
    
    for (NSNumber *num in self.activeNotes) {
        if ([num intValue] == noteNum) {
            fresh = NO;
        }
    }
    if (fresh) {
        [self.activeNotes addObject:[NSNumber numberWithInt:noteNum]];
        [PdBase sendFloat:noteNum toReceiver:@"note"];
        [PdBase sendFloat:1.0 toReceiver:@"gate"];
        
    }
    else {
        NSLog(@"Getting a duplicate note on!!!");
    }
    
}

- (void)noteOff:(int)noteNum {
    int count = [self.activeNotes count];
    for (int i =0; i < count; ++i) {
        if ([[self.activeNotes objectAtIndex:i] intValue] == noteNum) {
            [self.activeNotes removeObjectAtIndex:i];
            [PdBase sendFloat:noteNum toReceiver:@"note"];
            [PdBase sendFloat:0.0 toReceiver:@"gate"];
            
            --i;
            --count;
        }
    }
    
    
    
}

- (void)setScaleGenValue:(NSNumber *)value atIndex:(NSUInteger)index {
    [self.scaleGen replaceObjectAtIndex:index withObject:value];
    [self sendScaleToPd];
}
@end

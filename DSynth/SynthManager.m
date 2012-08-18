//
//  SynthManager.m
//  DSynth3
//
//  Created by David Kendall on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SynthManager.h"

@implementation SynthManager
@synthesize activeNotes;
@synthesize scaleGen;

- (id)init {
    self = [super init];
    if (self) {
        self.scaleGen = [NSArray arrayWithObjects:
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

- (void)setScale:(NSArray *)scale {
    // this will be where the scale is built dynamically, eventually. just run on init now.
    NSLog(@"initializing the pitch array");
    int numNotes = [scale count];
    float tratios[numNotes];
    
    for (int i = 0; i < numNotes; ++i) {
        tratios[i] = [[scale objectAtIndex:i] floatValue];
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

@end

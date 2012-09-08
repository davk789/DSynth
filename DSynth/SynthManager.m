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
@synthesize centerPitch = _centerPitch;
@synthesize synthPresets = _synthPresets;

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
        self.centerPitch = [NSNumber numberWithFloat:60.0];
        self.synthPresets = [[NSMutableDictionary alloc] init];
        dispatcher = [[PdDispatcher alloc] init];
        [PdBase setDelegate:dispatcher];
//        [dispatcher addListener:self forSource:@"test"];
        void *patch = [PdBase openFile:@"dsynth.pd" path:[[NSBundle mainBundle] resourcePath]];
        if (!patch) {
            NSLog(@"failed to open patch");
        }
        
    }
    [self initSynthPresets];
    
    return self;
}

- (void)initSynthPresets {
    NSDictionary *clarinet = [[NSDictionary alloc]
                              initWithObjectsAndKeys:
                              [NSNumber numberWithFloat:0.0],
                              @"aa",
                              [NSNumber numberWithFloat:85.0],
                              @"ab",
                              [NSNumber numberWithFloat:65.0],
                              @"ac",
                              [NSNumber numberWithFloat:0.0],
                              @"ba",
                              [NSNumber numberWithFloat:0.0],
                              @"bb",
                              [NSNumber numberWithFloat:0.0],
                              @"bc",
                              [NSNumber numberWithFloat:0.0],
                              @"ca",
                              [NSNumber numberWithFloat:0.0],
                              @"cb",
                              [NSNumber numberWithFloat:0.0],
                              @"cc",
                              [NSNumber numberWithFloat:0.5],
                              @"trA",
                              [NSNumber numberWithFloat:1.0],
                              @"trB",
                              [NSNumber numberWithFloat:3.0],
                              @"trC",
                              [NSNumber numberWithFloat:42.0],
                              @"att",
                              [NSNumber numberWithFloat:235.0],
                              @"dec",
                              [NSNumber numberWithFloat:0.7],
                              @"sus",
                              [NSNumber numberWithFloat:235.0],
                              @"rel",
                              nil];
    [self.synthPresets setObject:clarinet forKey:@"Clarinet"];
    
    NSDictionary *oboe = [[NSDictionary alloc]
                              initWithObjectsAndKeys:
                              [NSNumber numberWithFloat:0.0],
                          @"aa",
                              [NSNumber numberWithFloat:95.0],
                          @"ab",
                              [NSNumber numberWithFloat:100.0],
                          @"ac",
                              [NSNumber numberWithFloat:0.0],
                          @"ba",
                              [NSNumber numberWithFloat:0.0],
                          @"bb",
                              [NSNumber numberWithFloat:0.0],
                          @"bc",
                              [NSNumber numberWithFloat:0.0],
                          @"ca",
                              [NSNumber numberWithFloat:500.0],
                          @"cb",
                              [NSNumber numberWithFloat:0.0],
                          @"cc",
                              [NSNumber numberWithFloat:1.0],
                          @"trA",
                              [NSNumber numberWithFloat:1.0],
                          @"trB",
                              [NSNumber numberWithFloat:1.5],
                          @"trC",
                              [NSNumber numberWithFloat:44.0],
                          @"att",
                              [NSNumber numberWithFloat:114.0],
                          @"dec",
                              [NSNumber numberWithFloat:0.7],
                          @"sus",
                              [NSNumber numberWithFloat:193.0],
                          @"rel",
                          nil];
    [self.synthPresets setObject:oboe forKey:@"Oboe"];

    NSDictionary *bell = [[NSDictionary alloc]
                          initWithObjectsAndKeys:
                          [NSNumber numberWithFloat:0.0],
                          @"aa",
                          [NSNumber numberWithFloat:119.0],
                          @"ab",
                          [NSNumber numberWithFloat:52.0],
                          @"ac",
                          [NSNumber numberWithFloat:0.0],
                          @"ba",
                          [NSNumber numberWithFloat:0.0],
                          @"bb",
                          [NSNumber numberWithFloat:0.0],
                          @"bc",
                          [NSNumber numberWithFloat:0.0],
                          @"ca",
                          [NSNumber numberWithFloat:44.0],
                          @"cb",
                          [NSNumber numberWithFloat:0.0],
                          @"cc",
                          [NSNumber numberWithFloat:1.0],
                          @"trA",
                          [NSNumber numberWithFloat:2.97],
                          @"trB",
                          [NSNumber numberWithFloat:4.243],
                          @"trC",
                          [NSNumber numberWithFloat:15.0],
                          @"att",
                          [NSNumber numberWithFloat:2000.0],
                          @"dec",
                          [NSNumber numberWithFloat:0.0],
                          @"sus",
                          [NSNumber numberWithFloat:200.0],
                          @"rel",
                          nil];
    [self.synthPresets setObject:bell forKey:@"Bell"];}

- (void)setCenterPitch:(NSNumber *)centerPitch {
    _centerPitch = centerPitch;
    float clipPitch = MAX(MIN([centerPitch floatValue], 127.0), 0.0);
    [PdBase sendFloat:clipPitch toReceiver:@"pitch"];
}

- (void)sendScaleToPd {
    int numNotes = pow([self.scaleGen count], 2);
    float tratios[numNotes];
    int i = 0;
    for (NSNumber *uval in self.scaleGen) {
        for (NSNumber *oval in self.scaleGen) {
            NSArray *ratio = [[[NSArray alloc] initWithObjects:oval, uval, nil] transposeToOctaveRange:1.0];
            tratios[i] = [[ratio objectAtIndex:0] floatValue] / [[ratio objectAtIndex:1] floatValue];
            ++i;
        }
    }

    [PdBase sendFloat:numNotes toReceiver:@"arraysize"];
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

- (void)loadSynthPresetNamed:(NSString *)name {
    NSDictionary *preset = [self.synthPresets objectForKey:name];
    if (preset != nil) {
        NSLog(@"sending the preset for %@", name);
        for (NSString *key in [preset allKeys]) {
            NSLog(@"getting param key %@", key);
            float val = [[preset objectForKey:key] floatValue];
            [PdBase sendFloat:val toReceiver:key];
        }
    }
    else {
        NSLog(@"couldn't get the preset");
    }
}

@end

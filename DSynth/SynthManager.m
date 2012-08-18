//
//  SynthManager.m
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SynthManager.h"

@implementation SynthManager

@synthesize scaleGen;


- (id)init {
    self = [super init];
    if (self) {
        // do the init
        self.scaleGen = [NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:8.0], 
                         [NSNumber numberWithFloat:9.0], 
                         [NSNumber numberWithFloat:10.0], 
                         [NSNumber numberWithFloat:11.0], 
                         [NSNumber numberWithFloat:12.0],
                         [NSNumber numberWithFloat:14.0], 
                         nil];

        
    }
    return self;
}

@end

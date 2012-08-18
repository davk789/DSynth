//
//  SynthManager.h
//  DSynth3
//
//  Created by David Kendall on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdDispatcher.h"


@interface SynthManager : NSObject {
    float centerFreq;
    PdDispatcher *dispatcher;
}

@property (strong, nonatomic) NSMutableArray *activeNotes;
@property (strong, nonatomic) NSArray *scaleGen;

- (void)setScale:(NSArray *)scale;
- (void)noteOn:(int)noteNum;
- (void)noteOff:(int)noteNum;

@end

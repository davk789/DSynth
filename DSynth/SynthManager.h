//
//  SynthManager.h
//  DSynth3
//
//  Created by David Kendall on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdDispatcher.h"
#import "DSynthAdditions.h"


@interface SynthManager : NSObject {
    PdDispatcher *dispatcher;

}

@property (strong, nonatomic) NSMutableArray *activeNotes;
@property (strong, nonatomic) NSMutableArray *scaleGen;
@property (strong, nonatomic) NSNumber *centerPitch;

- (void)sendScaleToPd;
- (void)noteOn:(int)noteNum;
- (void)noteOff:(int)noteNum;
- (void)setScaleGenValue:(NSNumber *)value atIndex:(NSUInteger)index;

@end

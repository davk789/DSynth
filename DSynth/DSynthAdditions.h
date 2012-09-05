//
//  NSObject+DSynthAdditions.h
//  DSynth
//
//  Created by David Kendall on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber(DSynthAdditions)
+ (NSNumber *)getDistanceFromX:(NSNumber *)x y:(NSNumber *)y toX:(NSNumber *)dx y:(NSNumber *)dy;
- (NSNumber *)greatestCommonDivisor:(NSNumber *)num;
@end

@interface NSArray(DSynthAdditions)
- (NSArray *)reduceFraction;
- (NSArray *)transposeToOctaveRange:(int)range;
@end



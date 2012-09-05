//
//  NSObject+DSynthAdditions.m
//  DSynth
//
//  Created by David Kendall on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DSynthAdditions.h"


@implementation NSNumber(DSynthAdditions)
+ (NSNumber *)getDistanceFromX:(NSNumber *)x y:(NSNumber *)y toX:(NSNumber *)xx y:(NSNumber *)xy {
    float dx = abs([xx  floatValue] - [x floatValue]);
    float dy = abs([xy  floatValue] - [y floatValue]);
    float distance = sqrt(pow(dx, 2.0) + pow(dy, 2.0));
    return [NSNumber numberWithFloat:distance];
}

- (NSNumber *)greatestCommonDivisor:(NSNumber *)num {
    int b = [self intValue];
    int a = [num intValue];
    int rem;
    while (b != 0) {
        rem = a % b;
        a = b;
        b = rem;
    }
    return [NSNumber numberWithInt:a];
}
@end

@implementation NSArray(DSynthAdditions)
- (NSArray *)transposeToOctaveRange:(int)range {
    // self == an array (size:2) representing a fraction
    // no error handling here so expect blowups if the array doesn't have the proper data
    float numer = [[self objectAtIndex:0] floatValue];
    float denom = [[self objectAtIndex:1] floatValue];
    float ratio = numer / denom;
    
    float frange = powf(2.0, (float)range);
    if (ratio > frange) {
        while (ratio > frange) {
            denom *= 2.0;
            ratio = numer / denom;
        }
    }
    
    frange = 1.0 / frange;
    if (ratio < frange) {
        while (ratio < frange) {
            numer *= 2.0;
            ratio = numer / denom;
        }
    }
    
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:numer], [NSNumber numberWithFloat:denom], nil];
    
}
- (NSArray *)reduceFraction {
    // self ==  an array (size 2) representing a fraction
    // return a numerator and denominator reduced to to between range and range*2
    // make sure there are two numbers at the start of this array
    int numer;
    int denom;
    int gcd;
    if ([[self objectAtIndex:0] isKindOfClass:[NSNumber class]] && [[self objectAtIndex:1] isKindOfClass:[NSNumber class]]) {
        gcd = [[[self objectAtIndex:0] greatestCommonDivisor:[self objectAtIndex:1]] intValue];
        numer = [[self objectAtIndex:0] intValue] / gcd;
        denom = [[self objectAtIndex:1] intValue] / gcd;
        
        
    }
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:numer],
            [NSNumber numberWithInt:denom], 
            nil];
}
@end


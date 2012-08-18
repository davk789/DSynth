//
//  KeyboardViewController.m
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeyboardViewController.h"

#pragma mark - additions

@interface NSNumber(DSynthAdditions)
+ (NSNumber*)getDistanceFromX:(NSNumber*)x y:(NSNumber*)y toX:(NSNumber*)dx y:(NSNumber*)dy;
@end
@implementation NSNumber(DSynthAdditions)
+ (NSNumber*)getDistanceFromX:(NSNumber*)x y:(NSNumber*)y toX:(NSNumber*)xx y:(NSNumber*)xy {
    float dx = abs([xx  floatValue] - [x floatValue]);
    float dy = abs([xy  floatValue] - [y floatValue]);
    float distance = sqrt(pow(dx, 2.0) + pow(dy, 2.0));
    return [NSNumber numberWithFloat:distance];
}
@end


@implementation KeyboardViewController

@synthesize synthManager = _synthManager;

#pragma mark -

- (void)generateKeysFromScaleGen:(NSArray *)gen {
    // root on the bottom, otonality right, utonality left
    int xb = 512; // base loc for x
    int yb = 600
    ;
    for (NSNumber *uval in gen) {
        int y = yb;
        int x = xb;
        for (NSNumber *oval in gen) {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key-off.png"]];
            CGRect bounds = CGRectMake(0.0, 0.0, 115.0, 100.0); 
            CGPoint center = CGPointMake(x, y);
            image.bounds = bounds;
            image.center = center;
            [self.view addSubview:image];
            [keyViews addObject:image];
            
            UILabel *label = [[UILabel alloc] initWithFrame:bounds];
            label.center = CGPointMake(x, y);
            label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            label.textAlignment = UITextAlignmentCenter;
            
            [label setText:[NSString stringWithFormat:@"%i / %i", [oval intValue], [uval intValue]]];
            [self.view addSubview:label];
            
            x += 88;
            y -= 50;
        }
        xb -= 88;
        yb -= 50;
    }

}

- (NSArray *)getActiveNotesForLocationX:(int)x y:(int)y {
    /* return an array with all notes triggered from x, y */
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    int count = [keyViews count];
    
    for (int i = 0; i < count; ++i) {
        CGPoint loc = [[keyViews objectAtIndex:i] center];
        NSNumber *distance = [NSNumber 
                              getDistanceFromX:[NSNumber numberWithInt:x] 
                              y:[NSNumber numberWithInt:y] 
                              toX:[NSNumber numberWithFloat:loc.x]
                              y:[NSNumber numberWithFloat:loc.y]];
        if ([distance floatValue] < 58.0) {
            [notes addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return notes;
}

- (NSArray *)getInactiveNotes:(NSArray *)notes {
    NSMutableArray *prevNotes = [[NSMutableArray alloc] initWithArray:self.synthManager.activeNotes copyItems:YES];
    
    for (NSNumber *note in notes) {
        int count = [prevNotes count];
        int num = [note intValue];
        for (int i = 0; i < count; ++i) {
            int pnum = [[prevNotes objectAtIndex:i] intValue];
            if (num == pnum) {
                [prevNotes removeObjectAtIndex:i];
                --count;
                --i;
            }
        }
    }
    
    return prevNotes;
    
}

- (void)keyDown:(NSNumber *)num {
    UIImageView *im = [keyViews objectAtIndex:[num intValue]];
    im.image = [UIImage imageNamed:@"key-on.png"];
    [self.synthManager noteOn:[num intValue]];
}

- (void)keyUp:(NSNumber *)num {
    UIImageView *im = [keyViews objectAtIndex:[num intValue]];
    im.image = [UIImage imageNamed:@"key-off.png"];
    [self.synthManager noteOff:[num intValue]];
    
}

#pragma mark - touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (![activeTouches containsObject:touch]) {
            [activeTouches addObject:touch];
            CGPoint point = [touch locationInView:self.view];
            
            NSArray *notes = [self getActiveNotesForLocationX:point.x y:point.y];
            for (NSNumber *num in notes) {
                bool isPlaying = NO;
                for (NSNumber *active in self.synthManager.activeNotes) {
                    if ([active intValue] == [num intValue]) {
                        isPlaying = YES;
                    }
                }
                if (!isPlaying) {
                    [self keyDown:num];
                }
            }
        }
        //
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if ([activeTouches containsObject:touch]) {
            CGPoint location = [touch locationInView:self.view];
            NSArray *notes = [self getActiveNotesForLocationX:location.x y:location.y];
            for (NSNumber *num in notes) {
                [self keyUp:num];
            }
            [activeTouches removeObject:touch];
        }
    }
    
    // force note offs for all other notes if this is the last touch up
    if ([[event allTouches] count] == [touches count]) {
        NSArray *leftovers = [[NSArray alloc] initWithArray:self.synthManager.activeNotes copyItems:TRUE];
        if ([leftovers count] > 0) {
            for (NSNumber *num in leftovers) {
                [self keyUp:num];
            }
        }
    }
    
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *notes = [[NSArray alloc] initWithArray:self.synthManager.activeNotes copyItems:TRUE];
    for (NSNumber *note in notes) {
        [self keyUp:note];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if ([activeTouches containsObject:touch]) {
            CGPoint currLoc = [touch locationInView:self.view];
            CGPoint prevLoc = [touch previousLocationInView:self.view];
            
            NSArray *newNotes = [self getActiveNotesForLocationX:currLoc.x y:currLoc.y];
            NSArray *oldNotes = [self getActiveNotesForLocationX:prevLoc.x y:prevLoc.y];
            
            for (NSNumber *newNote in newNotes) {
                bool noMatch = YES;
                for (NSNumber *oldNote in oldNotes) {
                    if ([newNote intValue] == [oldNote intValue]) {
                        noMatch = NO;
                    }
                }
                
                if (noMatch) {
                    [self keyDown:newNote];
                }
            }
            
            // from the old notes, one can get the offnotes and the holdnotes
            for (NSNumber *oldNote in oldNotes) {
                bool hasMatch = NO;
                for (NSNumber *newNote in newNotes) {
                    if ([newNote intValue] == [oldNote intValue]) {
                        hasMatch = YES;
                    }
                }
                if (!hasMatch) {
                    [self keyUp:oldNote];
                } // if match, it's a hold note
            }
        }
    }
}


#pragma mark - inherited methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor alloc] initWithRed:0.33 green:0.33 blue:0.33 alpha:1.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end

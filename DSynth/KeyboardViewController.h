//
//  KeyboardViewController.h
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SynthManager.h"
#import "TuningSelectorViewController.h"

@interface KeyboardViewController : UIViewController <TuningSelectorDelegate> {
    NSMutableArray *keyViews;
    NSMutableArray *activeTouches;
}

@property (strong, nonatomic) TuningSelectorViewController *tuningSelect;
@property (strong, nonatomic) UIPopoverController *tuningSelectPopover;
@property (strong, nonatomic) SynthManager *synthManager;


- (void)generateKeysFromScaleGen:(NSArray *)gen;

- (NSArray *)getActiveNotesForLocationX:(int)x y:(int)y;
- (NSArray *)getInactiveNotes:(NSArray *)notes;

- (void)keyDown:(NSNumber *)num;
- (void)keyUp:(NSNumber *)num;

- (IBAction)setTuningButtonTapped:(id)sender;

@end

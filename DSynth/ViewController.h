//
//  ViewController.h
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SynthManager.h"
#import "TuningSelectorViewController.h"

@interface ViewController : UIViewController <TuningSelectorDelegate, UITextFieldDelegate> {
    NSMutableArray *keyViews;
    NSMutableArray *keyLabels;
    NSMutableArray *activeTouches;
    NSMutableArray *tuningTextFields;
    BOOL toolbarHidden;
}

@property (strong, nonatomic) TuningSelectorViewController *tuningSelect;
@property (strong, nonatomic) UIPopoverController *tuningSelectPopover;
@property (strong, nonatomic) SynthManager *synthManager;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIButton *toolbarButton;


- (void)generateKeysFromScaleGen:(NSArray *)gen;
- (void)makeScaleGenTextFields:(NSArray *)gen;

- (NSArray *)getActiveNotesForLocationX:(int)x y:(int)y;
- (NSArray *)getInactiveNotes:(NSArray *)notes;

- (void)keyDown:(NSNumber *)num;
- (void)keyUp:(NSNumber *)num;

- (IBAction)setTuningButtonTapped:(id)sender;
- (IBAction)hideToolbarButtonTapped:(id)sender;

@end

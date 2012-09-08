//
//  ViewController.m
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 THIS VIEW CONTROLLER HAS ALL THE SETTINGS CONTROLS AS WELL AS THE KEYBOARD
 */

#import "ViewController.h"

#pragma mark - additions


#pragma mark -

@implementation ViewController

@synthesize synthManager = _synthManager;
@synthesize settingsManager = _settingsManager;

@synthesize tuningSelect = _tuningSelect;
@synthesize tuningSelectPopover = _tuningSelectPopover;
@synthesize synthSelect = _synthSelect;
@synthesize synthSelectPopover = _synthSelectPopover;

@synthesize pitchField = _pitchField;
@synthesize numStepsField = _numStepsField;

@synthesize toolbar = _toolbar;

- (NSArray *)getActiveNotesForLocationX:(int)x y:(int)y {
    /* return an array with all notes triggered from x, y */
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    int count = [keyViews count];
    
    int numNotes = MAX([self.synthManager.scaleGen count], 1);
    int det = 348 / numNotes;// 58 * 6 = 348 
    
    for (int i = 0; i < count; ++i) {
        CGPoint loc = [[keyViews objectAtIndex:i] center];
        NSNumber *distance = [NSNumber 
                              getDistanceFromX:[NSNumber numberWithInt:x] 
                              y:[NSNumber numberWithInt:y] 
                              toX:[NSNumber numberWithFloat:loc.x]
                              y:[NSNumber numberWithFloat:loc.y]];
        if ([distance floatValue] < det) {
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

#pragma mark view creation methods

- (void)makeScaleGenTextFields:(NSArray *)gen {
    if ([tuningTextFields count] > 0) {
        for (UITextField *text in tuningTextFields) {
            [text removeFromSuperview];
        }
        [tuningTextFields removeAllObjects];
    }
    
    float y = 45.0;
    int i = 1;
    for (NSNumber *val in gen) {
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(25.0, y, 40.0, 20.0)];
        
        field.text = [NSString stringWithFormat:@"%i", [val intValue]];
        field.backgroundColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        field.tag = i;
        field.delegate = self;
        
        [tuningTextFields addObject:field];
        
        [self.view addSubview:field];
        y += 25.0;
        ++i;
    }
}

- (void)generateKeysFromScaleGen:(NSArray *)gen {
    // root on the bottom, otonality right, utonality left
    int xb = 512; // base loc for x
    int yb = 615;
    int genCount = MAX([gen count], 1);
    int xStep = 528 / genCount; // 88 * 6 = 528
    int yStep = 300 / genCount; // 50 * 6 = 300
    int width = 690 / genCount;// 115 * 6 = 690
    int height = (600 / genCount) - 1;// 100 * 6 = 600
    
    if ([keyViews count] > 0) {
        for (UIImageView *view in keyViews) {
            [view removeFromSuperview];
        }
        [keyViews removeAllObjects];
    }
    
    if ([keyLabels count] > 0) {
        for (UILabel *label in keyLabels) {
            [label removeFromSuperview];
        }
        [keyLabels removeAllObjects];
    }
    
    for (NSNumber *uval in gen) {
        int y = yb;
        int x = xb;
        for (NSNumber *oval in gen) {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key-off.png"]];
            CGRect bounds = CGRectMake(0.0, 0.0, width, height); 
            CGPoint center = CGPointMake(x, y);
            image.bounds = bounds;
            image.center = center;
            
            [self.view addSubview:image];
            [keyViews addObject:image];
            
            UILabel *label = [[UILabel alloc] initWithFrame:bounds];
            label.center = CGPointMake(x, y);
            label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            label.textAlignment = UITextAlignmentCenter;
            [keyLabels addObject:label];
            
            NSArray *displayNums = [[[[NSArray alloc] initWithObjects:oval, uval, nil] transposeToOctaveRange:1] reduceFraction];
            [label setText:[NSString stringWithFormat:@"%i / %i", [[displayNums objectAtIndex:0] intValue], [[displayNums objectAtIndex:1] intValue]]];
            [self.view addSubview:label];
            
            x += xStep;
            y -= yStep;
        }
        xb -= xStep;
        yb -= yStep;
    }
    
}

#pragma mark touch

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


#pragma mark inherited methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    keyViews = [[NSMutableArray alloc] init];
    keyLabels = [[NSMutableArray alloc] init];
    activeTouches = [[NSMutableArray alloc] init];
    tuningTextFields = [[NSMutableArray alloc] init];

    
    self.view.backgroundColor = [[UIColor alloc] initWithRed:0.33 green:0.33 blue:0.33 alpha:1.0];
    self.view.multipleTouchEnabled = YES;
    
    // initialize the synth manager
    
    self.synthManager = [[SynthManager alloc] init];
    [self.synthManager sendScaleToPd];
    self.synthManager.centerPitch = [NSNumber numberWithFloat:60.0];
    // create the key UIImageViews
    [self generateKeysFromScaleGen:self.synthManager.scaleGen];
    // create the scale sequence text boxes
    [self makeScaleGenTextFields:self.synthManager.scaleGen];
    
    // initialize the settings manager
    
    self.settingsManager = [[SettingsManager alloc] init];
    self.settingsManager.delegate = self;
    
    // set keyboard types for textfields
    self.pitchField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.numStepsField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    // customize the toolbar appearance
    
    UIImage *toolBarIMG = [UIImage imageNamed: @"title-bar.png"];  
    
    if ([self.toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) { 
        // iOS 5.0+
        [self.toolbar setBackgroundImage:toolBarIMG forToolbarPosition:0 barMetrics:0]; 
    }
    else {
        // iOS 4.x-
        [self.toolbar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title-bar.png"]] atIndex:0];
    }

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || \
           (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark ibactions

- (IBAction)setSynthButtonTapped:(id)sender {
    if (self.synthSelect == nil) {
        self.synthSelect = [[SynthSelectorViewController alloc] initWithStyle:UITableViewStylePlain];
        self.synthSelect.delegate = self;
        self.synthSelect.synthPresets = [[NSMutableArray alloc] initWithArray:[self.synthManager.synthPresets allKeys]];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.synthSelect];
        self.synthSelect.navigationItem.title = @"Synth";
        
        self.synthSelectPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    }
    [self.synthSelectPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)setTuningButtonTapped:(id)sender {
    if (self.tuningSelect == nil) {
        // initialize the tuning select popover
        
        self.tuningSelect = [[TuningSelectorViewController alloc]  initWithStyle:UITableViewStylePlain];
        self.tuningSelect.delegate = self;

        // build the navigation controller
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.tuningSelect];
        self.tuningSelect.navigationItem.title = @"Tuning";        
        
        UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed)];
        UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonPressed)];
        
        [self.tuningSelect.navigationItem setLeftBarButtonItem:edit];
        [self.tuningSelect.navigationItem setRightBarButtonItem:save];
        
        self.tuningSelectPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    }
    
    [self.tuningSelectPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
}

- (IBAction)pitchOctaveUpTapped:(id)sender {
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    float val = [[f numberFromString:[self.pitchField text]] floatValue];
    val += 12.0;
        
    self.synthManager.centerPitch = [NSNumber numberWithFloat:val];
        
    NSString *disp = [[NSString alloc] initWithFormat:@"%.2f", val, nil];
    self.pitchField.text = disp;
}

- (IBAction)pitchOctaveDownTapped:(id)sender {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    float val = [[f numberFromString:[self.pitchField text]] floatValue];
    val -= 12.0;
    
    self.synthManager.centerPitch = [NSNumber numberWithFloat:val];
    
    NSString *disp = [[NSString alloc] initWithFormat:@"%.2f", val, nil];
    self.pitchField.text = disp;
}

- (IBAction)pitchNoteNumSet:(id)sender {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *val = [f numberFromString:[self.pitchField text]];
    
    if (val != nil) {
        float fval = [val floatValue];
        
        self.synthManager.centerPitch = [NSNumber numberWithFloat:fval];
        
        NSString *disp = [[NSString alloc] initWithFormat:@"%.2f", fval, nil];
        self.pitchField.text = disp;
    }
    else {
        NSNumber *pitch = self.synthManager.centerPitch;
        NSString *disp = [[NSString alloc] initWithFormat:@"%.2f", [pitch floatValue], nil];
        self.pitchField.text = disp;
    }

}

- (IBAction)numStepsSet:(id)sender {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *numSteps = [f numberFromString:[self.numStepsField text]];
    
    if (numSteps != nil) {
        NSMutableArray *scaleGen = [[NSMutableArray alloc] initWithArray:self.synthManager.scaleGen];
        int sizeDelta = [numSteps intValue] - [scaleGen count];
        
        if (sizeDelta >= 0) {
            NSNumber *defaultVal = [scaleGen lastObject];
            while (sizeDelta > 0) {
                [scaleGen addObject:[defaultVal copy]];
                --sizeDelta;
            }
        }
        else {
            while (sizeDelta < 0) {
                [scaleGen removeLastObject];
                ++sizeDelta;
            }
        }
        
        self.synthManager.scaleGen = scaleGen;
        [self.synthManager sendScaleToPd];
        
        NSLog(@"this is the new scalegen %@", self.synthManager.scaleGen);
        
        [self generateKeysFromScaleGen:self.synthManager.scaleGen];
        [self makeScaleGenTextFields:self.synthManager.scaleGen];
        
    }
    else {
        int numSteps = [self.synthManager.scaleGen count];
        NSString *disp = [[NSString alloc] initWithFormat:@"%d", numSteps, nil];
        self.numStepsField.text = disp;
    }
}

#pragma mark delegate methods

- (void)synthSelected:(NSString *)synth {
    [self.synthManager loadSynthPresetNamed:synth];
    [self.synthSelectPopover dismissPopoverAnimated:YES];
}

- (void)savePromptView:(SavePromptView *)saveView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"pressed button %d title %@", buttonIndex, [saveView enteredText]);
    [self.tuningSelectPopover dismissPopoverAnimated:YES];
    //[self.settingsManager savePresetWithName:@"test"];
}

- (void)saveButtonPressed {
    SavePromptView *prompt = [[SavePromptView alloc]
                              initWithPrompt:@"Save Preset" 
                              delegate:self 
                              cancelButtonTitle:@"Cancel" 
                              acceptButtonTitle:@"Save"];
    [prompt show];
}
- (void)editButtonPressed {
    NSLog(@"edit button pressed");
}

- (void)tuningSelected:(NSString *)tuning {
    NSLog(@"this is my tuning %@", tuning);
    [self.tuningSelectPopover dismissPopoverAnimated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    int ind = [textField tag] - 1;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *val = [f numberFromString:[textField text]];
    
    if (val != nil) {
        [self.synthManager setScaleGenValue:val atIndex:ind];
        [self generateKeysFromScaleGen:self.synthManager.scaleGen];
    }
    else {
        NSString *str = [NSString stringWithFormat:@"%i", [[self.synthManager.scaleGen objectAtIndex:ind] intValue]];
        [[tuningTextFields objectAtIndex:ind] setText:str];
    }
}

- (NSDictionary *)givePresetData {
    NSArray *keys = [[NSArray alloc] initWithObjects:@"tuningSeq", @"numSteps", @"centerPitch", nil];
    
    // values
    NSMutableArray *values = [[NSMutableArray alloc] init];
    // tuning seq
    NSMutableArray *tsvalues = [[NSMutableArray alloc] init];
    for (UITextField *field in tuningTextFields) {
        [tsvalues addObject:[field text]];
    }
    [values addObject:tsvalues];
    // num steps
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *val = [f numberFromString:[self.numStepsField text]];
    if (val != nil) {
        [values addObject:val];
    }
    // center pitch
    NSNumber *center = [f numberFromString:[self.pitchField text]];
    if (val != nil) {
        [values addObject:center];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    return result;
}

@end

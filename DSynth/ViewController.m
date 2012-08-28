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

@interface NSNumber(DSynthAdditions)
+ (NSNumber *)getDistanceFromX:(NSNumber *)x y:(NSNumber *)y toX:(NSNumber *)dx y:(NSNumber *)dy;
- (NSNumber *)greatestCommonDivisor:(NSNumber *)num;
@end
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

@interface NSArray(DSynthAdditions)
- (NSArray *)reduceFraction;
@end
@implementation NSArray(DSynthAdditions)
- (NSArray *)reduceFraction {
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

#pragma mark -

@implementation ViewController

@synthesize synthManager = _synthManager;
@synthesize tuningSelect = _tuningSelect;
@synthesize tuningSelectPopover = _tuningSelectPopover;
@synthesize toolbar = _toolbar;
@synthesize toolbarButton = _toolbarButton;

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

#pragma mark view creation methods

- (void)makeScaleGenTextFields:(NSArray *)gen {
    if ([tuningTextFields count] > 0) {
        for (UITextField *text in tuningTextFields) {
            [text removeFromSuperview];
        }
    }
    tuningTextFields = [[NSMutableArray alloc] init]; // is this a memory leak?
    
    float y = 25.0;
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
    int yb = 600;
    
    if ([keyViews count] > 0) {
        for (UIImageView *view in keyViews) {
            [view removeFromSuperview];
        }
        keyViews = [[NSMutableArray alloc] init];
    }
    
    if ([keyLabels count] > 0) {
        for (UILabel *label in keyLabels) {
            [label removeFromSuperview];
        }
        keyLabels = [[NSMutableArray alloc] init];
    }
    
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
            [keyLabels addObject:label];
            
            NSArray *displayNums = [[[NSArray alloc] initWithObjects:oval, uval, nil] reduceFraction];
            
            [label setText:[NSString stringWithFormat:@"%i / %i", [[displayNums objectAtIndex:0] intValue], [[displayNums objectAtIndex:1] intValue]]];
            [self.view addSubview:label];
            
            x += 88;
            y -= 50;
        }
        xb -= 88;
        yb -= 50;
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
    toolbarHidden = FALSE;

    
    self.view.backgroundColor = [[UIColor alloc] initWithRed:0.33 green:0.33 blue:0.33 alpha:1.0];
    self.view.multipleTouchEnabled = YES;
    
    self.synthManager = [[SynthManager alloc] init];
    [self.synthManager sendScaleToPd];
    
    // create the key UIImageViews
    [self generateKeysFromScaleGen:self.synthManager.scaleGen];

    // create the scale sequence text boxes
    [self makeScaleGenTextFields:self.synthManager.scaleGen];
    
    
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

#pragma mark IBActions

- (IBAction)setTuningButtonTapped:(id)sender {
    if (self.tuningSelect == nil) {
        //
        self.tuningSelect = [[TuningSelectorViewController alloc] initWithStyle:UITableViewStylePlain];
        self.tuningSelect.delegate = self;
        self.tuningSelectPopover = [[UIPopoverController alloc] initWithContentViewController:self.tuningSelect];
    }
    [self.tuningSelectPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
}

- (IBAction)hideToolbarButtonTapped:(id)sender {

    CGRect toolbarFrame = self.toolbar.frame;
    CGRect buttonFrame = self.toolbarButton.frame;
    [UIView beginAnimations:nil context:nil];
    
    if (!toolbarHidden) {
        toolbarFrame.origin.y += toolbarFrame.size.height;
        buttonFrame.origin.y += toolbarFrame.size.height;
        [self.toolbarButton setTitle:@"^" forState:UIControlStateNormal];
    }
    else {
        toolbarFrame.origin.y -= toolbarFrame.size.height;
        buttonFrame.origin.y -= toolbarFrame.size.height;
        [self.toolbarButton setTitle:@"v" forState:UIControlStateNormal];
    }
    self.toolbar.frame = toolbarFrame;
    self.toolbarButton.frame = buttonFrame;
    [UIView commitAnimations];

    toolbarHidden = !toolbarHidden;
}

#pragma mark delegate methods

- (void)tuningSelected:(NSString *)tuning {
    NSLog(@"this is my tuning %@", tuning);
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

@end

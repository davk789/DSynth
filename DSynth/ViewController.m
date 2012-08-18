//
//  ViewController.m
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize keyboardController = _keyboardController;
@synthesize settingsController = _settingsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	
    synthManager = [[SynthManager alloc] init];
    [synthManager sendScaleToPd];
    
    self.keyboardController = [[KeyboardViewController alloc] init];
    [self.keyboardController generateKeysFromScaleGen:synthManager.scaleGen];
    
    self.keyboardController.synthManager = synthManager;
    
    [self.view insertSubview:self.keyboardController.view atIndex:0];
    
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

#pragma mark - actions

- (IBAction)switchViews:(id)sender {
	[UIView beginAnimations:@"View Flip" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    if (self.settingsController.view.superview == nil) {
        
        if (self.settingsController == nil) {
            SettingsViewController *contr = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController"                   
                                                                                     bundle:nil];
            self.settingsController = contr;
        }

        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        
		[self.settingsController viewWillAppear:YES];
		[self.keyboardController viewWillDisappear:YES];
		
		[self.keyboardController.view removeFromSuperview];
		[self.view insertSubview:self.settingsController.view atIndex:0];
        
		[self.keyboardController viewDidDisappear:YES];
		[self.settingsController viewDidAppear:YES];
        
    } else {

        if (self.keyboardController == nil) {
            // this section will not be hit since the keyboard controller is created in
            // viewdidload
            KeyboardViewController *contr = [[KeyboardViewController alloc] init];
            self.keyboardController = contr;
            [self.keyboardController generateKeysFromScaleGen:synthManager.scaleGen];
        }
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        
		[self.keyboardController viewWillAppear:YES];
		[self.settingsController viewWillDisappear:YES];
		
		[self.settingsController.view removeFromSuperview];
		[self.view insertSubview:self.keyboardController.view atIndex:0];
        
		[self.settingsController viewDidDisappear:YES];
		[self.keyboardController viewDidAppear:YES];
    }
    [UIView commitAnimations];
    
}
@end

//
//  KeyboardViewController.m
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeyboardViewController.h"


@implementation KeyboardViewController

#pragma mark -

- (void)generateKeysFromScaleGen:(NSArray *)gen {
    int oi = 0;
    int ui = 0;

    for (NSNumber *uval in gen) {
        for (NSNumber *oval in gen) {
            
        }
    }
    

}

#pragma mark -

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

//
//  ViewController.h
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardViewController.h"
#import "SettingsViewController.h"
#import "SynthManager.h"

@interface ViewController : UIViewController {
    SynthManager *synthManager;
}

@property (strong, nonatomic) KeyboardViewController *keyboardController;
@property (strong, nonatomic) SettingsViewController *settingsController;
@property (strong, nonatomic) IBOutlet UIButton *settingsWindowButton;

- (IBAction)switchViews:(id)sender;


@end

//
//  SynthSelectorViewController.h
//  DSynth
//
//  Created by David Kendall on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SynthSelectorDelegate
- (void)synthSelected:(NSString *)synth;
@end

@interface SynthSelectorViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *synthPresets;
@property (strong, nonatomic) id<SynthSelectorDelegate> delegate;

@end

//
//  TuningSelectorViewController.h
//  DSynth
//
//  Created by David Kendall on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TuningSelectorDelegate
- (void)tuningSelected:(NSString *)tuning;
@end

@interface TuningSelectorViewController : UITableViewController

@property (strong, nonatomic) NSArray *tunings;
@property (assign, nonatomic) id<TuningSelectorDelegate> delegate;

@end

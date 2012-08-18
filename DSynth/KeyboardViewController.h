//
//  KeyboardViewController.h
//  DSynth
//
//  Created by David Kendall on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardViewController : UIViewController {
    NSMutableArray *scale;
}

- (void)generateKeysFromScaleGen:(NSArray *)gen;


@end

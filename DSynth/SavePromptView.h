//
//  SavePromptView.h
//  DSynth
//
//  Created by David Kendall on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SavePromptView;

@protocol SavePromptViewDelegate
- (void)savePromptView:(SavePromptView *)saveView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface SavePromptView : UIAlertView

@property (nonatomic, retain) UITextField *textField;

- (id)initWithPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle;
- (NSString *)enteredText;

@end

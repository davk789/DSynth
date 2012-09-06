//
//  SavePromptView.m
//  DSynth
//
//  Created by David Kendall on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SavePromptView.h"

@implementation SavePromptView

@synthesize textField = _textField;

- (id)initWithPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle {
    self = [super initWithTitle:prompt message:@"\n" delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil];
    if (self != nil) {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 31.0)];
        [theTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [theTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [theTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [theTextField setBackgroundColor:[UIColor whiteColor]];
        [theTextField setTextAlignment:UITextAlignmentLeft];
        [self addSubview:theTextField];
        self.textField = theTextField;
    }
    return self;
}

- (NSString *)enteredText {
    return self.textField.text;
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [self.delegate savePromptView:self clickedButtonAtIndex:buttonIndex];
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end

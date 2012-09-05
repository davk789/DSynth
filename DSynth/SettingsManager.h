//
//  SettingsManager.h
//  DSynth
//
//  Manage the user defaults and also the save files. i.e. all persistent data.
//
//  Created by David Kendall on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingsManagerDelegate
- (NSDictionary *)givePresetData; // the delegate needs to return a dict with strings or arrays of strings as the values
@end

@interface SettingsManager : NSObject

@property (assign, nonatomic) id<SettingsManagerDelegate> delegate;

- (BOOL)savePresetWithName:(NSString *)name;

@end

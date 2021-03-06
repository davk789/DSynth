//
//  SettingsManager.h
//  DSynth
//
//  Actually, more of a preset/persistent data manager.
//
//  Manage the user defaults and also the save files. i.e. all persistent data.
//
//  Created by David Kendall on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingsManagerDelegate
- (NSDictionary *)yieldPresetData; // the delegate needs to return a dict with strings or arrays of strings as the values
- (void)pushPresetData:(NSDictionary *)data;
@end

@interface SettingsManager : NSObject 

@property (assign, nonatomic) id<SettingsManagerDelegate> delegate;
@property (retain, nonatomic) NSDictionary *factoryPresets;

- (BOOL)savePresetWithName:(NSString *)name;

- (void)loadUserPreset:(NSString *)name;
- (void)loadFactoryPreset:(NSString *)name;

@end

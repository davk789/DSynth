//
//  SettingsManager.m
//  DSynth
//
//  Created by David Kendall on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager
@synthesize delegate = _delegate;
@synthesize factoryPresets = _factoryPresets;

- (id)init {
    self = [super init];
    if (self) {
        NSDictionary *partch = [[NSDictionary alloc]
                                  initWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:60.0],
                                  @"centerPitch", 
                                  [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:8.0],
                                   [NSNumber numberWithFloat:9.0],
                                   [NSNumber numberWithFloat:10.0],
                                   [NSNumber numberWithFloat:11.0],
                                   [NSNumber numberWithFloat:12.0],
                                   [NSNumber numberWithFloat:14.0], nil],
                                  @"tuningSeq", 
                                  @"Oboe", 
                                  @"synth", nil];
        NSDictionary *thirteen = [[NSDictionary alloc]
                                  initWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:72.0],
                                  @"centerPitch", 
                                  [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:8.0],
                                   [NSNumber numberWithFloat:9.0],
                                   [NSNumber numberWithFloat:10.0],
                                   [NSNumber numberWithFloat:11.0],
                                   [NSNumber numberWithFloat:12.0],
                                   [NSNumber numberWithFloat:13.0], 
                                   [NSNumber numberWithFloat:14.0], nil],
                                  @"tuningSeq", 
                                  @"Clarinet", 
                                  @"synth", nil];
        NSDictionary *fifteen = [[NSDictionary alloc]
                                 initWithObjectsAndKeys:
                                 [NSNumber numberWithFloat:60.0],
                                 @"centerPitch", 
                                 [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:8.0],
                                  [NSNumber numberWithFloat:9.0],
                                  [NSNumber numberWithFloat:10.0],
                                  [NSNumber numberWithFloat:11.0],
                                  [NSNumber numberWithFloat:12.0],
                                  [NSNumber numberWithFloat:13.0], 
                                  [NSNumber numberWithFloat:14.0],
                                  [NSNumber numberWithFloat:15.0], nil],
                                 @"tuningSeq", 
                                 @"Oboe", 
                                 @"synth", nil];
        NSDictionary *nineteen = [[NSDictionary alloc]
                                  initWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:60.0],
                                  @"centerPitch", 
                                  [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:10.0],
                                   [NSNumber numberWithFloat:11.0],
                                   [NSNumber numberWithFloat:12.0],
                                   [NSNumber numberWithFloat:13.0],
                                   [NSNumber numberWithFloat:14.0],
                                   [NSNumber numberWithFloat:15.0], 
                                   [NSNumber numberWithFloat:16.0],
                                   [NSNumber numberWithFloat:17.0],
                                   [NSNumber numberWithFloat:18.0],
                                   [NSNumber numberWithFloat:19.0], nil],
                                  @"tuningSeq", 
                                  @"Oboe", 
                                  @"synth", nil];
        self.factoryPresets = [[NSDictionary alloc]
                               initWithObjects:[NSArray arrayWithObjects:partch, thirteen, fifteen, nineteen, nil]
                               forKeys:[NSArray arrayWithObjects:
                                        @"Partch",
                                        @"13 Limit",
                                        @"15 Limit",
                                        @"19 Limit", nil]];
        
    }
    return self;
}



- (BOOL)savePresetWithName:(NSString *)name {

    NSDictionary *appState = [self.delegate yieldPresetData];
    BOOL result = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    
    if ([fileManager changeCurrentDirectoryPath:docsDir]) {
        result = [appState writeToFile:[name stringByAppendingString:@".plist"] atomically:YES];
        if (result) {
            NSLog(@"saved to %@ :\n%@", name, appState);
        }
        else {
            NSLog(@"could not save %@.plist", name);
        }

    }
    else {
        NSLog(@"couldn't change directory");
    }

    return result;
}

- (void)loadUserPreset:(NSString *)name {

}
// should I really be splitting all these load functions in to user and factory parts?
- (void)loadFactoryPreset:(NSString *)name {
    NSDictionary *data = [self.factoryPresets objectForKey:name];
    if (data != nil) {
        
    }
}


@end

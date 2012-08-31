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

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)savePresetWithName:(NSString *)name {
    
    NSDictionary *appState = [self.delegate givePresetData];
    
    NSLog(@"%@", appState);

}
/*
- (void)testDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    BOOL res = [fileManager changeCurrentDirectoryPath:docsDir];
    if (!res) {
        NSLog(@"couldn't change directory");
    }
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:@"." error:nil];
    NSLog(@"%@", fileList);
}*/

@end

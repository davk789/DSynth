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

- (BOOL)savePresetWithName:(NSString *)name {

    NSDictionary *appState = [self.delegate givePresetData];
    BOOL result = YES;
    /*   NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    BOOL result = NO;
    
    if ([fileManager changeCurrentDirectoryPath:docsDir]) {
        result = [appState writeToFile:[name stringByAppendingString:@".plist"] atomically:YES];*/
        NSLog(@"saved to %@ :\n%@", name, appState);    
    /*}
    else {
        NSLog(@"couldn't change directory");
    }*/

    return result;
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

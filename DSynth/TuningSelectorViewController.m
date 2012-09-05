//
//  TuningSelectorViewController.m
//  DSynth
//
//  Created by David Kendall on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TuningSelectorViewController.h"

#pragma mark -

@implementation TuningSelectorViewController

@synthesize tunings = _tunings;
@synthesize delegate = _delegate;

#pragma mark inherited methods

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(280.0, 450.0);
    
    NSArray *factoryTunings = [[NSArray alloc] initWithObjects:@"1 3 5 7 9 11", 
                               @"1 5 7 11 13 17 19 23",
                               @"8 9 10 11 12 14",
                               nil];
    NSArray *userTunings = [[NSMutableArray alloc] initWithObjects:@"foo", nil];
    headers = [[NSArray alloc] initWithObjects:@"Factory", @"User", nil];
    self.tunings = [[NSMutableArray alloc] initWithObjects:factoryTunings, userTunings, nil];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tunings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionList = [self.tunings objectAtIndex:section];
    return [sectionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tuning"];
        
        int lastInd = [indexPath length] - 1;
        if (lastInd >= 0) {
            if ([indexPath indexAtPosition:lastInd] == 0) {
                cell.backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            }
        }
    }
    
    NSLog(@"%i, %i l: %i", [indexPath indexAtPosition:0], [indexPath indexAtPosition:1], [indexPath length]);
    
    NSArray *tuningList = [self.tunings objectAtIndex:indexPath.section];
    NSString *tuning = [tuningList objectAtIndex:indexPath.row];
    cell.textLabel.text = tuning;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [headers objectAtIndex:section];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate != nil) {
        NSString *tuning = [self.tunings objectAtIndex:indexPath.row];
        [self.delegate tuningSelected:tuning];
        [self.delegate tuningPopoverFinished];
    }
}

@end

//
//  ColorsTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ColorsTVC.h"
#import "BeerCrushAppDelegate.h"

@implementation ColorsTVC

@synthesize colorsDict;
@synthesize selectedColorSRM;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		self.colorsDict=[appDelegate getColorsDictionary];
		self.title=NSLocalizedString(@"Colors",@"Title for Colors view controller");
    }
    return self;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.colorsDict objectForKey:@"colors"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSDictionary* colorInfo=[[self.colorsDict objectForKey:@"colors"] objectAtIndex:indexPath.row];

	UILabel* colorNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 30)] autorelease];
	colorNameLabel.font=[UIFont boldSystemFontOfSize:21];
	[cell.contentView addSubview:colorNameLabel];
	[colorNameLabel setText:[colorInfo objectForKey:@"name"]];

	if (self.selectedColorSRM==[[colorInfo objectForKey:@"srm"] integerValue])
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType=UITableViewCellAccessoryNone;
	
	// Put color swatch on the cell
	NSArray* rgbValues=[colorInfo objectForKey:@"rgb"];
	UIView* colorSwatch=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.rowHeight, tableView.rowHeight)] autorelease];
	colorSwatch.backgroundColor=[UIColor colorWithRed:[[rgbValues objectAtIndex:0] integerValue]/255.0 green:[[rgbValues objectAtIndex:1] integerValue]/255.0 blue:[[rgbValues objectAtIndex:2] integerValue]/255.0 alpha:1.0];
	[cell.contentView addSubview:colorSwatch];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[delegate colorsTVC:self didSelectColor:[[[[self.colorsDict objectForKey:@"colors"] objectAtIndex:indexPath.row] objectForKey:@"srm"] integerValue]];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[self.colorsDict release];
    [super dealloc];
}



@end


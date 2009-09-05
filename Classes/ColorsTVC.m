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

	UILabel* colorNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 30)];
	colorNameLabel.font=[UIFont boldSystemFontOfSize:21];
	[cell.contentView addSubview:colorNameLabel];
	[colorNameLabel setText:[colorInfo objectForKey:@"name"]];

	if (self.selectedColorSRM==[[[colorInfo objectForKey:@"@attributes"] objectForKey:@"srm"] integerValue])
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType=UITableViewCellAccessoryNone;
	
	// Put color swatch on the cell
	NSArray* rgbValues=[[colorInfo objectForKey:@"@attributes"] objectForKey:@"rgb"];
	UIView* colorSwatch=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.rowHeight, tableView.rowHeight)] autorelease];
	colorSwatch.backgroundColor=[UIColor colorWithRed:[[rgbValues objectAtIndex:0] integerValue]/255.0 green:[[rgbValues objectAtIndex:1] integerValue]/255.0 blue:[[rgbValues objectAtIndex:2] integerValue]/255.0 alpha:1.0];
	[cell.contentView addSubview:colorSwatch];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[delegate colorsTVC:self didSelectColor:[[[[[self.colorsDict objectForKey:@"colors"] objectAtIndex:indexPath.row] objectForKey:@"@attributes"] objectForKey:@"srm"] integerValue]];
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

/*
 Sample Colors doc:
 
<colors>
<color srm="2" srmmin="0" srmmax="2.4"><name>Pale Straw</name></color>
<color srm="3"  srmmin="2.5" srmmax="3.4"><name>Straw</name></color>
<color srm="4"  srmmin="3.4" srmmax="4.9"><name>Pale Gold</name></color>
<color srm="6"  srmmin="5" srmmax="7.4"><name>Deep Gold</name></color>
<color srm="9"  srmmin="7.5" srmmax="10.4"><name>Pale Amber</name></color>
<color srm="12" srmmin="10.5" srmmax="13.4"><name>Medium Amber</name></color>
<color srm="15" srmmin="13.5" srmmax="16.4"><name>Deep Amber</name></color>
<color srm="18" srmmin="16.5" srmmax="19.4"><name>Amber Brown</name></color>
<color srm="21" srmmin="19.5" srmmax="22.9"><name>Brown</name></color>
<color srm="24" srmmin="23" srmmax="26.9"><name>Ruby Brown</name></color>
<color srm="30" srmmin="27" srmmax="34.9"><name>Deep Brown</name></color>
<color srm="40" srmmin="35"><name>Black</name></color>
</colors>
*/



@end


//
//  FlavorsAromasTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FlavorsAromasTVC.h"
#import "BeerCrushAppDelegate.h"

@implementation FlavorsAromasTVC

@synthesize flavorsDictionary;
@synthesize delegate;

- (id)initWithFlavorSet:(NSDictionary*)flavorsDict {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStylePlain]) { // Ignores style argument
		self.title=@"Flavors & Aromas";
		if (flavorsDict==nil)
		{
			BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			self.flavorsDictionary=[del getFlavorsDictionary];
		}
		else
			self.flavorsDictionary=flavorsDict;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Put Done button on NavBar
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)] autorelease];
}

-(void)doneButtonClicked
{
	if ([self.delegate respondsToSelector:@selector(doneSelectingFlavors)])
		[self.delegate performSelector:@selector(doneSelectingFlavors)];
}

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
	return [[self.flavorsDictionary objectForKey:@"flavors"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSString* flavorid=[[[flavorsDictionary objectForKey:@"flavors"] objectAtIndex:indexPath.row] objectForKey:@"id"];
	[cell.textLabel setText:[[[flavorsDictionary objectForKey:@"flavors"] objectAtIndex:indexPath.row] objectForKey:@"title"]];
	
	// Turn on checkmark, if it's selected in the user's review
	NSArray* flavors=[delegate getCurrentFlavors];
	if ([flavors containsObject:flavorid])
	{
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	}

	
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return [[flavorsDictionary objectForKey:@"titles"] objectAtIndex:section];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSArray* flavors=[flavorsDictionary objectForKey:@"flavors"];
	
	if ([[flavors objectAtIndex:indexPath.row] objectForKey:@"flavors"]==nil)
	{
		// Put a checkmark on the row
		UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
		if (cell.accessoryType==UITableViewCellAccessoryCheckmark) // Currently selected
		{
			cell.accessoryType=UITableViewCellAccessoryNone;

			// Call delegate's didUnselectFlavor method
			if ([self.delegate respondsToSelector:@selector(didUnselectFlavor:)])
			{
				// Send the ID
				[delegate performSelector:@selector(didUnselectFlavor:) withObject:[[flavors objectAtIndex:indexPath.row] objectForKey:@"id"]];
			}
		}
		else
		{
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
		
			// Call delegate's didSelectFlavor method
			if ([self.delegate respondsToSelector:@selector(didSelectFlavor:)])
			{
				// Send the ID
				[delegate performSelector:@selector(didSelectFlavor:) withObject:[[flavors objectAtIndex:indexPath.row] objectForKey:@"id"]];
			}
		}
	}
	else 
	{
		// Navigate to another level
		FlavorsAromasTVC* fatvc=[[[FlavorsAromasTVC alloc] initWithFlavorSet:[flavors objectAtIndex:indexPath.row]] autorelease];
		fatvc.delegate=self.delegate;
		[self.navigationController pushViewController:fatvc animated:YES];
	}

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
	[flavorsDictionary release];
	
    [super dealloc];
}

@end


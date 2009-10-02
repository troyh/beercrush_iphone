//
//  StylesTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StylesListTVC.h"
#import "BeerCrushAppDelegate.h"

@implementation StylesListTVC

@synthesize stylesDictionary;
@synthesize selectedStyleIDs;
@synthesize delegate;

- (id)initWithStyleID:(NSDictionary*)styles {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		if (styles==nil)
			self.stylesDictionary=[appDelegate getStylesDictionary];
		else
			self.stylesDictionary=styles;
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
    return [[self.stylesDictionary objectForKey:@"styles"] count];
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//	NSMutableArray* a=[NSMutableArray arrayWithCapacity:32];
//	for (int i=0; i < [self.stylesList count]; i+=5) {
//		[a addObject:[[self.stylesNames objectForKey:[NSString stringWithFormat:@"%d",i+1]] substringToIndex:10]];
//	}
//	return a;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//	return index*5;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return [[[self.stylesDictionary objectForKey:@"names"] objectForKey:[NSString stringWithFormat:@"%d",section+1]] objectForKey:@"name"];
//}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

    if (indexPath.row < [[self.stylesDictionary objectForKey:@"styles"] count])
	{
		NSString* name=[[[self.stylesDictionary objectForKey:@"styles"] objectAtIndex:indexPath.row] objectForKey:@"name"];
		[cell.textLabel setText:name];
		
		NSString* styleID=[[[self.stylesDictionary objectForKey:@"styles"] objectAtIndex:indexPath.row] objectForKey:@"id"];
		if ([self.selectedStyleIDs containsObject:styleID])
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
		else
			cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row < [[self.stylesDictionary objectForKey:@"styles"] count])
	{
		NSArray* substyles=[[[self.stylesDictionary objectForKey:@"styles"] objectAtIndex:indexPath.row] objectForKey:@"styles"];
		if (substyles && [substyles isKindOfClass:[NSArray class]])
		{
			// Navigate to the next level of styles
			StylesListTVC* vc=[[[StylesListTVC alloc] initWithStyleID:[[self.stylesDictionary objectForKey:@"styles"] objectAtIndex:indexPath.row]] autorelease];
			vc.selectedStyleIDs=self.selectedStyleIDs;
			vc.delegate=self.delegate;
			[self.navigationController pushViewController:vc animated:YES];
		}
		else 
		{
			// For now, we only support selecting one style, so we'll remove any already set and replace them with the one the user just selected
			[self.selectedStyleIDs removeAllObjects];
			[self.selectedStyleIDs addObject:[self.stylesDictionary objectForKey:@"id"]];
			[delegate stylesTVC:self didSelectStyle:self.selectedStyleIDs];
		}
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
	[stylesDictionary release];
    [super dealloc];
}


@end


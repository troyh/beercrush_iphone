//
//  BrowseBrewersTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BrowseBrewersTVC.h"
#import "BeerCrushAppDelegate.h"
#import "BeerListTableViewController.h"

@implementation BrowseBrewersTVC

@synthesize breweryList;
@synthesize breweryGroups;
@synthesize currentElemValue;
@synthesize xmlParserPath;
@synthesize currentGroup;
@synthesize currentBrewery;

-(id)init
{
	// This must be UITableViewStylePlain because we have an index down the right side (iPhone OS requirement)
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		breweryList=nil;
		breweryGroups=nil;
		currentGroup=nil;
		currentBrewery=nil;
		
		currentElemValue=nil;
		xmlParserPath=nil;
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
	
	breweryList=[[NSMutableArray alloc] init];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(getBreweriesList:) object:nil withActivityHUD:YES andActivityHUDText:NSLocalizedString(@"HUD:GettingBrewery",@"Getting Brewery List")];

	[super viewWillAppear:animated];
}

-(void)getBreweriesList:(id)nothing
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate getBreweriesList];
	
	[appDelegate dismissActivityHUD];
}

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
    return [breweryGroups count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[breweryList objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	[cell.textLabel setText:[[[breweryList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"]];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [breweryGroups objectAtIndex:section];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	BeerListTableViewController* bltvc=[[[BeerListTableViewController alloc] initWithBreweryID:[[[breweryList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id"]] autorelease];
	bltvc.setRightBarButtonItem=NO;
	[self.navigationController pushViewController:bltvc animated:YES];
	[self.navigationController.navigationBar.topItem setRightBarButtonItem:
		[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(newBeerCancelButtonClicked)] autorelease]
	];
}

-(void)newBeerCancelButtonClicked
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return breweryGroups;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return index;
}

- (void)dealloc {
    [super dealloc];
	
	[breweryList release];
}

@end


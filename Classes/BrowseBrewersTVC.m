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
	
	// Get list of breweries from the server
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_GET_ALL_BREWERIES_DOC];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	BOOL retval=[parser parse];
	[parser release];
	
	if (retval==YES)
	{
	}

	[super viewWillAppear:animated];
	
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
	BeerListTableViewController* bltvc=[[BeerListTableViewController alloc] initWithBreweryID:[[[breweryList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id"]];
	bltvc.setRightBarButtonItem=NO;
	[self.navigationController pushViewController:bltvc animated:YES];
	[self.navigationController.navigationBar.topItem setRightBarButtonItem:
		[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(newBeerCancelButtonClicked)] autorelease]
	];
}

-(void)newBeerCancelButtonClicked
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	// Clear onBeerSelected selector so we're not called when the user selects a beer
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate setOnBeerSelectedAction:nil target:nil];
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

/********************************
 * NSXMLParser delegate methods
 ********************************/

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.currentElemValue release];
	self.currentElemValue=nil;
	if (xmlParserPath)
		[self.xmlParserPath removeAllObjects];
	else
		xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.currentElemValue release];
	self.currentElemValue=nil;
//	[self.xmlParserPath release];
	self.xmlParserPath=nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"name"])
	{
		// Is it the /breweries/group/brewery/name?
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"breweries",@"group",@"brewery",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[NSMutableString string];
		}
	}
	else if ([elementName isEqualToString:@"group"])
	{
		// Is it the /breweries/group?
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"breweries",nil]])
		{
			// Add group title to array of brewery groups
			[breweryGroups addObject:[attributeDict objectForKey:@"title"]];
			// Create a new group of breweries
			currentGroup=[NSMutableArray arrayWithCapacity:5];
			[breweryList addObject:currentGroup];
		}
	}
	else if ([elementName isEqualToString:@"brewery"])
	{
		// Is it the /breweries/group/brewery?
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"breweries",@"group",nil]])
		{
			// Create a new brewery dictionary
			currentBrewery=[NSMutableDictionary dictionaryWithCapacity:2];
			[currentGroup addObject:currentBrewery];
			[currentBrewery setObject:[attributeDict objectForKey:@"id"] forKey:@"id"];
		}
	}
	else if ([elementName isEqualToString:@"breweries"])
	{
		// Is it the /breweries?
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:nil]])
		{
			if (breweryGroups)
				[breweryGroups release]; // Free the last one, if there is one
			// Create a new brewery groups array
			breweryGroups=[[NSMutableArray alloc] initWithCapacity:27]; // 27=26 letters of alphabet plus one for numbered names
		}
	}
	
	// Add the element to the xmlParserPath
	[self.xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	// Pop the element name off the XML parser path array
	[self.xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"name"])
		{
			// Is it the /breweries/group/brewery/name?
			if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"breweries",@"group",@"brewery",nil]])
			{
				[currentBrewery setObject:currentElemValue forKey:@"name"];
			}
		}

		self.currentElemValue=nil;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.currentElemValue)
	{
		[self.currentElemValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}

@end


//
//  BeerListTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "BeerListTableViewController.h"
#import "BeerTableViewController.h"


@implementation BeerListTableViewController

@synthesize breweryID;
@synthesize currentElemValue;
@synthesize	currentElemAttribs;
@synthesize beerList;
@synthesize app;

-(id)initWithBreweryID:(NSString*)brewery_id andApp:(UIApplication*)a
{
	self.breweryID=brewery_id;
	self.app=a;
	
	self.title=@"Beer List";
	
	beerList=[[NSMutableArray alloc] initWithCapacity:10];
	
	// Retrieve XML doc from server
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dev:81/api/xml/meta/brewery/%@.xml", breweryID ]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	
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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [NSString string];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [beerList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	BeerObject* beer=[beerList objectAtIndex:indexPath.row];
	cell.text=[NSString stringWithFormat:@"%@", [beer.data objectForKey:@"name"] ];
	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BeerObject* beer=[beerList objectAtIndex:indexPath.row];
	BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)self.app.delegate;
	BeerTableViewController* btvc=[[BeerTableViewController alloc] initWithBeerID:[beer.data valueForKey:@"id"]  app:self.app appDelegate:del];
	[del.nav pushViewController: btvc animated:YES];
	[btvc release];
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
    [super dealloc];
}

// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	self.currentElemValue=nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"brewery"])
	{
	}
	else if ([elementName isEqualToString:@"beerlist"])
	{
	}
	else if ([elementName isEqualToString:@"beer"])
	{
		self.currentElemValue=[NSMutableString string];
		self.currentElemAttribs=[[NSMutableDictionary alloc] initWithCapacity:10];
		[self.currentElemAttribs addEntriesFromDictionary:attributeDict];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"beer"])
		{
			BeerObject* beer=[[BeerObject alloc] init];
			[beer.data setObject:currentElemValue forKey:@"name"];
			[beer.data setObject:[currentElemAttribs objectForKey:@"id"] forKey:@"id"];
			
			[beerList addObject:beer];
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


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

@synthesize xmlParserPath;
@synthesize currentElemValue;
@synthesize flavorTitles;
@synthesize flavorsList;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStylePlain]) { // Ignores style argument
		flavorTitles=[[NSMutableArray alloc] initWithCapacity:10];
		flavorsList=[[NSMutableArray alloc] initWithCapacity:10];

		self.title=@"Flavors & Aromas";
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Get Flavors & Aromas doc from server
	// TODO: cache this doc
	
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_GET_FLAVORS_DOC];
	NSData* answer;
	NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
	if ([response statusCode]==200)
	{
		NSXMLParser* parser=[[[NSXMLParser alloc] initWithData:answer] autorelease];
		[parser setDelegate:self];
		[parser parse];
	}
	else
	{
		// TODO: handle this gracefully
	}
	
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
    return [flavorTitles count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[flavorsList objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	[cell.textLabel setText:[[flavorsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [flavorTitles objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
	[flavorTitles release];
	[flavorsList release];
	[currentElemValue release];
	[xmlParserPath release];
    [super dealloc];
}


// NSXMLParser delegate methods

// Sample Flavors doc:
//
//<?xml version="1.0"?>
//<flavors>
//	<group>
//		<title>Berry</title>
//		<flavors>
//			<flavor>Black Currant/Cassis</flavor>
//			<flavor>Blackberry</flavor>
//			<flavor>Blueberry</flavor>
//			<flavor>Raspberry</flavor>
//			<flavor>Strawberry</flavor>
//		</flavors>
//	</group>
//	<group>
//		<title>Chemical</title>
//		<flavors>
//			<flavor>Alcohol</flavor>
//			<flavor>Burnt Match</flavor>
//			<flavor>Medicinal</flavor>
//			<flavor>Menthold</flavor>
//			<flavor>Metallic</flavor>
//			<flavor>Mineral</flavor>
//			<flavor>Paint Thinner</flavor>
//			<flavor>Petroleum</flavor>
//			<flavor>Plastic</flavor>
//			<flavor>Rubber</flavor>
//		</flavors>
//	</group>
//</flavors>

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.currentElemValue release];
	self.currentElemValue=nil;
	
	xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5]; // This also releases a previous xmlParserPath
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.currentElemValue release];
	self.currentElemValue=nil;
	
	xmlParserPath=nil; // This also releases a previous xmlParserPath
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"title"])
	{
		// Is it the /flavors/group/title element?
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=nil;
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
		}
	}
	else if ([elementName isEqualToString:@"flavor"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",@"flavors",nil]]) // Is it the /flavors/group/flavors/flavor element?
		{
			[self.currentElemValue release];
			self.currentElemValue=nil;
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
		}
	}
	
	[xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"title"])
		{
			// Is it the /flavors/group/title element?
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",nil]])
			{
				[flavorTitles addObject:currentElemValue];
				[flavorsList addObject:[NSMutableArray arrayWithCapacity:3]];
			}
		}
		else if ([elementName isEqualToString:@"flavor"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",@"flavors",nil]]) // Is it the /flavors/group/flavors/flavor element?
			{
				[[flavorsList lastObject] addObject:currentElemValue];
			}
		}
		
		[self.currentElemValue release];
		self.currentElemValue=nil;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self.currentElemValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}



@end


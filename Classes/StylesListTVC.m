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

@synthesize stylesList;
@synthesize stylesNames;
@synthesize currentStyleNum;
@synthesize currentElemValue;
@synthesize xmlParserPath;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		// Get styles list from server
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer;
		NSHTTPURLResponse* response=[appDelegate sendRequest:[NSURL URLWithString:BEERCRUSH_API_GET_STYLESLIST] usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSXMLParser* parser=[[[NSXMLParser alloc] initWithData:answer] autorelease];
			parser.delegate=self;
			[parser parse];
		}
		else
		{
			// TODO: alert the user
		}

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
    return [self.stylesList count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.stylesList objectAtIndex:section] count];
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
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [self.stylesNames objectForKey:[NSString stringWithFormat:@"%d",section+1]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	[cell.textLabel setText:[self.stylesNames objectForKey:[[self.stylesList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	[delegate stylesTVC:self didSelectStyle:[[self.stylesList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
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
	[stylesList release];
	[stylesNames release];
	self.currentElemValue=nil;
	self.xmlParserPath=nil;
    [super dealloc];
}

/*
 
 Sample styles doc:
 
<styles>
	<style num="1">
		<name>Light Lager</name>
		<style num="1A">
			<name>Light American Lager</name>
		</style>
		<style num="1B">
			<name>Standard American Lager</name>
		</style>
		<style num="1C">
			<name>Premium American Lager</name>
		</style>
		<style num="1D">
			<name>Munich Helles</name>
		</style>
		<style num="1E">
			<name>Dortmunder Export</name>
		</style>
	</style>
	<style num="2">
		<name>Pilsner</name>
		<style num="2A">
			<name>German Pilsner</name>
		</style>
		<style num="2B">
			<name>Boehmian Pilsner</name>
		</style>
		<style num="2C">
			<name>Classic American Pilsner</name>
		</style>
	</style>
	<style num="3">
		<name>European Amber Lager</name>
		<style num="3A">
			<name>Vienna Lager</name>
		</style>
		<style num="3B">
			<name>Oktoberfest/Maerzen</name>
		</style>
	</style>
 </styles>
 
 */

// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	self.currentElemValue=nil;
	
	xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5];
	
	self.stylesList=[[NSMutableArray alloc] initWithCapacity:32];
	self.stylesNames=[[NSMutableDictionary alloc] initWithCapacity:32];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	xmlParserPath=nil;
	currentElemValue=nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"style"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",nil]])
		{
			[self.stylesList addObject:[NSMutableArray arrayWithCapacity:5]];
//			[self.stylesList addObject:[attributeDict objectForKey:@"num"]];
		}
		else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",@"style",nil]])
		{
			[[self.stylesList lastObject] addObject:[attributeDict objectForKey:@"num"]];
		}
	}
	else if ([elementName isEqualToString:@"name"])
	{
		if ([[xmlParserPath lastObject] isEqualToString:@"style"])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	
	[xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"style"])
		{
		}
		else if ([elementName isEqualToString:@"name"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",@"style",nil]])
			{
				[self.stylesNames setObject:self.currentElemValue forKey:[NSString stringWithFormat:@"%d",[self.stylesList count]]];
			}
			else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",@"style",@"style",nil]])
			{
				[self.stylesNames setObject:self.currentElemValue forKey:[[self.stylesList lastObject] lastObject]];
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
	[self.currentElemValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}

@end


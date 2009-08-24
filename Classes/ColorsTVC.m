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

@synthesize colorsList;
@synthesize colorsNums;
@synthesize xmlParserPath;
@synthesize currentElemValue;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer;
		NSHTTPURLResponse* response=[appDelegate sendRequest:[NSURL URLWithString:BEERCRUSH_API_URL_GET_COLORSLIST] usingMethod:@"GET" withData:nil returningData:&answer];
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.colorsNums count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSString* s=[self.colorsNums objectAtIndex:indexPath.row];
	[cell.textLabel setText:[self.colorsList objectForKey:s]];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	[delegate colorsTVC:self didSelectColor:[[self.colorsNums objectAtIndex:indexPath.row] integerValue]];
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
	[self.colorsList release];
	[self.colorsNums release];
	[self.xmlParserPath release];
	[self.currentElemValue release];
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

// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	self.currentElemValue=nil;
	
	xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5];
	
	self.colorsList=[[NSMutableDictionary alloc] initWithCapacity:12];
	self.colorsNums=[[NSMutableArray alloc] initWithCapacity:12];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	xmlParserPath=nil;
	currentElemValue=nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"color"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"colors",nil]])
		{
			[self.colorsNums addObject:[attributeDict objectForKey:@"srm"]];
		}
	}
	else if ([elementName isEqualToString:@"name"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"colors",@"color",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:16];
		}
	}
	
	[xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"color"])
		{
		}
		else if ([elementName isEqualToString:@"name"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"colors",@"color",nil]])
			{
				[self.colorsList setObject:self.currentElemValue forKey:[self.colorsNums lastObject]];
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


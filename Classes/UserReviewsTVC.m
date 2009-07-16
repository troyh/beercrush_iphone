//
//  UserReviewsTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 7/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "UserReviewsTVC.h"


@implementation UserReviewsTVC

@synthesize reviewsList;
@synthesize xmlParserPath;
@synthesize currentElemValue;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.title=@"My Reviews";
		self.currentElemValue=nil;
		self.xmlParserPath=nil;
		self.reviewsList=[[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Fetch list of user's beer reviews from the server
	NSString* user_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
	if (user_id==nil)
	{
		// TODO: alert the user
	}
	else
	{
		NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_BEER_REVIEWS_DOC, user_id]];
		NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
		[parser setDelegate:self];
		BOOL parse_ok=[parser parse];
		if (parse_ok==NO)
		{
			NSError* err=[parser parserError];
			UIAlertView* vw=[[UIAlertView alloc] initWithTitle:@"Oops" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[vw show];
			[vw release];
		}
		[parser release];
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.reviewsList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"URTVCCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSMutableDictionary* review=[self.reviewsList objectAtIndex:indexPath.row];
	NSString* s=[review objectForKey:@"beer_id"];
	if (s==nil)
		[cell.textLabel setText:@"???"];
	else
	{
		NSLog(@"Requested %d of %d",indexPath.row,[self.reviewsList count]);
		[cell.textLabel setText:s];

		NSArray* starsfmt=[NSArray arrayWithObjects:
						   @"☆☆☆☆☆",
						   @"★☆☆☆☆",
						   @"★★☆☆☆",
						   @"★★★☆☆",
						   @"★★★★☆",
						   @"★★★★★",
						   nil];
		
		// Set up the cell...
		[cell.detailTextLabel setText:[starsfmt objectAtIndex:[[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"rating"] integerValue]]];
	}
	
    return cell;
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
	[self.currentElemValue release];
	[self.xmlParserPath release];
	[self.reviewsList release];
    [super dealloc];
}


// NSXMLParser delegate methods

//
// Sample Beer Review element:
//
//<beer_review>
//<_id>beer_review:Dogfish-Head-Craft-Brewery-Milton:Indian-Brown-Ale:troyh</_id>
//<_rev>1214100753</_rev>
//<type>beer_review</type>
//<timestamp>1247524623</timestamp>
//<user_id>troyh</user_id>
//<beer_id>Dogfish-Head-Craft-Brewery-Milton:Indian-Brown-Ale</beer_id>
//<rating>5</rating>
//</beer_review>


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.xmlParserPath release];
	self.xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5];
	[self.currentElemValue release];
	self.currentElemValue=nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.xmlParserPath release];
	[self.currentElemValue release];
	self.currentElemValue=nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	// FYI, the test for count here is just for performance to avoid the array compare if possible
	if ([self.xmlParserPath count]==1 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer_reviews",nil]])
	{
		if ([elementName isEqualToString:@"beer_review"])
		{
			// Create a new review item in the reviewsList array
			[self.reviewsList addObject:[NSMutableDictionary dictionaryWithCapacity:5]];
		}
	}
	else if ([self.xmlParserPath count]==2 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer_reviews",@"beer_review",nil]])
	{ // Is a Beer Review
		if ([elementName isEqualToString:@"type"] ||
			[elementName isEqualToString:@"timestamp"] ||
			[elementName isEqualToString:@"beer_id"] ||
			[elementName isEqualToString:@"rating"])
		{
			// Init the string to hold the value of this element
			self.currentElemValue=[[NSMutableString string] retain];
		}
	}

	[self.xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[self.xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer_reviews",@"beer_review",nil]])
		{ // Is a Beer Review
			if ([elementName isEqualToString:@"type"] ||
				[elementName isEqualToString:@"timestamp"] ||
				[elementName isEqualToString:@"beer_id"] ||
				[elementName isEqualToString:@"rating"])
			{
				NSMutableDictionary* review=[self.reviewsList lastObject];
				if (review)
					[review setObject:self.currentElemValue forKey:elementName];
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
	if (self.currentElemValue)
	{
		[self.currentElemValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}

@end


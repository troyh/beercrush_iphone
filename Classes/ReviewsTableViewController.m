//
//  ReviewsTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReviewsTableViewController.h"


@implementation ReviewsTableViewController

@synthesize beerID;
@synthesize xmlParserPath;
@synthesize currentElemValue;
@synthesize reviewsList;

-(id)initWithID:(NSString*)beerid dataType:(ResultType)t
{
	self.beerID=beerid;
	self.xmlParserPath=[NSMutableArray arrayWithCapacity:5];
	self.reviewsList=[NSMutableArray arrayWithCapacity:10];

	self.title=@"Reviews";

	// Separate the brewery ID and the beer ID from the beerID
	NSArray* idparts=[self.beerID componentsSeparatedByString:@":"];

	// Retrieve XML doc for this beer
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_ALL_BEER_REVIEWS_DOC, 
									 [idparts objectAtIndex:0],
									 [idparts objectAtIndex:1]]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	BOOL retval=[parser parse];
	
	if (retval==NO)
	{
		// TODO: handle this error
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.reviewsList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	[cell.textLabel setText:[NSString stringWithFormat:@"%@:%@",
						[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"user_id"],
						[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"rating"]
	]];

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
    [super dealloc];
}

		
// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	self.currentElemValue=nil;
	[self.xmlParserPath removeAllObjects];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	// Add the element to the xmlParserPath
	[self.xmlParserPath addObject:elementName];
	
	if ([elementName isEqualToString:@"beer_review"])
	{
		// Add a new review dictionary object to the list of reviews
		[self.reviewsList addObject:[NSMutableDictionary dictionaryWithCapacity:3]]; // 3 matches the number of elements we know we're going to add
	}
	else if (
		[elementName isEqualToString:@"timestamp"] ||
	    [elementName isEqualToString:@"user_id"] ||
	    [elementName isEqualToString:@"rating"]
		)
	{
		self.currentElemValue=[NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	// Pop the element name off the XML parser path array
	[self.xmlParserPath removeLastObject];
	
	if (self.currentElemValue) // If we care about capturing this data
	{
		// Is it the element under //beer_reviews/beer_review?
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer_reviews",@"beer_review",nil]])
		{
//			NSMutableDictionary* currentReviewObject=[self.reviewsList lastObject];
			if ([elementName isEqualToString:@"timestamp"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"timestamp"];
			else if ([elementName isEqualToString:@"user_id"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"user_id"];
			else if ([elementName isEqualToString:@"rating"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"rating"];
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


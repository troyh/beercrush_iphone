//
//  ReviewsTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReviewsTableViewController.h"

@implementation ReviewsTableViewController

@synthesize reviewedDocID;
@synthesize xmlParserPath;
@synthesize currentElemValue;
@synthesize reviewsList;
@synthesize totalReviews;

-(id)initWithID:(NSString*)docid dataType:(ResultType)t
{
	self.reviewedDocID=docid;
	self.xmlParserPath=[NSMutableArray arrayWithCapacity:5];
	self.reviewsList=[NSMutableArray arrayWithCapacity:10];
	self.totalReviews=0;

	self.title=@"Reviews";

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
    [super viewWillAppear:animated];

	// Separate the parts of the reviewedDocID to determine what kind of doc it is
	NSArray* idparts=[self.reviewedDocID componentsSeparatedByString:@":"];
	
	NSURL* url=nil;
	if ([[idparts objectAtIndex:0] isEqualToString:@"beer"])
	{	// Retrieve XML doc for this beer
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_ALL_BEER_REVIEWS_DOC, 
								  [idparts objectAtIndex:1],
								  [idparts objectAtIndex:2],
								  0]];
	}
	else if ([[idparts objectAtIndex:0] isEqualToString:@"brewery"])
	{ // Retrieve XML doc for this brewery
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_ALL_BREWERY_REVIEWS_DOC, 
								  [idparts objectAtIndex:1],
								  0]];
	}
	else if ([[idparts objectAtIndex:0] isEqualToString:@"place"]) 
	{ // Retrieve XML doc for this place
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_ALL_PLACE_REVIEWS_DOC, 
								  [idparts objectAtIndex:1],
								  0]];
	}
	
	if (url)
	{
		BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer;
		NSHTTPURLResponse* response=[del sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
			[parser setDelegate:self];
			BOOL retval=[parser parse];
			
			if (retval==NO)
			{
				// TODO: handle this error
			}
		}
	}

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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.totalReviews>[self.reviewsList count])
		return [self.reviewsList count]+1; // Extra row for the button to get more reviews
    return [self.reviewsList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if (indexPath.row > [self.reviewsList count])
	{
		[cell.textLabel setText:[NSString stringWithFormat:@"%d more reviews",(self.totalReviews-[self.reviewsList count]),nil]];
	}
	else
	{
		NSArray* starsfmt=[NSArray arrayWithObjects:
			@"☆☆☆☆☆ %@",
			@"★☆☆☆☆ %@",
			@"★★☆☆☆ %@",
			@"★★★☆☆ %@",
			@"★★★★☆ %@",
			@"★★★★★ %@",
			nil];

		// Set up the cell...
		[cell.textLabel setText:[NSString stringWithFormat:[starsfmt objectAtIndex:[[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"rating"] integerValue]],
							[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"user_id"]
							
		]];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Find out what type of document this review is for...
	UIViewController* vc=nil;
	
	if ([[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"beer_id"]!=nil) // It's a beer review
	{
		FullBeerReviewTVC* fbrtvc=[[[FullBeerReviewTVC alloc] initWithReviewObject:[self.reviewsList objectAtIndex:indexPath.row]] autorelease];
		fbrtvc.delegate=self;
		vc=fbrtvc;
	}
	
	if (vc!=nil)
		[self.navigationController pushViewController:vc animated:YES];
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
	[reviewedDocID release];
	currentElemValue=nil;
	[reviewsList release];
	[xmlParserPath release];

    [super dealloc];
}

// FullBeerReviewTVCDelegate methods

-(void)fullBeerReview:(NSDictionary*)review withChanges:(BOOL)edited
{
	if (edited)
	{
		BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer;
		if ([[del postBeerReview:review returningData:&answer] statusCode]==200)
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}
		
// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.currentElemValue release];
	self.currentElemValue=nil;
	[self.xmlParserPath removeAllObjects];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.currentElemValue release];
	self.currentElemValue=nil;
	[self.xmlParserPath removeAllObjects];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	/*
	 Sample reviews doc:
	<reviews total="1" start="0" count="1" seqnum="0" seqmax="0">
		<review>
			<type>review</type>
			<timestamp>1249427886</timestamp>
			<user_id>troyh</user_id>
			<place_id>place:Elliot-Bay-Brewhouse-and-Pub-Burien-Washington</place_id>
			<rating>4</rating>
		</review>
	</reviews>
	 */
	
	if ([elementName isEqualToString:@"reviews"])
	{
		if ([self.xmlParserPath count]==0)
		{
			self.totalReviews=[[attributeDict objectForKey:@"total"] integerValue];
		}
	}
	else if ([elementName isEqualToString:@"review"])
	{
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",nil]])
		{
			// Add a new review dictionary object to the list of reviews
			[self.reviewsList addObject:[NSMutableDictionary dictionaryWithCapacity:3]]; // 3 matches the number of elements we know we're going to add
		}
	}
	else if (
		[elementName isEqualToString:@"timestamp"] ||
	    [elementName isEqualToString:@"user_id"] ||
		[elementName isEqualToString:@"beer_id"] ||
	    [elementName isEqualToString:@"rating"]
		)
	{
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",nil]])
		{
			currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"name"])
	{
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",@"beer",nil]])
			currentElemValue=[[NSMutableString alloc] initWithCapacity:128];
	}

	// Add the element to the xmlParserPath
	[self.xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	// Pop the element name off the XML parser path array
	[self.xmlParserPath removeLastObject];
	
	if (self.currentElemValue) // If we care about capturing this data
	{
		// Is it the element under //beer_reviews/beer_review?
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",nil]])
		{
			if ([elementName isEqualToString:@"timestamp"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"timestamp"];
			else if ([elementName isEqualToString:@"user_id"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"user_id"];
			else if ([elementName isEqualToString:@"beer_id"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"beer_id"];
			else if ([elementName isEqualToString:@"rating"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"rating"];
		}
		else if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",@"beer",nil]])
		{
			if ([elementName isEqualToString:@"name"])
				[[self.reviewsList lastObject] setObject:currentElemValue forKey:@"name"];
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


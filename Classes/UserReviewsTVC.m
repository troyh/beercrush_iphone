//
//  UserReviewsTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 7/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "UserReviewsTVC.h"
#import "FullBeerReviewTVC.h"

@implementation UserReviewsTVC

@synthesize reviewsList;
@synthesize xmlParserPath;
@synthesize currentElemValue;
@synthesize totalReviews;
@synthesize seqNext;
@synthesize seqMax;
@synthesize retrievedReviewsCount;

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

	[self retrieveReviews:0]; // Get the first batch
}

-(void)retrieveReviews:(NSUInteger)seqnum
{
	// Fetch list of user's beer reviews from the server
	NSString* user_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
	if (user_id==nil)
	{
		// TODO: ask the user to login
	}
	else
	{
		BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer=nil;
		NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_BEER_REVIEWS_DOC, user_id, seqnum]];
		NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
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






#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.reviewsList count]+(self.totalReviews-[self.reviewsList count]?1:0);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"URTVCCell";
	
	UITableViewCell* cell=nil;
	
	if (indexPath.row<[self.reviewsList count])
	{
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Set up the cell...
		NSMutableDictionary* review=[self.reviewsList objectAtIndex:indexPath.row];
		NSString* s=[review objectForKey:@"beer_name"];
		if (s==nil)
			[cell.textLabel setText:@"???"];
		else
		{
			[cell.textLabel setText:s];
			//[cell.detailTextLabel setText:[review objectForKey:@"brewery_name"]];

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
	}
	else
	{
		// Add the "More reviews..." table cell
		cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		[cell.textLabel setText:[NSString stringWithFormat:@"%d more reviews",self.totalReviews-[self.reviewsList count]]];
		cell.textLabel.textAlignment=UITextAlignmentCenter;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row<[self.reviewsList count])
	{
		BeerObject* beerObj=[[BeerObject alloc] init];
		beerObj.data=[[reviewsList objectAtIndex:indexPath.row] copy];
		FullBeerReviewTVC* fbrtvc=[[FullBeerReviewTVC alloc] initWithReviewObject:[self.reviewsList objectAtIndex:indexPath.row]];
		fbrtvc.delegate=self;
		[self.navigationController pushViewController:fbrtvc animated:YES];
	}
	else if (self.totalReviews-[self.reviewsList count])
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		NSUInteger origcnt=[self.reviewsList count];
		// Query the server for the next set of reviews
		// TODO: put spinner in accessoryview so the user knows network stuff is going on
		[self retrieveReviews:self.seqNext];

		// Insert more rows
		[self.tableView beginUpdates];
		
		NSMutableArray* indexPaths=[NSMutableArray arrayWithCapacity:self.retrievedReviewsCount];
		for (int i=0;i<self.retrievedReviewsCount;++i)
		{
			[indexPaths addObject:[NSIndexPath indexPathForRow:origcnt+i inSection:0]];
		}
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
		if ([self.reviewsList count]>=self.totalReviews) // We have no more reviews to load?
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:origcnt inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
		
		[self.tableView endUpdates];
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
	[self.currentElemValue release];
	[self.xmlParserPath release];
	[self.reviewsList release];
    [super dealloc];
}


// NSXMLParser delegate methods

//
// Sample Beer Review element:
//
//<review>
//	<type>beer_review</type>
//	<timestamp>1247524623</timestamp>
//	<user_id>troyh</user_id>
//	<beer_id>Dogfish-Head-Craft-Brewery-Milton:Indian-Brown-Ale</beer_id>
//	<rating>5</rating>
//</review>


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
//	[self.xmlParserPath release];
	self.xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5];
	[self.currentElemValue release];
	self.currentElemValue=nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//	[self.xmlParserPath release];
	self.xmlParserPath=nil;
	[self.currentElemValue release];
	self.currentElemValue=nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"reviews"])
	{
		if ([self.xmlParserPath count]==0) // At the root / of the XML tree
		{
			self.totalReviews=[[attributeDict objectForKey:@"total"] integerValue];
			self.seqNext=[[attributeDict objectForKey:@"seqnum"] integerValue]+1;
			self.seqMax=[[attributeDict objectForKey:@"seqmax"] integerValue];
			self.retrievedReviewsCount=[[attributeDict objectForKey:@"count"] integerValue];
			DLog(@"totalReviews=%d",totalReviews);
			DLog(@"seqNext=%d",seqNext);
			DLog(@"seqMax=%d",seqMax);
		}
	}
	else if ([elementName isEqualToString:@"review"])
	{
		if ([self.xmlParserPath count]==1 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",nil]])
		{
			// Create a new review item in the reviewsList array
			[self.reviewsList addObject:[NSMutableDictionary dictionaryWithCapacity:5]];
		}
	}
	else if ([elementName isEqualToString:@"type"] ||
			[elementName isEqualToString:@"timestamp"] ||
			[elementName isEqualToString:@"beer_id"] ||
			[elementName isEqualToString:@"rating"] ||
			 [elementName isEqualToString:@"aftertaste"] ||
			 [elementName isEqualToString:@"balance"] ||
			 [elementName isEqualToString:@"comments"] ||
			[elementName isEqualToString:@"body"])
	{
		if ([self.xmlParserPath count]==2 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",nil]])
		{ // XPath is /reviews/review (i.e., it's a beer review
			// Init the string to hold the value of this element
			self.currentElemValue=[[NSMutableString string] retain];
		}
	}
	else if ([elementName isEqualToString:@"item"])
	{ // XPath is /reviews/review/flavors
		if ([self.xmlParserPath count]==3 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",@"flavors",nil]])
			self.currentElemValue=[[NSMutableString string] retain];
	}
	else if ([elementName isEqualToString:@"name"])
	{ // XPath is /reviews/review/beer
		if ([self.xmlParserPath count]==3 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",@"beer",nil]])
			self.currentElemValue=[[NSMutableString string] retain];
	}

	[self.xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[self.xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"type"] ||
			[elementName isEqualToString:@"timestamp"] ||
			[elementName isEqualToString:@"beer_id"] ||
			[elementName isEqualToString:@"rating"] ||
			[elementName isEqualToString:@"aftertaste"] ||
			[elementName isEqualToString:@"balance"] ||
			[elementName isEqualToString:@"comments"] ||
			[elementName isEqualToString:@"body"])
		{
			if ([self.xmlParserPath count]==2 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",nil]])
			{ // Is a Beer Review
				NSMutableDictionary* review=[self.reviewsList lastObject];
				[review setObject:self.currentElemValue forKey:elementName];
			}
		}
		else if ([elementName isEqualToString:@"item"])
		{ // XPath is /reviews/review/flavors
			if ([self.xmlParserPath count]==3 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",@"flavors",nil]])
			{
				NSMutableDictionary* review=[self.reviewsList lastObject];
				NSMutableArray* flavors=[review objectForKey:@"flavors"];
				if (flavors==nil)
				{ // Create an array to store the flavors
					flavors=[NSMutableArray arrayWithCapacity:10];
					[review setObject:flavors forKey:@"flavors"];
				}
				[flavors addObject:currentElemValue];
			}
		}
		else if ([elementName isEqualToString:@"name"])
		{
			if ([self.xmlParserPath count]==3 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",@"beer",nil]])
			{
				NSMutableDictionary* review=[self.reviewsList lastObject];
				[review setObject:self.currentElemValue forKey:@"beer_name"];
			}
			else if ([self.xmlParserPath count]==4 && [self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"reviews",@"review",@"beer",@"brewery",nil]])
			{
				NSMutableDictionary* review=[self.reviewsList lastObject];
				[review setObject:self.currentElemValue forKey:@"brewery_name"];
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


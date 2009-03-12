//
//  BreweryTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "BreweryTableViewController.h"
#import "ReviewsTableViewController.h"
#import "BeerListTableViewController.h"

@implementation BreweryObject

@synthesize name;
@synthesize street;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize phone;

-(id)init
{
	return self;
}

@end

@implementation BreweryTableViewController

@synthesize breweryID;
@synthesize breweryObject;
@synthesize app;
@synthesize appdel;
@synthesize currentElemValue;
@synthesize reviewPostResponse;

-(id) initWithBreweryID:(NSString*)brewery_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d
{
	self.breweryID=brewery_id;
	self.app=a;
	self.appdel=d;
	
	self.title=@"Brewery";
	
	[super initWithStyle:UITableViewStyleGrouped];

//	breweryInfo=[[NSMutableπArray alloc] initWithObjects:@"Name",@"Rating & Reviews",@"List of beers",@"1234 Main Street, Anytown AA 12345 US",@"(456) 789-0123",nil];
	breweryObject=[[BreweryObject alloc] init];
	
	// Retrieve XML doc from server
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dev:81/api/xml/brewery/%@.xml", breweryID ]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
			break;
		case 1:
			return 3;
			break;
		default:
			break;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// TODO: If we don't have the data yet, request it from the server
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0:
			switch (indexPath.row)
			{
				case 0:
					cell.text=breweryObject.name;
					cell.font=[UIFont boldSystemFontOfSize:20];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					break;
				case 1:
				{
					NSArray* ratings=[NSArray arrayWithObjects:@" 1 ",@" 2 ",@" 3 ",@" 4 ",@" 5 ",nil];
					UISegmentedControl* ratingctl=[[UISegmentedControl alloc] initWithItems:ratings];
					[cell.contentView addSubview:ratingctl];
					[ratings release];
					
					[ratingctl addTarget:self action:@selector(ratingButtonTapped:event:) forControlEvents:UIControlEventValueChanged];
					break;
				}
				case 2:
					cell.text=@"Ratings & Reviews";
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 3:
					cell.text=@"List of Beers";
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					break;
				default:
					break;
			}
			break;
		case 1:
			switch (indexPath.row)
			{
				case 0:
					cell.text=@"Web site";
					cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
					break;
				case 1:
					cell.text=[NSString stringWithFormat:@"%@, %@ %@ %@",breweryObject.street,breweryObject.city,breweryObject.state,breweryObject.zip];
					cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					break;
				case 2:
					cell.text=breweryObject.phone;
					cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					break;
				default:
					break;
			}
	}
	

    return cell;
}

-(void)ratingButtonTapped:(id)sender event:(id)event
{
	UISegmentedControl* segctl=(UISegmentedControl*)sender;
	NSInteger rating=segctl.selectedSegmentIndex;
	
	// Send the review to the site
	
	NSString* bodystr=[[NSString alloc] initWithFormat:@"rating=%u&brewery_id=%@", rating+1, breweryID];
	NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://dev:81/api/post/place_review"]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:60.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:body];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		reviewPostResponse=[[NSMutableData data] retain];
	} else {
		// TODO: inform the user that the download could not be made
	}	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.section == 0 && indexPath.row == 2) // Reviews is the 2nd row in the 1st section
	{
		ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.breweryID dataType:Brewer];
		[self.navigationController pushViewController: rtvc animated:YES];
		[rtvc release];
	}
	else if (indexPath.section == 0 && indexPath.row == 3) // List of beers is the 3rd row in the 1st section
	{
		BeerListTableViewController* bltvc=[[BeerListTableViewController alloc] initWithBreweryID:self.breweryID andApp:self.app];
		[self.navigationController pushViewController: bltvc animated:YES];
		[bltvc release];
	}
	else if (indexPath.section == 1 && indexPath.row == 0) // Address cell
	{
		[app openURL:[[NSURL alloc] initWithString: [NSString stringWithFormat:@"http://maps.google.com/maps?g=%@, %@ %@ %@",breweryObject.street,breweryObject.city,breweryObject.state,breweryObject.zip]]];
	}
	else if (indexPath.section == 1 && indexPath.row == 1) // Phone number cell
	{
		[app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", breweryObject.phone ]]];
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
	if ([elementName isEqualToString:@"name"] ||
	    [elementName isEqualToString:@"street"] ||
	    [elementName isEqualToString:@"city"] ||
	    [elementName isEqualToString:@"state"] ||
	    [elementName isEqualToString:@"zip"] ||
	    [elementName isEqualToString:@"country"] ||
	    [elementName isEqualToString:@"phone"]
	)
	{
		self.currentElemValue=[NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"name"])
			breweryObject.name=currentElemValue;
		else if ([elementName isEqualToString:@"street"])
			breweryObject.street=currentElemValue;
		else if ([elementName isEqualToString:@"city"])
			breweryObject.city=currentElemValue;
		else if ([elementName isEqualToString:@"state"])
			breweryObject.state=currentElemValue;
		else if ([elementName isEqualToString:@"zip"])
			breweryObject.zip=currentElemValue;
		else if ([elementName isEqualToString:@"phone"])
			breweryObject.phone=currentElemValue;
		
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

// NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [reviewPostResponse setLength:0];
	
	NSHTTPURLResponse* httprsp=(NSHTTPURLResponse*)response;
	NSInteger n=httprsp.statusCode;
	
	if (n==401)
	{
		[appdel login];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [reviewPostResponse appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
	
    // receivedData is declared as a method instance elsewhere
    [reviewPostResponse release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[reviewPostResponse length]);
	
    // release the connection, and the data object
    [connection release];
    [reviewPostResponse release];
}

@end


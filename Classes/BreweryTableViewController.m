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
#import "PhoneNumberEditTableViewController.h"
#import "RatingControl.h"



@implementation BreweryObject

@synthesize data;

-(id)init
{
	self.data=[[NSMutableDictionary alloc] initWithCapacity:10];
	[self.data release];
	[self.data setObject:[[[NSMutableDictionary alloc] initWithCapacity:4] autorelease] forKey:@"address"];

	// Init with blank values for URI and Phone
	[self.data setObject:@"" forKey:@"uri"];
	[self.data setObject:@"" forKey:@"phone"];

	return self;
}

-(void)dealloc
{
	if (self.data)
		[self.data release];
	[super dealloc];
}

@end

@implementation BreweryTableViewController

@synthesize breweryID;
@synthesize breweryObject;
@synthesize app;
@synthesize appdel;
@synthesize currentElemValue;
@synthesize xmlPostResponse;
@synthesize xmlParserPath;

-(id) initWithBreweryID:(NSString*)brewery_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d
{
	self.breweryID=brewery_id;
	self.app=a;
	self.appdel=d;
	self.xmlParserPath=[NSMutableArray arrayWithCapacity:10];
	self.xmlPostResponse=nil;
	self.currentElemValue=nil;
	
	self.title=@"Brewery";
	
	[super initWithStyle:UITableViewStyleGrouped];

	breweryObject=[[BreweryObject alloc] init];

	NSArray* parts=[self.breweryID componentsSeparatedByString:@":"];

	// Retrieve XML doc from server
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_DOC, [parts objectAtIndex:1] ]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	[parser	release];
	
	return self;
}

-(void)dealloc
{
	[self.breweryObject release];
	[self.xmlPostResponse release];
	[self.currentElemValue release];
	[super dealloc];
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData]; // Reload data because we may come back from an editing view controller
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];

	if (editing==YES)
	{
		self.title=@"Editing Brewery";
		NSArray* rows=[NSArray arrayWithObjects:
					   [NSIndexPath indexPathForRow:1 inSection:0],
					   [NSIndexPath indexPathForRow:2 inSection:0],
					   nil];
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
	}
	else
	{
		// Save data to server
		
		NSMutableString* bodystr=[[NSMutableString alloc] initWithFormat:@"brewery_id=%@",self.breweryID];
		// Add in changed fields to the POST data
		// TODO: Only change the fields that were edited by the user
		if (YES)
			[bodystr appendFormat:@"&address:city=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"city"]];
		if (YES)
			[bodystr appendFormat:@"&address:state=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"state"]];
		if (YES)
			[bodystr appendFormat:@"&address:street=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"street"]];
		if (YES)
			[bodystr appendFormat:@"&address:zip=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"zip"]];
		if (YES)
			[bodystr appendFormat:@"&name=%@",[self.breweryObject.data objectForKey:@"name"]];
		if (YES)
			[bodystr appendFormat:@"&phone=%@",[self.breweryObject.data objectForKey:@"phone"]];
		if (YES)
			[bodystr appendFormat:@"&uri=%@",[self.breweryObject.data objectForKey:@"uri"]];
		
		
		NSLog(@"POST data:%@",bodystr);
		NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_BREWERY_DOC]
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:30.0];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest setHTTPBody:body];
		[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];

		NSHTTPURLResponse* response=nil;
		NSError* error;
		int nTries=0;
		BOOL bRetry=NO;
		
		do
		{
			++nTries;
			
			NSData* rspdata=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
			
			if (rspdata) {
				NSLog(@"Response code:%d",[response statusCode]);
				NSLog(@"Response data:%s",[rspdata bytes]);
				
				bRetry=NO;
				int statuscode=[response statusCode];
				if (statuscode==420)
				{
					if (nTries < 2) // Don't retry over and over, just do it once
					{
						if ([appdel login]==YES)
						{
							bRetry=YES;
						}
					}
				}
				else if (statuscode==200)
				{
					// Parse the XML response, which is the new brewery doc
					NSXMLParser* parser=[[NSXMLParser alloc] initWithData:rspdata];
					[parser setDelegate:self];
					[parser parse];
				}
			} else {
				// TODO: inform the user that the download could not be made
			}	
		}
		while (bRetry);
		
		self.title=@"Brewery";

		NSArray* rows=[NSArray arrayWithObjects:
					   [NSIndexPath indexPathForRow:1 inSection:0],
					   [NSIndexPath indexPathForRow:2 inSection:0],
					   nil];
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
	}

}




#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return self.editing?1:3;
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
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	tableView.allowsSelectionDuringEditing=YES;
    
    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0:
			switch (indexPath.row)
			{
				case 0:
					[cell.textLabel setText:[breweryObject.data objectForKey:@"name"]];
					[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					break;
				case 1:
				{
					RatingControl* ratingctl=[[RatingControl alloc] initWithFrame:cell.contentView.frame];
					NSLog(@"RatingControl retainCount=%d",[ratingctl retainCount]);
					
					// Set current user's rating (if any)
					NSString* user_rating=[self.breweryObject.data objectForKey:@"user_rating"];
					if (user_rating!=nil) // No user review
						ratingctl.currentRating=[user_rating integerValue];
					
					// Set the callback for a review
					[ratingctl addTarget:self action:@selector(ratingButtonTapped:event:) forControlEvents:UIControlEventValueChanged];
					
					[cell.contentView addSubview:ratingctl];
					[ratingctl release];
					break;
				}
//				case 2:
//					[cell.textLabel setText:@"Ratings & Reviews"];
//					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
//					break;
				case 2:
					[cell.textLabel setText:@"List of Beers"];
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
					[cell.textLabel setText:[breweryObject.data objectForKey:@"uri"]];
					[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
					[cell.textLabel setTextAlignment:UITextAlignmentCenter];
					break;
				case 1:
				{
					NSMutableDictionary* addr=[breweryObject.data objectForKey:@"address"];
					[cell.textLabel setText:[NSString stringWithFormat:@"%@, %@ %@ %@",
											[addr objectForKey:@"street"],
											[addr objectForKey:@"city"],
											[addr objectForKey:@"state"],
											[addr objectForKey:@"zip"]]];
					[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
					[cell.textLabel setTextAlignment:UITextAlignmentCenter];
//					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					break;
				}
				case 2:
					[cell.textLabel setText:[breweryObject.data objectForKey:@"phone"]];
					[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
					[cell.textLabel setTextAlignment:UITextAlignmentCenter];
//					cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_POST_PLACE_REVIEW]
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
		xmlPostResponse=[[NSMutableData data] retain];
	} else {
		// TODO: inform the user that the download could not be made
	}	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.section == 0 && indexPath.row == 0) // Brewery name
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit name
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=breweryObject.data;
			pnetvc.editableValueName=@"name";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeText;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
	}
//	else if (indexPath.section == 0 && indexPath.row == 2) // Reviews is the 2nd row in the 1st section
//	{
//		ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.breweryID dataType:Brewer];
//		[self.navigationController pushViewController: rtvc animated:YES];
//		[rtvc release];
//	}
	else if (indexPath.section == 0 && indexPath.row == 2) // List of beers is the 3rd row in the 1st section
	{
		BeerListTableViewController* bltvc=[[BeerListTableViewController alloc] initWithBreweryID:self.breweryID];
		[self.navigationController pushViewController: bltvc animated:YES];
		[bltvc release];
	}
	else if (indexPath.section == 1 && indexPath.row == 0) // Web site cell
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit URI
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=breweryObject.data;
			pnetvc.editableValueName=@"uri";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeURI;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
			NSString* uri=[breweryObject.data objectForKey:@"uri"];
			if (uri && [uri length])
				[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: uri]];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 1) // Address cell
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit address
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=breweryObject.data;
			pnetvc.editableValueName=@"address";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeAddress;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
			NSMutableDictionary* addr=[breweryObject.data valueForKey:@"address"];
			NSString* url=[[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@, %@ %@ %@",
							[addr valueForKey:@"street"],
							[addr valueForKey:@"city"],
							[addr valueForKey:@"state"],
							[addr valueForKey:@"zip"]] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
			
			NSLog(@"Opening URL:%@",url);
			[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:url ]];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 2) // Phone number cell
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit phone
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=breweryObject.data;
			pnetvc.editableValueName=@"phone";
			pnetvc.editableValueType=kBeerCrushEditableValueTypePhoneNumber;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
			NSString* s=[[[[breweryObject.data objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""] 
						  stringByReplacingOccurrencesOfString:@"(" withString:@""] 
						 stringByReplacingOccurrencesOfString:@")" withString:@""];
			NSString* url=[NSString stringWithFormat:@"tel:%@",s];
			NSLog(@"Opening URL:%@", url);
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
	}
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	switch (indexPath.section)
	{
		case 0:
			switch (indexPath.row)
			{
				case 0:
					return YES;
					break;
				case 1:
				case 2:
				case 3:
				default:
					break;
			}
			break;
		case 1:
			switch (indexPath.row)
			{
				case 0:
				case 1:
				case 2:
					return YES;
					break;
				default:
					break;
			}
		default:
			break;
	}
			
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}


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
	// Add the element to the xmlParserPath
	[self.xmlParserPath addObject:elementName];
	
	if ([elementName isEqualToString:@"name"] ||
	    [elementName isEqualToString:@"street"] ||
	    [elementName isEqualToString:@"city"] ||
	    [elementName isEqualToString:@"state"] ||
	    [elementName isEqualToString:@"zip"] ||
	    [elementName isEqualToString:@"country"] ||
	    [elementName isEqualToString:@"phone"] ||
	    [elementName isEqualToString:@"uri"]
	)
	{
		[self.currentElemValue release];
		self.currentElemValue=[NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	// Pop the element name off the XML parser path array
	[self.xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"name"])
		{
			// Is it the //brewery/name or the //brewery/meta/beerlist/item/name element?
			NSArray* tmp=[NSArray arrayWithObjects:@"brewery",nil];
			if ([self.xmlParserPath isEqualToArray:tmp])
				[breweryObject.data setObject:currentElemValue forKey:@"name"];
		}
		else if ([elementName isEqualToString:@"street"])
			[[breweryObject.data objectForKey:@"address"] setObject:currentElemValue forKey:@"street"];
		else if ([elementName isEqualToString:@"city"])
			[[breweryObject.data objectForKey:@"address"] setObject:currentElemValue forKey:@"city"];
		else if ([elementName isEqualToString:@"state"])
			[[breweryObject.data objectForKey:@"address"] setObject:currentElemValue forKey:@"state"];
		else if ([elementName isEqualToString:@"zip"])
			[[breweryObject.data objectForKey:@"address"] setObject:currentElemValue forKey:@"zip"];
		else if ([elementName isEqualToString:@"phone"])
			[breweryObject.data setObject:currentElemValue forKey:@"phone"];
		else if ([elementName isEqualToString:@"uri"])
			[breweryObject.data setObject:currentElemValue forKey:@"uri"];
		
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
    [xmlPostResponse setLength:0];
	
	NSHTTPURLResponse* httprsp=(NSHTTPURLResponse*)response;
	NSInteger n=httprsp.statusCode;
	
	if (n==401)
	{
		NSLog(@"Need to login...");
		[appdel login];
	}
	else
		NSLog(@"Status code:%u",n);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [xmlPostResponse appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
	
    // receivedData is declared as a method instance elsewhere
    [xmlPostResponse release];
	xmlPostResponse=nil;
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[xmlPostResponse length]);
	NSLog(@"Response doc:%s",(char*)[xmlPostResponse mutableBytes]);
	
    // release the connection, and the data object
    [connection release];
    [xmlPostResponse release];
	xmlPostResponse=nil;
}

@end


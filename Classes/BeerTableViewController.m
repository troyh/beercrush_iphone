//
//  BeerTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import "BeerTableViewController.h"
#import "ReviewsTableViewController.h"
#import "PhoneNumberEditTableViewController.h"

@implementation BeerTableViewController

@synthesize beerID;
@synthesize app;
@synthesize appdel;
@synthesize beerObj;
@synthesize currentElemValue;
@synthesize xmlParseDepth;
@synthesize bParsingBeerReview;
@synthesize xmlPostResponse;

-(id) initWithBeerID:(NSString*)beer_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d
{
	self.beerID=beer_id;
	self.app=a;
	self.appdel=d;

	self.beerObj=[[BeerObject alloc] init];
	self.title=@"Beer";
	
	[super initWithStyle:UITableViewStyleGrouped];
	
	// Retrieve XML doc for this beer
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_DOC, beerID ]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	BOOL retval=[parser parse];
	
	if (retval==YES)
	{
		[parser release];
		
		// Separate the brewery ID and the beer ID from the beerID
		NSArray* idparts=[self.beerID componentsSeparatedByString:@":"];
		
		// Retrieve user's review for this beer
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC, 
								  [idparts objectAtIndex:0], 
								  [idparts objectAtIndex:1], 
								  @"troyh"]]; // TODO: get real user's id
		parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
		[parser setDelegate:self];
		retval=[parser parse];
		[parser release];
		
		if (retval==YES)
		{
			// The user has a review for this beer
			NSLog(@"User rating:%@", [self.beerObj.data objectForKey:@"user_rating"]);
		}
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
		self.title=@"Editing Beer";
	}
	else
	{
		// Save data to server
		NSString* bodystr=[[NSString alloc] initWithFormat:
						   @"beer_id=%@&"
						   "description=%@&"
						   "name=%@",
						   self.beerID,
						   [self.beerObj.data objectForKey:@"description"],
						   [self.beerObj.data objectForKey:@"name"]];
		
		NSLog(@"POST data:%@",bodystr);
		NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_BEER_DOC]
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
		
		self.title=@"Beer";
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
			return 4;
			break;
		case 1:
			return 2;
			break;
		default:
			break;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case 0:
			switch (indexPath.row)
			{
			case 0:
				break;
			case 1:
				break;
			case 2:
				break;
			case 3:
			{
				CGSize sz=[[beerObj.data objectForKey:@"description"] sizeWithFont:[UIFont systemFontOfSize: [UIFont smallSystemFontSize]] constrainedToSize:CGSizeMake(280.f, 500.0f) lineBreakMode:UILineBreakModeWordWrap];
				return sz.height+20.0f;
				break;
			}
			default:
				break;
			}
			break;
		case 1:
			switch (indexPath.row)
			{
			case 0:
				break;
			case 1:
				break;
			default:
				break;
			}
	}
	return 44.0f; // 44 is the default iPhone table cell height
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
				[cell.textLabel setText:[beerObj.data objectForKey:@"name"]];
				[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
			{
				NSArray* ratings=[[NSArray alloc] initWithObjects:@" 1 ",@" 2 ",@" 3 ",@" 4 ",@" 5 ",nil];
				UISegmentedControl* ratingctl=[[UISegmentedControl alloc] initWithItems:ratings];
				[cell.contentView addSubview:ratingctl];
				[ratings release];
				
				NSString* user_rating=[self.beerObj.data objectForKey:@"user_rating"];
				if (user_rating==nil) // No user review
					ratingctl.selectedSegmentIndex=UISegmentedControlNoSegment;
				else
					ratingctl.selectedSegmentIndex=[user_rating integerValue] - 1;
				
				[ratingctl addTarget:self action:@selector(ratingButtonTapped:event:) forControlEvents:UIControlEventValueChanged];
				
				[ratingctl autorelease]; // TODO: necessary?
				break;
			}
			case 2:
				[cell.textLabel setText:@"Rating & Reviews"];
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 3:
			{
//				cell.text=beerObj.description;
				CGRect contentRect=CGRectMake(10, 10, 0, 0);
				UILabel* textView=[[UILabel alloc] initWithFrame:contentRect];
				textView.text=[beerObj.data objectForKey:@"description"];
				
				contentRect.size=[textView.text sizeWithFont:[UIFont systemFontOfSize: [UIFont systemFontSize]] constrainedToSize:CGSizeMake(280.f, 500.0f)];
				textView.frame=contentRect;
				
				textView.numberOfLines=0;
				textView.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
				textView.lineBreakMode=UILineBreakModeWordWrap;
				[textView sizeToFit];

				[cell.textLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				[cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
				
				[cell.contentView addSubview:textView];
				[cell.contentView sizeToFit];
				[textView release];
				break;
			}
			default:
				break;
		}
			break;
		case 1:
			switch (indexPath.row)
		{
			case 0:
				[cell.textLabel setText:[beerObj.data objectForKey:@"style"]];
				[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
			{
				NSString* ibu=[[beerObj.data objectForKey:@"attribs" ] objectForKey:@"ibu"];
				NSString* abv=[[beerObj.data objectForKey:@"attribs" ] objectForKey:@"abv"];
				if ([ibu length])
					[cell.textLabel setText:[[NSString alloc] initWithFormat:@"%u%% ABV %u IBUs", 
							   abv.intValue, 
							   ibu.intValue]];
				else
					[cell.textLabel setText:[[NSString alloc] initWithFormat:@"%u%% ABV", abv.intValue]];
				
				[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			}
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
	
	NSString* bodystr=[[NSString alloc] initWithFormat:@"rating=%u&beer_id=%@", rating+1, beerID];
	NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];

	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_POST_BEER_REVIEW]
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
	if (indexPath.section == 0 && indexPath.row == 0) // Beer name
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit name
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=beerObj.data;
			pnetvc.editableValueName=@"name";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeText;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
		}
	}
	else if (indexPath.section == 0 && indexPath.row == 2) // Ratings & Reviews
	{
		ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.beerID dataType:Beer];
		[self.navigationController pushViewController: rtvc animated:YES];
		[rtvc release];
	}
	else if (indexPath.section == 0 && indexPath.row == 3) // Beer description
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit description
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=beerObj.data;
			pnetvc.editableValueName=@"description";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeMultiText;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 0) // Beer style
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit style
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=beerObj.data;
			pnetvc.editableValueName=@"style";
			pnetvc.editableChoices=[NSArray arrayWithObjects:@"Stout",@"IPA",nil];
			pnetvc.editableValueType=kBeerCrushEditableValueTypeChoice;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 1) // Beer ABV & IBUs
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit style
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=beerObj.data;
			pnetvc.editableValueName=@"abv";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeNumber;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
		}
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
	xmlParseDepth=0;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	++xmlParseDepth;

	if (xmlParseDepth==1) // Figure out what document type we're parsing
	{
		if ([elementName isEqualToString:@"beer_review"])
			self.bParsingBeerReview=YES;
		else
			self.bParsingBeerReview=NO;
	}

	if (self.bParsingBeerReview)
	{
		if ([elementName isEqualToString:@"rating"])
		{
			self.currentElemValue=[NSMutableString string];
		}
	}
	else
	{
		if ([elementName isEqualToString:@"beer"])
		{
			[beerObj.data setObject:attributeDict forKey:@"attribs"];
		}
		else if ([elementName isEqualToString:@"name"])
		{
			if (xmlParseDepth==2)
				self.currentElemValue=[NSMutableString string];
		}
		else if ([elementName isEqualToString:@"description"])
		{
			if (xmlParseDepth==2)
				self.currentElemValue=[NSMutableString string];
		}
		else if ([elementName isEqualToString:@"style"])
		{
			if (xmlParseDepth==3)
				self.currentElemValue=[NSMutableString string];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	--xmlParseDepth;
	
	if (self.bParsingBeerReview)
	{
		if ([elementName isEqualToString:@"rating"])
		{
			[beerObj.data setObject:currentElemValue forKey:@"user_rating"];
		}
	}
	else
	{
		if (self.currentElemValue)
		{
			if ([elementName isEqualToString:@"name"])
			{
				[beerObj.data setObject:currentElemValue forKey:@"name"];
			}
			else if ([elementName isEqualToString:@"description"])
			{
				[beerObj.data setObject:currentElemValue forKey:@"description"];
			}
			else if ([elementName isEqualToString:@"style"])
			{
				if ([[beerObj.data objectForKey:@"style"] length] == 0) // Only take the 1st style
					[beerObj.data setObject:currentElemValue forKey:@"style"];
			}
			
			self.currentElemValue=nil;
		}
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
}

@end


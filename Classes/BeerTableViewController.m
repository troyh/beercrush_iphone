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
#import "RatingControl.h"

@implementation BeerTableViewController

@synthesize beerID;
@synthesize breweryID;
@synthesize beerObj;
@synthesize currentElemValue;
@synthesize xmlParseDepth;
@synthesize bParsingBeerReview;
@synthesize xmlPostResponse;
@synthesize overlay;
@synthesize spinner;

-(id) initWithBeerID:(NSString*)beer_id
{
	self.beerID=[beer_id copy];
	self.breweryID=nil;
	DLog(@"BeerTableViewController initWithBeerID beerID retainCount=%d",[beerID retainCount]);
	self.overlay=nil;
	self.spinner=nil;
	self.xmlPostResponse=nil;
	self.currentElemValue=nil;

	self.beerObj=[[BeerObject alloc] init];
	self.title=@"Beer";
	
	[super initWithStyle:UITableViewStyleGrouped];
	
	return self;
}

- (void)dealloc
{
	DLog(@"BeerTableViewController release: retainCount=%d",[self retainCount]);
	DLog(@"BeerTableViewController release: beerID retainCount=%d",[beerID retainCount]);
	//	[beerID release];
	[self.beerObj release];
	self.beerObj=nil;
	[self.currentElemValue release];
	self.currentElemValue=nil;
	[xmlPostResponse release];
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
	if (self.beerID!=nil)
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	if (self.beerID==nil)
	{
//		UIToolbar* tb=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//		[tb sizeToFit];
//		
//		// Add cancel and save buttons
//		UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(newBeerCancelButtonClicked)] autorelease];
//		UIBarButtonItem* saveButton=[[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(newBeerSaveButtonClicked)] autorelease];
//		[tb setItems:[NSArray arrayWithObjects:cancelButton,saveButton,nil]];
//		
//		[self.view.superview addSubview:tb];
//		CGRect vf=self.view.frame;
//		vf.size.height-=tb.frame.size.height;
//		vf.origin.y=0;
//		self.view.frame=vf;
//		[self.view sizeToFit];
		self.title=@"New Beer";
	}
	else
	{
		// Separate the brewery ID and the beer ID from the beerID
		NSArray* idparts=[self.beerID componentsSeparatedByString:@":"];

		// Retrieve XML doc for this beer
		NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_DOC, [idparts objectAtIndex:1], [idparts objectAtIndex:2] ]];
		NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
		[parser setDelegate:self];
		BOOL retval=[parser parse];
		[parser release];
		
		if (retval==YES)
		{
			
			// Retrieve user's review for this beer
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC, 
									  [idparts objectAtIndex:1], 
									  [idparts objectAtIndex:2], 
									  [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]]];
			parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
			[parser setDelegate:self];
			retval=[parser parse];
			[parser release];
			
			if (retval==YES)
			{
				// The user has a review for this beer
				DLog(@"User rating:%@", [self.beerObj.data objectForKey:@"user_rating"]);
			}
		}
	}
	
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

//		UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBeerCancelButtonClicked)] autorelease];
//		[self.navigationController.navigationBar.topItem setLeftBarButtonItem:cancelButton animated:YES];
		self.navigationController.navigationBar.topItem.leftBarButtonItem=nil;

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
		// TODO: only do this if the user actually changed anything
		
		// Save data to server
		NSString* bodystr;
		
		// TODO: only send data that has changed
		if (self.beerID)
		{
			bodystr=[[NSString alloc] initWithFormat:
						   @"beer_id=%@&"
						   "description=%@&"
						   "name=%@",
						   self.beerID,
						   [self.beerObj.data objectForKey:@"description"],
						   [self.beerObj.data objectForKey:@"name"]];
		}
		else
		{
			bodystr=[[NSString alloc] initWithFormat:
					 @"brewery_id=%@&"
					 "description=%@&"
					 "name=%@",
					 self.breweryID,
					 [self.beerObj.data objectForKey:@"description"],
					 [self.beerObj.data objectForKey:@"name"]];
		}
		
		DLog(@"POST data:%@",bodystr);
		
		BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer;
		NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_BEER_DOC];
		NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:&answer];
		if ([response statusCode]==200)
		{
			// Parse the XML response, which is the new beer doc
			NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
			[parser setDelegate:self];
			[parser parse];
		}
		else
		{
			// TODO: alert the user that it failed and/or give a chance to retry
		}
		
		self.title=@"Beer";

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
    return 3;
}

//-(void)editBeerCancelButtonClicked
//{
//	self.navigationController.navigationBar.topItem.leftBarButtonItem=nil;
//	[self setEditing:NO animated:YES];
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return self.editing?2:4;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 1;
			break;
		default:
			break;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger adjusted_row=indexPath.row;
	if (self.editing && indexPath.section==0)
	{
		// When editing a beer, section 0 has 2 less rows
		if (adjusted_row>0)
			adjusted_row+=2;
	}

	switch (indexPath.section) 
	{
		case 0:
			switch (adjusted_row)
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

	return tableView.rowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    if (cell == nil) {
		if (indexPath.section==0 && indexPath.row==0)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NameCell"] autorelease];
		else
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	tableView.allowsSelectionDuringEditing=YES;

	NSInteger adjusted_row=indexPath.row;
	if (self.editing && indexPath.section==0)
	{
		// When editing a beer, section 0 has 2 less rows
		if (adjusted_row>0)
			adjusted_row-=2;
	}
	
    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0:
			switch (adjusted_row)
		{
			case 0:
				[cell.textLabel setText:[beerObj.data objectForKey:@"name"]];
				[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
				[cell.detailTextLabel setText:[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"brewery_id"]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
			{
				cell.selectionStyle=UITableViewCellSelectionStyleNone;

				RatingControl* ratingctl=[[RatingControl alloc] initWithFrame:cell.contentView.frame];
				
				// Set current user's rating (if any)
				NSString* user_rating=[self.beerObj.data objectForKey:@"user_rating"];
				if (user_rating!=nil) // No user review
					ratingctl.currentRating=[user_rating integerValue];
				DLog(@"Current rating:%d",ratingctl.currentRating);
				
				// Set the callback for a review
				[ratingctl addTarget:self action:@selector(ratingButtonTapped:event:) forControlEvents:UIControlEventValueChanged];
				
				[cell.contentView addSubview:ratingctl];
				[ratingctl release];
				
				break;
			}
			case 2:
				[cell.textLabel setText:@"Ratings & Reviews"];
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
						[cell.textLabel setText:[[[NSString alloc] initWithFormat:@"%u%% ABV %u IBUs", 
								   abv.intValue, 
								   ibu.intValue] autorelease]];
					else
						[cell.textLabel setText:[[[NSString alloc] initWithFormat:@"%u%% ABV", abv.intValue] autorelease]];
					
					[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					break;
				}
				default:
					break;
			}
			break;
		case 2:
		{
			UIView* transparentBackground=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
			transparentBackground.backgroundColor=[UIColor clearColor];
			cell.backgroundView=transparentBackground;
			
			UIButton* button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
			button.frame=CGRectMake(20, 0, 200, 30);
			[button setTitle:@"Add to Wish List" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(addToWishListButtonClicked) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:button];
			break;
		}
		default:
			break;
	}
	
	
    return cell;
}

-(void)addToWishListButtonClicked
{
	// Add beerID to wish list
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_WISHLIST_DOC];
	NSString* bodystr=[NSString stringWithFormat:@"add_item=%@",self.beerID];
	
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSData* answer;
	NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:&answer];
	if ([response statusCode]==200)
	{
		// TODO: signify somehow that it worked
		// TODO: store new wishlist locally (the returned doc)
	}
	else
	{
		// TODO: tell the user it didn't work
	}
}

-(void)ratingButtonTapped:(id)sender event:(id)event
{
//	[self.view addSubview:spinner];
//	CGRect frame=CGRectMake(0.0, 0.0, 100.0, 100.0);
	CGRect frame=self.view.frame;
	
	if (self.overlay==nil)
	{
		self.overlay=[[UIView alloc] initWithFrame:frame];
		self.overlay.backgroundColor=[UIColor blackColor];
		self.overlay.alpha=0.7;
	}
	
	if (self.spinner==nil)
	{
	//	UIActivityIndicatorView* spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		self.spinner=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
		self.spinner.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
		self.spinner.center=self.overlay.center;
		[self.overlay addSubview:self.spinner];
		[self.spinner release];
	}

	[self.spinner startAnimating];
	self.spinner.hidden=NO;
	[self.view addSubview:self.overlay];
	[self.overlay release];
	
	RatingControl* ctl=(RatingControl*)sender;
	NSInteger rating=ctl.currentRating;
	
	// Send the review to the site
	
	NSString* bodystr=[[NSString alloc] initWithFormat:@"rating=%u&beer_id=%@", rating, beerID];
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



// Support conditional editing of the table view.
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
					break;
				case 3:
					return YES;
					break;
				default:
					break;
			}
			break;
		case 1:
			switch (indexPath.row)
			{
				case 0:
				case 1:
					return YES;
				default:
					break;
			}
			break;
		default:
			break;
	}
	return NO;
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
	if (self.currentElemValue)
	{
		[self.currentElemValue release];
		self.currentElemValue=nil;
	}
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
		if ([elementName isEqualToString:@"review"])
			self.bParsingBeerReview=YES;
		else
			self.bParsingBeerReview=NO;
	}

	if (self.bParsingBeerReview)
	{
		if ([elementName isEqualToString:@"rating"])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:5];
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
			{
				[self.currentElemValue release];
				self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
			}
		}
		else if ([elementName isEqualToString:@"description"])
		{
			if (xmlParseDepth==2)
			{
				[self.currentElemValue release];
				self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
			}
		}
		else if ([elementName isEqualToString:@"style"])
		{
			if (xmlParseDepth==3)
			{
				[self.currentElemValue release];
				self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
			}
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
			[self.currentElemValue release];
			currentElemValue=nil;
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
			
			[self.currentElemValue release];
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
	
	if (n==201)
	{
		DLog(@"Need to login...");
		BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[del login];
		// TODO: retry
	}
	else
		DLog(@"Status code:%u",n);
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
    DLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    DLog(@"Succeeded! Received %d bytes of data",[xmlPostResponse length]);
	DLog(@"Response doc:%s",(char*)[xmlPostResponse mutableBytes]);
	
    // release the connection, and the data object
    [connection release];
    [xmlPostResponse release];
	xmlPostResponse=nil;
	
	if (self.spinner!=nil)
		[self.spinner stopAnimating];
	if (self.overlay!=nil)
		[self.overlay removeFromSuperview];
	self.spinner=nil;
	self.overlay=nil;
}

@end


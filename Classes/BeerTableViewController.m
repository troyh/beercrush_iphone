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
#import "FullBeerReviewTVC.h"

@implementation BeerTableViewController

@synthesize beerID;
@synthesize breweryID;
@synthesize beerObj;
@synthesize currentElemValue;
@synthesize xmlParseDepth;
@synthesize bParsingBeerReview;

-(id) initWithBeerID:(NSString*)beer_id
{
	self.beerID=[beer_id copy];
	self.breweryID=nil;
	DLog(@"BeerTableViewController initWithBeerID beerID retainCount=%d",[beerID retainCount]);
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
					   [NSIndexPath indexPathForRow:1 inSection:1],
					   [NSIndexPath indexPathForRow:2 inSection:1],
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
					   [NSIndexPath indexPathForRow:1 inSection:1],
					   [NSIndexPath indexPathForRow:2 inSection:1],
					   nil];
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
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
			return 1;
			break;
		case 1:
			return self.editing?1:3;
			break;
		case 2:
			return 2;
			break;
		case 3:
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
			break;
		case 1:
			switch (adjusted_row)
			{
			case 0:
				break;
			case 1:
				break;
			case 2:
			{
				CGSize sz=[[beerObj.data objectForKey:@"description"] sizeWithFont:[UIFont systemFontOfSize: [UIFont smallSystemFontSize]] constrainedToSize:CGSizeMake(280.f, 500.0f) lineBreakMode:UILineBreakModeWordWrap];
				return sz.height+20.0f;
				break;
			}
			default:
				break;
			}
			break;
		case 2:
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
	if (self.editing && indexPath.section==1)
	{
		// When editing a beer, section 0 has 2 less rows
		if (adjusted_row>0)
			adjusted_row-=2;
	}
	
    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0:
			[cell.textLabel setText:[beerObj.data objectForKey:@"name"]];
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
			[cell.detailTextLabel setText:[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"brewery_id"]];
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			
			UIView* transparentBackground=[[UIView alloc] initWithFrame:CGRectZero];
			transparentBackground.backgroundColor=[UIColor clearColor];
			cell.backgroundView=transparentBackground;
			
			cell.textLabel.backgroundColor=[UIColor clearColor];
			cell.detailTextLabel.backgroundColor=[UIColor clearColor];
			
			CGRect f=cell.textLabel.frame;
			f.size.width-=100;
			f.origin.x+=100;
			cell.textLabel.frame=f;
			break;
		case 1:
			switch (adjusted_row)
			{
			case 0:
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
			case 1:
				[cell.textLabel setText:@"Ratings & Reviews"];
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 2:
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
		case 2:
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
		case 3:
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
	RatingControl* ctl=(RatingControl*)sender;
	NSInteger rating=ctl.currentRating;
	
	// Send the review to the site
	
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_POST_BEER_REVIEW];
	NSString* bodystr=[[NSString alloc] initWithFormat:@"rating=%u&beer_id=%@", rating, beerID];
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:nil];
	
	if ([response statusCode]==200) {
		FullBeerReviewTVC* fbrtvc=[[[FullBeerReviewTVC alloc] initWithBeerObject:self.beerObj] autorelease];
		[self.navigationController pushViewController:fbrtvc animated:YES];
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
	else if (indexPath.section == 1 && indexPath.row == 1) // Ratings & Reviews
	{
		ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.beerID dataType:Beer];
		[self.navigationController pushViewController: rtvc animated:YES];
		[rtvc release];
	}
	else if (indexPath.section == 1 && indexPath.row == 2) // Beer description
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
	else if (indexPath.section == 2 && indexPath.row == 0) // Beer style
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
	else if (indexPath.section == 2 && indexPath.row == 1) // Beer ABV & IBUs
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

@end


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
#import "RatingControl.h"
#import "FullBeerReviewTVC.h"
#import "StylesListTVC.h"
#import "StyleVC.h"
#import "ColorsTVC.h"
#import "AvailabilityTVC.h"

@implementation BeerTableViewController

@synthesize beerID;
@synthesize breweryID;
@synthesize beerObj;
@synthesize originalBeerData;
@synthesize currentElemValue;
@synthesize xmlParserPath;
@synthesize userReviewData;
@synthesize userRatingControl;
@synthesize overallRatingControl;
@synthesize bodySlider;
@synthesize balanceSlider;
@synthesize aftertasteSlider;
@synthesize beerNameTextField;
@synthesize abvTextField;
@synthesize ibuTextField;
@synthesize ogTextField;
@synthesize fgTextField;
@synthesize grainsTextField;
@synthesize hopsTextField;
@synthesize buttons;
@synthesize dataTableView;
@synthesize delegate;

const int kButtonWidth=80;
const int kButtonHeight=40;
const int kDescriptionCellDefaultRowHeight=80;

static const int kTagBeerNameLabel=1;
static const int kTagDescriptionLabel=2;
static const int kTagStyleLabel=3;

-(id) initWithBeerID:(NSString*)beer_id
{
	self.beerObj=[[BeerObject alloc] init];

	if (beer_id)
	{
		self.beerID=[beer_id copy];
		DLog(@"BeerTableViewController initWithBeerID beerID retainCount=%d",[beerID retainCount]);

		[self.beerObj.data setObject:beer_id forKey:@"beer_id"];
		self.title=@"Beer";
	}
	
	[super initWithStyle:UITableViewStyleGrouped];
	
	return self;
}

- (void)dealloc
{
	DLog(@"BeerTableViewController release: retainCount=%d",[self retainCount]);
	DLog(@"BeerTableViewController release: beerID retainCount=%d",[beerID retainCount]);
	//	[beerID release];
	[self.beerObj release];
	[self.originalBeerData release];
	[self.currentElemValue release];
	[self.xmlParserPath release];
	[self.userReviewData release];

	[self.userRatingControl release];
	[self.overallRatingControl release];
	[self.bodySlider release];
	[self.balanceSlider release];
	[self.aftertasteSlider release];
	[self.beerNameTextField release];
	[self.abvTextField release];
	[self.ibuTextField release];
	[self.ogTextField release];
	[self.fgTextField release];
	[self.grainsTextField release];
	[self.hopsTextField release];
	[self.buttons release];
	
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

	if (self.beerID!=nil)
	{
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.editButtonItem.target=self;
		self.editButtonItem.action=@selector(editButtonClicked);
	}
}

-(void)editButtonClicked
{
	if (self.editing)
	{
		// Save data to server
		NSString* bodystr=nil;
		NSMutableArray* values=[NSMutableArray arrayWithCapacity:10];
		
		if (self.beerNameTextField.text && [[self.beerObj.data objectForKey:@"name"] isEqualToString:self.beerNameTextField.text]==NO)
			[values addObject:[NSString stringWithFormat:@"name=%@",self.beerNameTextField.text]];
		if ([[self.beerObj.data objectForKey:@"description"] isEqualToString:[self.originalBeerData objectForKey:@"description"]]==NO)
			[values addObject:[NSString stringWithFormat:@"description=%@",[self.beerObj.data objectForKey:@"description"]]];
		if (self.abvTextField.text && [[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"abv"] isEqualToString:self.abvTextField.text]==NO)
			[values addObject:[NSString stringWithFormat:@"abv=%@",self.abvTextField.text]];
		if (self.ibuTextField.text && [[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"ibu"] isEqualToString:self.ibuTextField.text]==NO)
			[values addObject:[NSString stringWithFormat:@"ibu=%@",self.ibuTextField.text]];
		if (self.ogTextField.text && [[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"og"] isEqualToString:self.ogTextField.text]==NO)
			[values addObject:[NSString stringWithFormat:@"og=%@",self.ogTextField.text]];
		if (self.fgTextField.text && [[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"fg"] isEqualToString:self.fgTextField.text]==NO)
			[values addObject:[NSString stringWithFormat:@"fg=%@",self.fgTextField.text]];
		if (self.grainsTextField.text && [[self.beerObj.data objectForKey:@"grains"] isEqualToString:self.grainsTextField.text]==NO)
			[values addObject:[NSString stringWithFormat:@"grains=%@",self.grainsTextField.text]];
		if (self.hopsTextField.text && [[self.beerObj.data objectForKey:@"hops"] isEqualToString:self.hopsTextField.text]==NO)
			[values addObject:[NSString stringWithFormat:@"hops=%@",self.hopsTextField.text]];
		if ([[self.beerObj.data objectForKey:@"availability"] isEqualToString:[self.originalBeerData objectForKey:@"availability"]]==NO)
			[values addObject:[NSString stringWithFormat:@"availability=%@",[self.beerObj.data objectForKey:@"availability"]]];
		if ([[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"srm"] && [[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"srm"]!=[[self.originalBeerData objectForKey:@"attribs"] objectForKey:@"srm"])
			[values addObject:[NSString stringWithFormat:@"srm=%@",[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"srm"]]];
		if ([[self.beerObj.data objectForKey:@"style"] isEqualToString:[self.originalBeerData objectForKey:@"style"]]==NO)
			[values addObject:[NSString stringWithFormat:@"bjcp_style_id=%@",[self.beerObj.data objectForKey:@"style"]]];
		
		if ([values count]) // Only send request if there is something that is changing
		{
			if (self.beerID) // Editing an existing beer
			{
				[values addObject:[NSString stringWithFormat:@"beer_id=%@",self.beerID]];
			}
			else if (self.breweryID) // Adding a new beer
			{
				[values addObject:[NSString stringWithFormat:@"brewery_id=%@",self.breweryID]];
			}
			else
			{
				NSException* x=[NSException exceptionWithName:@"" reason:@"Either a beer ID or a brewery ID is required to save beers" userInfo:nil];
				[x raise];
			}
			
			bodystr=[values componentsJoinedByString:@"&"];
			DLog(@"POST data:%@",bodystr);
			
			BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSData* answer;
			NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_BEER_DOC];
			NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:&answer];
			if ([response statusCode]==200)
			{
				// Parse the XML response, which is the new beer doc
				NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
				[parser setDelegate:self];
				if ([parser parse]==YES)
				{
					[self.dataTableView removeFromSuperview];
					self.dataTableView=nil; // Causes it to be recreated in cellForRowAtIndexPath, which causes the updated data to appear
					
					[self setEditing:NO animated:YES];
					[self.tableView reloadData];

					[self.delegate didSaveBeerEdits];
				}
				else
				{
					// TODO: alert the user that it failed and/or give a chance to retry
					UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"XML Error" message:@"Unable to read XML result" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
					[alert show];
				}
			}
			else
			{
				// TODO: alert the user that it failed and/or give a chance to retry
				UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"HTTP Error" message:[NSString stringWithFormat:@"Status code %d",[response statusCode]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
				[alert show];
			}
		}
	}
	else
	{
		// Make a copy of the beer data so we can compare it to the new beer data to see if we should save to the server
		self.originalBeerData=[[NSDictionary alloc] initWithDictionary:self.beerObj.data copyItems:YES];
		[self setEditing:YES animated:YES];
	}
	
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

		// Add cancel and save buttons
		UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:delegate action:@selector(didCancelBeerEdits)] autorelease];
		UIBarButtonItem* saveButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(editButtonClicked)] autorelease];
		
		self.navigationItem.leftBarButtonItem=cancelButton;
		self.navigationItem.rightBarButtonItem=saveButton;
		
	}
	else if ([self.beerObj.data count]<2) // Do we need to get the beer data? TODO: should just ask for it and it would be cached in AppDelegate
	{
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];

		// Separate the brewery ID and the beer ID from the beerID
		NSArray* idparts=[self.beerID componentsSeparatedByString:@":"];

		// Retrieve XML doc for this beer
		NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_DOC, [idparts objectAtIndex:1], [idparts objectAtIndex:2] ]];
		NSData* answer;
		NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
			[parser setDelegate:self];
			[parser parse];
			[parser release];
			
			// Retrieve user's review for this beer
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC, 
									  [idparts objectAtIndex:1], 
									  [idparts objectAtIndex:2], 
									  [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]]];
			response=[appDelegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
			if ([response statusCode]==200)
			{
				// The user has a review for this beer
				parser=[[NSXMLParser alloc] initWithData:answer];
				[parser setDelegate:self];
				[parser parse];
				[parser release];

				if (userReviewData && [userReviewData count])
				{
					DLog(@"User rating:%@", [self.userReviewData objectForKey:@"rating"]);
				}
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

		self.navigationController.navigationBar.topItem.leftBarButtonItem=nil;

		[self.tableView beginUpdates];
//		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:
//												[NSIndexPath indexPathForRow:0 inSection:3],
//												[NSIndexPath indexPathForRow:1 inSection:3],
//												nil] 
//			withRowAnimation:UITableViewRowAnimationFade];

		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
//		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];

		
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
//		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:
//												[NSIndexPath indexPathForRow:1 inSection:0],
//												nil]
//							  withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
	}
	else
	{
		self.title=@"Beer";

		[self.tableView beginUpdates];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
//		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];

		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
//		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.editing?3:6;
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
			return self.editing?2:1;
			break;
		case 1:
			return self.editing?1:6;
			break;
		case 2:
			return self.editing?10:1;
			break;
		case 3:
			return self.editing?0:1;
			break;
		case 4:
			return self.editing?0:1;
			break;
		case 5:
			return self.editing?0:1;
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
			if (self.editing)
			{
			}
			else 
			{
				return 60; // Beer name, brewery and style cell
			}

			break;
		case 1:
		{
			if (self.editing)
			{
				return 80; // Description cell
			}
			else
			{
			}
			break;
		}
		case 2:
			if (self.editing)
			{
			}
			else
			{
				return kDescriptionCellDefaultRowHeight; // Description cell
			}
			break;
		case 3:
		{
			if (self.editing)
			{
			}
			else
			{
				return 250; // Details cell
			}
		}
		default:
			break;
	}

	return tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.editing)
	{
		switch (section) {
			case 1:
				return @"Brewer's Description";
				break;
			case 2:
				return @"Details";
				break;
			default:
				break;
		}
	}
	else {
		switch (section) {
			case 2:
				return @"Brewer's Description";
				break;
			case 3:
				return @"Details";
				break;
			default:
				break;
		}
	}
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
//	DLog(@"section=%d row=%d",indexPath.section,indexPath.row);
//	if (indexPath.section==0)
//		return YES;
	return NO;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];

    UITableViewCell *cell = nil;

	tableView.allowsSelectionDuringEditing=YES;

    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0: // Section 0
		{
			switch (indexPath.row)
			{
				case 0:
					if (self.editing)
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section0CellEditing"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section0CellEditing"] autorelease];
							[cell.textLabel setText:@"Name"];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							self.beerNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(80, 10, 200, 30)];
							self.beerNameTextField.font=[UIFont boldSystemFontOfSize:20];
							self.beerNameTextField.textAlignment=UITextAlignmentLeft;
							
							self.beerNameTextField.autocorrectionType=UITextAutocorrectionTypeNo;
							self.beerNameTextField.autocapitalizationType=UITextAutocapitalizationTypeWords;
							self.beerNameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
							self.beerNameTextField.returnKeyType=UIReturnKeyNext;
							self.beerNameTextField.enablesReturnKeyAutomatically=YES;
							self.beerNameTextField.delegate=self;

							[cell.contentView addSubview:self.beerNameTextField];
							self.beerNameTextField.text=[self.beerObj.data objectForKey:@"name"];
						}
					}
					else
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section0Cell"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Section0Cell"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;

							UILabel* breweryNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 0, 200, 20)] autorelease];
							breweryNameLabel.backgroundColor=[UIColor clearColor];
							breweryNameLabel.font=[UIFont boldSystemFontOfSize:12];
							breweryNameLabel.textColor=[UIColor grayColor];
							[breweryNameLabel setText:[appDelegate breweryNameFromBeerID:[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"brewery_id"]]];
							[cell.contentView addSubview:breweryNameLabel];
							
							UILabel* beerNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 15, 200, 30)] autorelease];
							beerNameLabel.tag=kTagBeerNameLabel;
							beerNameLabel.font=[UIFont boldSystemFontOfSize:22];
							beerNameLabel.backgroundColor=[UIColor clearColor];
							[cell.contentView addSubview:beerNameLabel];
							
							UILabel* styleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 40, 200, 20)] autorelease];
							styleLabel.backgroundColor=[UIColor clearColor];
							styleLabel.font=[UIFont boldSystemFontOfSize:14];
							styleLabel.textColor=[UIColor blackColor];
							styleLabel.tag=kTagStyleLabel;
							[cell.contentView addSubview:styleLabel];
							
							// Put photo to the left
							PhotoThumbnailControl* photo=[[[PhotoThumbnailControl alloc] initWithFrame:CGRectMake(0, 0, 75, 75)] autorelease];
							[photo addTarget:self action:@selector(photoThumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
							[cell.contentView addSubview:photo];
							
							UIView* transparentBackground=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
							transparentBackground.backgroundColor=[UIColor clearColor];
							cell.backgroundView=transparentBackground;
						}

						UILabel* beerNameLabel=(UILabel*)[cell viewWithTag:kTagBeerNameLabel];
						[beerNameLabel setText:[beerObj.data objectForKey:@"name"]];

						UILabel* styleLabel=(UILabel*)[cell viewWithTag:kTagStyleLabel];
						NSDictionary* stylesDict=[appDelegate getStylesDictionary];
						[styleLabel setText:[[stylesDict objectForKey:@"names"] objectForKey:[beerObj.data objectForKey:@"style"]]];
						
					}
					break;
				case 1:
					if (self.editing)
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section0Row1CellEditing"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section0Row1CellEditing"] autorelease];
							[cell.textLabel setText:@"Style"];
						}
						NSDictionary* stylesDict=[appDelegate getStylesDictionary];
						[cell.detailTextLabel setText:[[stylesDict objectForKey:@"names"] objectForKey:[beerObj.data objectForKey:@"style"]]];
					}
					else 
					{
					}
					break;
				default:
					break;
			}
			break;
		}
		case 1:  // Section 1
			if (self.editing)
			{ // Brewer's description
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section1CellEditing"];
				if (cell == nil)
				{
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section1CellEditing"] autorelease];
					
					UILabel* descriptionLabel=[[[UILabel alloc] initWithFrame:CGRectMake(8, 0, 275, 70)] autorelease];
					[descriptionLabel setFont:[UIFont systemFontOfSize:14.0]];
					descriptionLabel.tag=kTagDescriptionLabel;
					descriptionLabel.numberOfLines=3;
					descriptionLabel.lineBreakMode=UILineBreakModeTailTruncation;
					[cell.contentView addSubview:descriptionLabel];
				}
				
				UILabel* descriptionLabel=(UILabel*)[cell viewWithTag:kTagDescriptionLabel];
				[descriptionLabel setText:[beerObj.data objectForKey:@"description"]];
			}
			else
			{
				switch (indexPath.row)
				{
					case 0: // My Rating
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"MyRatingCell"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"MyRatingCell"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryNone;
						}
						
						[cell.textLabel setText:@"My Rating"];
						
						if (self.userRatingControl==nil)
							self.userRatingControl=[[RatingControl alloc] initWithFrame:CGRectMake(80, 7, 180, 30)];
						
						// Set current user's rating (if any)
						NSString* user_rating=[self.userReviewData objectForKey:@"rating"];
						if (user_rating!=nil) // Ther user has a review of this beer
						{
							self.userRatingControl.currentRating=[user_rating integerValue];
							cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
						}
						DLog(@"Current rating:%d",self.userRatingControl.currentRating);
						
						// Set the callback for a review
						[self.userRatingControl addTarget:self action:@selector(ratingButtonTapped:event:) forControlEvents:UIControlEventValueChanged];
						
						[cell.contentView addSubview:self.userRatingControl];
						break;
					}
					case 1: // Overall rating
						cell = [tableView dequeueReusableCellWithIdentifier:@"OverallRating"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"OverallRating"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryNone;
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleBlue;
						[cell.textLabel setText:[NSString stringWithFormat:@"%d Ratings",[self.beerObj.data objectForKey:@"ratingcount"]]];

						if (self.overallRatingControl==nil)
						{
							self.overallRatingControl=[[RatingControl alloc] initWithFrame:CGRectMake(80, 7, 180, 30)];
							self.overallRatingControl.userInteractionEnabled=NO; // This rating control should ignore touches
						}
						
						// Set overall rating (if any)
						NSString* overall_rating=[self.beerObj.data objectForKey:@"avgrating"];
						if (overall_rating!=nil) // No overall rating
						{
							self.overallRatingControl.currentRating=[overall_rating integerValue];
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						else
							cell.accessoryType=UITableViewCellAccessoryNone;
						
						DLog(@"Overall rating:%d",self.overallRatingControl.currentRating);
						
						[cell.contentView addSubview:self.overallRatingControl];
						break;
					case 2: // Body meter
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"BodyMeter"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"BodyMeter"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryNone;
						}
						
						if (self.bodySlider==nil)
						{
							self.bodySlider=[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)];
							self.bodySlider.userInteractionEnabled=NO; // This rating control should ignore touches

							self.bodySlider.minimumValue=1.0;
							self.bodySlider.maximumValue=5.0;
							NSString* value=[[self.beerObj.data objectForKey:@"meta"] objectForKey:@"body"];
							if (value==nil)
								self.bodySlider.value=1;
							else
								[self.bodySlider setValue:[value integerValue] animated:YES];

							UIImageView* leftimgview=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"body_low.png"]] autorelease];
							CGRect frame=leftimgview.frame;
							frame.origin.x=self.bodySlider.frame.origin.x-20;
							frame.origin.y=14;
							leftimgview.frame=frame;
							[cell.contentView addSubview:leftimgview];
							
							UIImageView* rightimgview=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"body_high.png"]] autorelease];
							frame=rightimgview.frame;
							frame.origin.x=self.bodySlider.frame.origin.x+self.bodySlider.frame.size.width+3;
							frame.origin.y=14;
							rightimgview.frame=frame;
							[cell.contentView addSubview:rightimgview];
							
						}
						[cell.contentView addSubview:self.bodySlider];
						
						[cell.textLabel setText:@"Body"];
						cell.textLabel.backgroundColor=[UIColor clearColor];
						cell.accessoryType=UITableViewCellAccessoryNone;
						break;
					}
					case 3: // Balance meter
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"BalanceMeter"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"BalanceMeter"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryNone;
						}
						if (self.balanceSlider==nil)
						{
							self.balanceSlider=[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)];
							self.balanceSlider.userInteractionEnabled=NO; // This rating control should ignore touches

							self.balanceSlider.minimumValue=1.0;
							self.balanceSlider.maximumValue=5.0;
							NSString* value=[[self.beerObj.data objectForKey:@"meta"] objectForKey:@"balance"];
							if (value==nil)
								self.balanceSlider.value=1;
							else
								[self.balanceSlider setValue:[value floatValue] animated:YES];

							UIImageView* leftimgview=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balance_low.png"]] autorelease];
							CGRect frame=leftimgview.frame;
							frame.origin.x=self.balanceSlider.frame.origin.x-20;
							frame.origin.y=14;
							leftimgview.frame=frame;
							[cell.contentView addSubview:leftimgview];
							
							UIImageView* rightimgview=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balance_high.png"]] autorelease];
							frame=rightimgview.frame;
							frame.origin.x=self.balanceSlider.frame.origin.x+self.balanceSlider.frame.size.width+3;
							frame.origin.y=14;
							rightimgview.frame=frame;
							[cell.contentView addSubview:rightimgview];
						}
						[cell.contentView addSubview:self.balanceSlider];

						[cell.textLabel setText:@"Balance"];
						cell.textLabel.backgroundColor=[UIColor clearColor];
						cell.accessoryType=UITableViewCellAccessoryNone;
						break;
					}
					case 4: // Aftertaste meter
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"AftertasteMeter"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"AftertasteMeter"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryNone;
						}
						if (self.aftertasteSlider==nil)
						{
							self.aftertasteSlider=[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)];
							self.aftertasteSlider.userInteractionEnabled=NO; // This rating control should ignore touches

							self.aftertasteSlider.minimumValue=1.0;
							self.aftertasteSlider.maximumValue=5.0;
							NSString* value=[[self.beerObj.data objectForKey:@"meta"] objectForKey:@"aftertaste"];
							if (value==nil)
								self.aftertasteSlider.value=1;
							else
								[self.aftertasteSlider setValue:[value integerValue] animated:YES];
							
							UIImageView* leftimgview=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aftertaste_low.png"]] autorelease];
							CGRect frame=leftimgview.frame;
							frame.origin.x=self.aftertasteSlider.frame.origin.x-20;
							frame.origin.y=14;
							leftimgview.frame=frame;
							[cell.contentView addSubview:leftimgview];
							
							UIImageView* rightimgview=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aftertaste_high.png"]] autorelease];
							frame=rightimgview.frame;
							frame.origin.x=self.aftertasteSlider.frame.origin.x+self.aftertasteSlider.frame.size.width+3;
							frame.origin.y=14;
							rightimgview.frame=frame;
							[cell.contentView addSubview:rightimgview];
						}
						[cell.contentView addSubview:self.aftertasteSlider];

						[cell.textLabel setText:@"Aftertaste"];
						cell.textLabel.backgroundColor=[UIColor clearColor];
						cell.accessoryType=UITableViewCellAccessoryNone;
						break;
					}
					case 5: // Flavors summary
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Flavors"];
						if (cell == nil)
						{
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Flavors"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryNone;
						}
						[cell.textLabel setText:@"Flavors"];
						NSString* flavors=[self.beerObj.data objectForKey:@"flavors"];
						if (flavors==nil)
						{
							[cell.detailTextLabel setText:@"No flavors or aromas rated yet"];
							[cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
							[cell.detailTextLabel setTextColor:[UIColor grayColor]];
						}
						else
							[cell.detailTextLabel setText:flavors];
						cell.accessoryType=UITableViewCellAccessoryNone;
						break;
					}
					default:
						break;
				}
			}
			break;
		case 2: // Section 2
			if (self.editing)
			{
				switch (indexPath.row) {
					case 0:
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row0Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row0Editing"] autorelease];
						
						[cell.textLabel setText:@"Availability"];
						[cell.detailTextLabel setText:[self.beerObj.data objectForKey:@"availability"]];
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						break;
					case 1:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row1Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row1Editing"] autorelease];
						
						NSDictionary* colorsDict=[appDelegate getColorsDictionary];
						[cell.textLabel setText:@"Color"];
						[cell.detailTextLabel setText:[[[colorsDict objectForKey:@"colornamebysrm"] objectForKey:[NSString stringWithFormat:@"%@",[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"srm"]]] objectForKey:@"name" ]];
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						break;
					}
					case 2:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row2Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row2Editing"] autorelease];
						
						[cell.textLabel setText:@"ABV"];
						[cell.detailTextLabel setText:nil];
						
						if (abvTextField==nil)
						{
							abvTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 50, 30)];
							abvTextField.text=[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"abv"];
							abvTextField.font=[UIFont boldSystemFontOfSize:16];
							abvTextField.keyboardType=UIKeyboardTypeNumberPad;
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						[cell addSubview:abvTextField];
						break;
					}
					case 3:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row3Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row3Editing"] autorelease];
						
						[cell.textLabel setText:@"IBUs"];
						[cell.detailTextLabel setText:nil];
						
						if (ibuTextField==nil)
						{
							ibuTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 50, 30)];
							ibuTextField.text=[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"ibu"];
							ibuTextField.font=[UIFont boldSystemFontOfSize:16];
							ibuTextField.keyboardType=UIKeyboardTypeNumberPad;
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						[cell addSubview:ibuTextField];
						break;
					}
					case 4:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row4Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row4Editing"] autorelease];
						
						[cell.textLabel setText:@"OG"];
						[cell.detailTextLabel setText:nil];
						
						if (ogTextField==nil)
						{
							ogTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 50, 30)];
							ogTextField.text=[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"og"];
							ogTextField.font=[UIFont boldSystemFontOfSize:16];
							ogTextField.keyboardType=UIKeyboardTypeNumberPad;
							[ogTextField addTarget:self action:@selector(ogTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						[cell addSubview:ogTextField];
						break;
					}
					case 5:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row5Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row5Editing"] autorelease];
						
						[cell.textLabel setText:@"FG"];
						[cell.detailTextLabel setText:nil];
						
						if (fgTextField==nil)
						{
							fgTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 50, 30)];
							fgTextField.text=[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"fg"];
							fgTextField.font=[UIFont boldSystemFontOfSize:16];
							fgTextField.keyboardType=UIKeyboardTypeNumberPad;
							[fgTextField addTarget:self action:@selector(fgTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						[cell addSubview:fgTextField];
						break;
					}
					case 6:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row6Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row6Editing"] autorelease];
						
						[cell.textLabel setText:@"Grains"];
						[cell.detailTextLabel setText:nil];
						
						if (grainsTextField==nil)
						{
							grainsTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 150, 30)];
							grainsTextField.text=[self.beerObj.data objectForKey:@"grains"];
							grainsTextField.font=[UIFont boldSystemFontOfSize:16];
							grainsTextField.keyboardType=UIKeyboardTypeDefault;
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						[cell addSubview:grainsTextField];
						break;
					}
					case 7:
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row7Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row7Editing"] autorelease];
						
						[cell.textLabel setText:@"Hops"];
						[cell.detailTextLabel setText:nil];
						
						if (hopsTextField==nil)
						{
							hopsTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 150, 30)];
							hopsTextField.text=[self.beerObj.data objectForKey:@"hops"];
							hopsTextField.font=[UIFont boldSystemFontOfSize:16];
							hopsTextField.keyboardType=UIKeyboardTypeDefault;
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						[cell addSubview:hopsTextField];
						break;
					case 8:
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row8Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row8Editing"] autorelease];
						
						[cell.textLabel setText:@"Misc Ingredients"];
						
//						if (ingsTextField==nil)
//						{
//							ingsTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 150, 30)];
//							ingsTextField.text=[self.beerObj.data objectForKey:@"otherings"];
//							ingsTextField.font=[UIFont boldSystemFontOfSize:16];
//							ingsTextField.keyboardType=UIKeyboardTypeDefault;
//						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
//						[cell addSubview:ingsTextField];
						break;
					case 9:
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row9Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row9Editing"] autorelease];
						
						[cell.textLabel setText:@"Calories/12oz"];
						
//						if (ingsTextField==nil)
//						{
//							ingsTextField=[[UITextField alloc] initWithFrame:CGRectMake(100, 10, 150, 30)];
//							ingsTextField.text=[self.beerObj.data objectForKey:@"otherings"];
//							ingsTextField.font=[UIFont boldSystemFontOfSize:16];
//							ingsTextField.keyboardType=UIKeyboardTypeDefault;
//						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
//						[cell addSubview:ingsTextField];
						break;
					default:
						break;
				}
			}
			else
			{ // Brewer's description
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Cell"];
				if (cell == nil)
				{
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section2Cell"] autorelease];

					UILabel* descriptionLabel=[[[UILabel alloc] initWithFrame:CGRectMake(8, 0, 275, 70)] autorelease];
					[descriptionLabel setFont:[UIFont systemFontOfSize:14.0]];
					descriptionLabel.tag=kTagDescriptionLabel;
					descriptionLabel.numberOfLines=3;
					descriptionLabel.lineBreakMode=UILineBreakModeTailTruncation;
					[cell.contentView addSubview:descriptionLabel];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
				}
				
				UILabel* descriptionLabel=(UILabel*)[cell viewWithTag:kTagDescriptionLabel];
				[descriptionLabel setText:[beerObj.data objectForKey:@"description"]];
			}
			break;
		case 3: // Section 3
		{
			if (self.editing)
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section3CellEditing"];
				if (cell == nil)
				{
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section3CellEditing"] autorelease];
				}
				
				switch (indexPath.row) {
					case 0:
						[cell.textLabel setText:@"Retire This Beer"];
						[cell.textLabel setTextAlignment:UITextAlignmentCenter];
						cell.backgroundColor=[UIColor redColor];
						[cell.textLabel setTextColor:[UIColor whiteColor]];
						cell.textLabel.shadowColor=[UIColor grayColor];
						cell.clipsToBounds=YES;
						
						// TODO: Put a semi-transparent white rect on the top half. See http://www.mlsite.net/blog/?p=227 for help.
						break;
					default:
						break;
				}
			}
			else
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section3Cell"];
				if (cell == nil)
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section3Cell"] autorelease];

				UIColor* stdBlueColor=cell.textLabel.textColor;
				
				static struct { NSString* name; NSString* propname; BOOL inattribs; } fields[]={
					{@"Availability",@"availability",NO},
					{@"Color",@"srm",YES},
					{@"ABV",@"abv",YES},
					{@"IBUs",@"ibu",YES},
					{@"OG",@"og",YES},
					{@"FG",@"fg",YES},
					{@"Grains",@"grains",NO},
					{@"Hops",@"hops",NO},
					{@"Yeast",@"yeast",NO},
					{@"Misc Ingredients",@"otherings",NO},
					{@"Sizes",@"sizes",NO}
				};
				
				if (self.dataTableView==nil)
				{
					dataTableView=[[UIView alloc] initWithFrame:CGRectMake(10, 10, cell.contentView.frame.size.width-20, 100)];
					
					for (int i=0;i<(sizeof(fields)/sizeof(fields[0]));++i)
					{
						UILabel* label=[[[UILabel alloc] initWithFrame:CGRectMake(0, i*20-1, dataTableView.frame.size.width*1/3-5, 20)] autorelease];
						[label setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
						[label setTextColor:stdBlueColor];
						[label setText:fields[i].name];
						label.textAlignment=UITextAlignmentRight;
						[dataTableView addSubview:label];
						
						label=[[[UILabel alloc] initWithFrame:CGRectMake(dataTableView.frame.size.width*1/3, i*20, dataTableView.frame.size.width*2/3, 20)] autorelease];
						[label setFont:[UIFont boldSystemFontOfSize:14]];
						if (fields[i].inattribs)
						{
							if ([fields[i].propname isEqualToString:@"srm"]) 
							{ // Treat SRM (Color) specially
								CGRect newFrame=label.frame;
								newFrame.origin.x+=25; // Move it over so that the color swatch can be seen
								newFrame.size.width-=25; // Make it narrower too
								label.frame=newFrame;
								BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
								NSDictionary* colorsDict=[appDelegate getColorsDictionary];
								NSString* srmval=[NSString stringWithFormat:@"%@",[[self.beerObj.data objectForKey:@"attribs"] objectForKey:fields[i].propname]];
								NSDictionary* colorInfo=[[colorsDict objectForKey:@"colornamebysrm"] objectForKey:srmval];
								[label setText:[colorInfo objectForKey:@"name"]];
								
								// Add a color swatch
								UIView* colorSwatch=[[[UIView alloc] initWithFrame:CGRectMake(dataTableView.frame.size.width*1/3, i*20, 20, 20)] autorelease];
								NSArray* rgbValues=[[colorInfo objectForKey:@"@attributes"] objectForKey:@"rgb"];
								colorSwatch.backgroundColor=[UIColor colorWithRed:[[rgbValues objectAtIndex:0] integerValue]/255.0 
																		green:[[rgbValues objectAtIndex:1] integerValue]/255.0 
																		blue:[[rgbValues objectAtIndex:2] integerValue]/255.0 
																		alpha:1.0];
								[dataTableView addSubview:colorSwatch];
							}
							else
								[label setText:[[self.beerObj.data objectForKey:@"attribs"] objectForKey:fields[i].propname]];
						}
						else
							[label setText:[self.beerObj.data objectForKey:fields[i].propname]];
						[dataTableView addSubview:label];
					}
					[cell addSubview:dataTableView];
				}

				cell.selectionStyle=UITableViewCellSelectionStyleNone;
			}
			break;
		}
		case 4: // Find Nearby Button Cell
			cell = [tableView dequeueReusableCellWithIdentifier:@"Section4Cell"];
			if (cell == nil)
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section4Cell"] autorelease];
			[cell.textLabel setText:@"Find Nearby"];
			cell.textLabel.textAlignment=UITextAlignmentCenter;
			break;
		case 5: // Add To Wishlist Button Cell
			cell = [tableView dequeueReusableCellWithIdentifier:@"Section5Cell"];
			if (cell == nil)
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section5Cell"] autorelease];
			[cell.textLabel setText:@"Add to Wishlist"];
			cell.textLabel.textAlignment=UITextAlignmentCenter;
			break;
		default:
			break;
	}
	
	
    return cell;
}

//
// UITextFieldDelegate protocol methods
//

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField==self.beerNameTextField)
	{ // Go to next field
	}
	return NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	return YES;
}

-(void)ogTextFieldChanged
{
	if (ogTextField)
	{
		if ([ogTextField.text length] == 2 && [[ogTextField.text substringWithRange:NSMakeRange(1,1)] isEqualToString:@"."]==NO)
		{
			ogTextField.text=[NSString stringWithFormat:@"%@.%@",[ogTextField.text substringToIndex:1],[ogTextField.text substringFromIndex:1]];
		}
	}
}

-(void)fgTextFieldChanged
{
	if (fgTextField)
	{
		if ([fgTextField.text length] == 2 && [[fgTextField.text substringWithRange:NSMakeRange(1,1)] isEqualToString:@"."]==NO)
		{
			fgTextField.text=[NSString stringWithFormat:@"%@.%@",[fgTextField.text substringToIndex:1],[fgTextField.text substringFromIndex:1]];
		}
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==1 && indexPath.row==0)
	{
		FullBeerReviewTVC* fbrtvc=[[[FullBeerReviewTVC alloc] initWithReviewObject:self.userReviewData] autorelease];
		fbrtvc.delegate=self;
		[self.navigationController pushViewController:fbrtvc animated:YES];
	}
}

-(void)ratingButtonTapped:(id)sender event:(id)event
{
	RatingControl* ctl=(RatingControl*)sender;
	NSInteger rating=ctl.currentRating;
	
	// Send the review to the site
	
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_POST_BEER_REVIEW];
	NSString* bodystr=[[[NSString alloc] initWithFormat:@"rating=%u&beer_id=%@", rating, beerID] autorelease];
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:nil];
	
	if ([response statusCode]==200) {
		[self.userReviewData setObject:[NSString stringWithFormat:@"%d",rating] forKey:@"rating"];
		FullBeerReviewTVC* fbrtvc=[[[FullBeerReviewTVC alloc] initWithReviewObject:self.userReviewData] autorelease];
		fbrtvc.delegate=self;
		[self.navigationController pushViewController:fbrtvc animated:YES];
	} else {
		// TODO: inform the user that the download could not be made
	}	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.editing)
	{
		switch (indexPath.section)
		{
			case 0: // Beer name
			{
				switch (indexPath.row) {
					case 0:
						[self.beerNameTextField becomeFirstResponder];
						break;
					case 1: // Style
					{
						StylesListTVC* tvc=[[[StylesListTVC alloc] initWithStyle:UITableViewStylePlain] autorelease];
						tvc.delegate=self;
						tvc.selectedStyleID=[self.beerObj.data objectForKey:@"style"];
						[self.navigationController pushViewController:tvc animated:YES];
						break;
					}
					default:
						break;
				}
				break;
			}
			case 1:
			{
				switch (indexPath.row) {
					case 0: // Description field
					{
						EditTextVC* etfvc=[[[EditTextVC alloc] initWithNibName:nil bundle:nil] autorelease];
						etfvc.delegate=self;
						etfvc.textToEdit=[self.beerObj.data objectForKey:@"description"];
						[self.navigationController pushViewController:etfvc animated:YES];
						break;
					}
				}
				break;
			}
			case 2:
			{
				
				switch (indexPath.row) {
					case 0: // Availability
					{
						AvailabilityTVC* atvc=[[[AvailabilityTVC alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
						atvc.delegate=self;
						atvc.selectedAvailability=[self.beerObj.data objectForKey:@"availability"];
						[self.navigationController pushViewController:atvc animated:YES];
						break;
					}
					case 1: // Color
					{
						ColorsTVC* ctvc=[[[ColorsTVC alloc] initWithStyle:UITableViewStylePlain] autorelease];
						ctvc.delegate=self;
						ctvc.selectedColorSRM=[[[self.beerObj.data objectForKey:@"attribs"] objectForKey:@"srm"] integerValue];
						[self.navigationController pushViewController:ctvc animated:YES];
						break;
					}
					case 2: // ABV edit field
						[self.abvTextField becomeFirstResponder];
						break;
					case 3: // IBUs
						[self.ibuTextField becomeFirstResponder];
						break;
					case 4: // OG
						[self.ogTextField becomeFirstResponder];
						break;
					case 5: // FG
						[self.fgTextField becomeFirstResponder];
						break;
					case 6: // Grains
						[self.grainsTextField becomeFirstResponder];
						break;
					case 7: // Hops
						[self.hopsTextField becomeFirstResponder];
						break;
					case 8: // Misc Ingredients
						break;
					case 9: // Calories/12oz
						break;
					default:
						break;
				}
				break;
			}
//			case 3:
//			{
//				// Retire this beer
//				UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"NYI" message:@"This is not yet implemented. Sorry." delegate:nil cancelButtonTitle:@"Troy is Lazy" otherButtonTitles:nil] autorelease];
//				[alert show];
//			}
			default:
				break;
		}
	}
	else
	{
		switch (indexPath.section) {
			case 1: // Overall ratings and reviews
			{
				switch (indexPath.row) {
					case 1:
					case 2:
					case 3:
					case 4:
					case 5:
					{	 // Overall reviews
						ReviewsTableViewController*	rtvc=[[[ReviewsTableViewController alloc] initWithID:self.beerID dataType:Beer] autorelease];
						rtvc.fullBeerReviewDelegate=self; // I'll be the FullBeerReviewTVCDelegate when the user selects on of the reviews to look at
						[self.navigationController pushViewController: rtvc animated:YES];
						break;
					}
					default:
						break;
				}
				break;
			}
			case 2:
			{
				// Make the cell big enough to see all the text
				UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
				[UIView beginAnimations:@"bigdescriptioncell" context:nil];
				CGRect f=cell.frame;
				if (cell.frame.size.height <= kDescriptionCellDefaultRowHeight) // Make it expand to show the full text
				{
					f.size.height+=100;
					
					// Move the next section down too
//					UITableViewCell* next
				}
				else // Shrink it to its normal height
				{
					f.size.height=kDescriptionCellDefaultRowHeight;
				}
				cell.frame=f;
				[UIView commitAnimations];
				break;
			}
			case 3:
			{
//				switch (indexPath.row) {
//					case 1: // Beer style
//					{
//						StyleVC* svc=[[[StyleVC alloc] initWithStyleID:[self.beerObj.data objectForKey:@"style"]] autorelease];
//						[self.navigationController pushViewController:svc animated:YES];
//						break;
//					}
//					default:
//						break;
//				}
				break;
			}
			case 4:
			{
				UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"NYI" message:@"This is not yet implemented." delegate:nil cancelButtonTitle:@"Hurry up, Troy" otherButtonTitles:nil] autorelease];
				[alert show];

				UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
				[cell setSelected:NO animated:YES];
				
				break;
			}
			case 5:
			{
				// Add beerID to wish list
				NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_WISHLIST_DOC];
				NSString* bodystr=[NSString stringWithFormat:@"add_item=%@",self.beerID];
				
				BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
				NSData* answer;
				NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:&answer];
				
				UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
				[cell setSelected:NO animated:YES];
				
				if ([response statusCode]==200)
				{
					// TODO: signify somehow that it worked
					// TODO: store new wishlist locally (the returned doc)
				}
				else
				{
					// TODO: tell the user it didn't work
				}
				break;
			}
			default:
				break;
		}
	}
}

-(void)editTextVC:(id)sender didChangeText:(NSString*)text
{
	// Save the text to the beer's description
	[self.beerObj.data setObject:text forKey:@"description"];
	// Dismiss view controller
	[self.navigationController popViewControllerAnimated:YES];
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

// ColorsTVCDelegate methods

-(void)colorsTVC:(ColorsTVC*)tvc didSelectColor:(NSUInteger)srm
{
	[[self.beerObj.data objectForKey:@"attribs"] setObject:[NSNumber numberWithUnsignedInt:srm] forKey:@"srm"];
	[self.navigationController popViewControllerAnimated:YES];
}

// StylesListTVCDelegate methods
-(void)stylesTVC:(StylesListTVC*)tvc didSelectStyle:(NSString*)styleid
{
	[self.beerObj.data setObject:styleid forKey:@"style"];
	[self.navigationController popViewControllerAnimated:YES];
}

// FullBeerReviewTVCDelegate methods

-(void)fullBeerReview:(NSDictionary*)userReview withChanges:(BOOL)modified
{
	if (modified)
	{
		BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer;
		if ([[del postBeerReview:userReview returningData:&answer] statusCode]==200)
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

-(NSString*)beerName
{
	return [self.beerObj.data objectForKey:@"name"];
}

-(NSString*)breweryName
{
	return self.breweryID; // TODO: get the actual name of the brewery
}

#pragma mark Action methods

-(void)photoThumbnailClicked:(id)sender
{
	NSArray* photoList=[NSArray arrayWithObjects:@"beer.png",@"brewery.png",@"bar.png",nil];
	PhotoViewer* viewer=[[[PhotoViewer alloc] initWithPhotoList:photoList] autorelease];
	viewer.delegate=self;
	[self.navigationController pushViewController:viewer animated:YES];
}

#pragma mark PhotoViewerDelegate methods

-(void)photoViewer:(PhotoViewer*)photoViewer didSelectPhotoToUpload:(UIImage*)photo
{
	NSData* imageData=UIImageJPEGRepresentation(photo, 1.0);
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_UPLOAD_BEER_IMAGE,self.beerID]];
	NSData* answer;
	NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"POST" withData:imageData returningData:&answer];
	if ([response statusCode]==200)
	{
		DLog(@"Successfully uploaded photo");
	}
	else {
		DLog(@"Failed to upload photo");
		UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"Oops" message:@"BeerCrush didn't accept the photo for some reason. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	
}

#pragma mark NSXMLParserDelegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.currentElemValue release];
	self.currentElemValue=nil;
	
	xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	xmlParserPath=nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"review"])
	{
		if ([xmlParserPath count]==0)
		{
			userReviewData=[[NSMutableDictionary alloc] initWithCapacity:10];
		}
	}
	else if ([elementName isEqualToString:@"beer_id"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"rating"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:5];
		}
	}
	else if ([elementName isEqualToString:@"body"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:5];
		}
	}
	else if ([elementName isEqualToString:@"balance"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:5];
		}
	}
	else if ([elementName isEqualToString:@"aftertaste"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:5];
		}
	}
	else if ([elementName isEqualToString:@"comments"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
		}
	}
	else if ([elementName isEqualToString:@"item"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",@"flavors",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:32];
		}
		else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",@"styles",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"beer"])
	{
		if ([xmlParserPath count]==0)
		{
			[beerObj.data setObject:attributeDict forKey:@"attribs"];
		}
	}
	else if ([elementName isEqualToString:@"name"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"description"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
		}
	}
	else if ([elementName isEqualToString:@"availability"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"grains"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"hops"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"yeast"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"otherings"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	
	[xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[xmlParserPath removeLastObject];

	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"beer_id"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
			{
				[userReviewData setObject:currentElemValue forKey:@"beer_id"];
			}
		}
		else if ([elementName isEqualToString:@"rating"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
			{
				[userReviewData setObject:currentElemValue forKey:@"rating"];
			}
		}
		else if ([elementName isEqualToString:@"body"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
			{
				[userReviewData setObject:currentElemValue forKey:@"body"];
			}
		}
		else if ([elementName isEqualToString:@"balance"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
			{
				[userReviewData setObject:currentElemValue forKey:@"balance"];
			}
		}
		else if ([elementName isEqualToString:@"aftertaste"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
			{
				[userReviewData setObject:currentElemValue forKey:@"aftertaste"];
			}
		}
		else if ([elementName isEqualToString:@"comments"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
			{
				[userReviewData setObject:currentElemValue forKey:@"comments"];
			}
		}
		else if ([elementName isEqualToString:@"item"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",@"flavors",nil]])
			{
				NSMutableArray* flavors=[userReviewData objectForKey:@"flavors"];
				if (flavors==nil)
				{
					flavors=[NSMutableArray arrayWithObjects:currentElemValue,nil];
					[userReviewData setObject:flavors forKey:@"flavors"];
				}
				else
					[flavors addObject:currentElemValue];
			}
			else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",@"styles",nil]])
			{
				if ([[beerObj.data objectForKey:@"style"] length] == 0) // Only take the 1st style
					[beerObj.data setObject:currentElemValue forKey:@"style"];
			}
		}
		else if ([elementName isEqualToString:@"name"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
			{
				[beerObj.data setObject:currentElemValue forKey:@"name"];
			}
		}
		else if ([elementName isEqualToString:@"description"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
			{
				[beerObj.data setObject:currentElemValue forKey:@"description"];
			}
		}
		else if ([elementName isEqualToString:@"availability"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
			{
				[beerObj.data setObject:currentElemValue forKey:@"availability"];
			}
		}
		else if ([elementName isEqualToString:@"grains"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
			{
				[beerObj.data setObject:currentElemValue forKey:@"grains"];
			}
		}
		else if ([elementName isEqualToString:@"hops"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
			{
				[beerObj.data setObject:currentElemValue forKey:@"hops"];
			}
		}
		else if ([elementName isEqualToString:@"yeast"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
			{
				[beerObj.data setObject:currentElemValue forKey:@"yeast"];
			}
		}
		else if ([elementName isEqualToString:@"otherings"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"beer",nil]])
			{
				[beerObj.data setObject:currentElemValue forKey:@"otherings"];
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

// AvailabilityTVCDelegate methods

-(void)availabilityTVC:(AvailabilityTVC*)tvc didSelectAvailability:(NSString*)s
{
	[self.beerObj.data setObject:s forKey:@"availability"];
	[self.navigationController popViewControllerAnimated:YES];
}

@end


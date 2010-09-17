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
#import "BeerListTableViewController.h"
#import "RatingControl.h"
#import "FullBeerReviewTVC.h"
#import "StylesListTVC.h"
#import "StyleVC.h"
#import "ColorsTVC.h"
#import "AvailabilityTVC.h"
#import "JSON.h"
#import "BigTextVC.h"

@implementation BeerTableViewController

@synthesize beerID;
@synthesize breweryID;
@synthesize beerObj;
@synthesize thumbnailPhoto;
@synthesize originalBeerData;
@synthesize userReviewData;
@synthesize predictedRating;
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

enum TAGS {
	kTagEditTextName=1,
	kTagEditTextABV,
	kTagEditTextIBU,
	kTagEditTextOG,
	kTagEditTextFG,
	kTagEditTextGrains,
	kTagEditTextHops,
	kTagEditTextOtherIngs,
	kTagEditTextCalories,
	kTagBeerNameLabel,
	kTagBeerPhotoThumbnail,
	kTagBreweryNameLabel,
	kTagDescriptionLabel,
	kTagStyleLabel,
	kTagDetailsAvailability,
	kTagDetailsColor,
	kTagDetailsColorSwatch,
	kTagDetailsABV,
	kTagDetailsIBU,
	kTagDetailsOG,
	kTagDetailsFG,
	kTagDetailsGrains,
	kTagDetailsHops,
	kTagDetailsYeast,
	kTagDetailsOtherIngs,
	kTagDetailsSizes,
};

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

-(NSObject*)navigationRestorationData
{
	return self.beerID;
}

- (void)dealloc
{
	DLog(@"BeerTableViewController release: retainCount=%d",[self retainCount]);
	DLog(@"BeerTableViewController release: beerID retainCount=%d",[beerID retainCount]);
	//	[beerID release];
	[self.beerObj release];
	[self.thumbnailPhoto release];
	[self.originalBeerData release];
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
/*
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)editButtonClicked
{
	if (self.editing)
	{   // Editing is ending (or trying to end), send data to server
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(saveEdits:) object:nil requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"HUD:Saving",@"Saving")];
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
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.editButtonItem.target=self;
		self.editButtonItem.action=@selector(editButtonClicked);

		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(getBeerInfo:) object:self.beerID requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"HUD:GettingBeerInfo",@"Getting Beer Info")];
	}
}

-(void)getBeerInfo:(NSString*)aBeerID
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.beerObj.data=[appDelegate getBeerDoc:aBeerID];
	NSString* user_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
	if (user_id)
	{
		self.userReviewData=[appDelegate getReviewsOfBeer:aBeerID byUserID:user_id];

		// If we don't have a review, get the predicted rating
		if (self.userReviewData==nil) {
			double pr=[appDelegate getPredictedRatingForBeer:aBeerID forUserID:user_id];
			self.predictedRating=[NSNumber numberWithDouble:pr];
			DLog("Predicted rating:%@",self.predictedRating);
		}
	}

	NSString* thumburl=[[beerObj.data objectForKey:@"photos"] objectForKey:@"thumbnail"];
	if ([thumburl isKindOfClass:[NSNull class]]==NO && thumburl && [thumburl length])
	{
		self.thumbnailPhoto=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumburl]]];
	}
	
	[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO]; // Reload data because we may come back from an editing view controller
	[appDelegate dismissActivityHUD];
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
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationFade];
		
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];

		// Put Cancel button up
		self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didCancelBeerEdits:)] autorelease];
	}
	else
	{
		self.title=@"Beer";

		[self.tableView beginUpdates];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];

		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];

		// Remove Cancel button
		self.navigationItem.leftBarButtonItem=nil;
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.editing?3:7;
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
		case 6:
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
						}
						[cell.detailTextLabel setText:[self.beerObj.data objectForKey:@"name"]];
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
							breweryNameLabel.tag=kTagBreweryNameLabel;
							breweryNameLabel.font=[UIFont systemFontOfSize:14];
							breweryNameLabel.textColor=[UIColor blackColor];
							[cell.contentView addSubview:breweryNameLabel];
							
							UILabel* beerNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 15, 200, 30)] autorelease];
							beerNameLabel.tag=kTagBeerNameLabel;
							beerNameLabel.font=[UIFont boldSystemFontOfSize:22];
							beerNameLabel.backgroundColor=[UIColor clearColor];
							[cell.contentView addSubview:beerNameLabel];
							
							UILabel* styleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 40, 200, 20)] autorelease];
							styleLabel.backgroundColor=[UIColor clearColor];
							styleLabel.font=[UIFont systemFontOfSize:12];
							styleLabel.textColor=[UIColor grayColor];
							styleLabel.tag=kTagStyleLabel;
							[cell.contentView addSubview:styleLabel];
							
							// Put photo to the left
							PhotoThumbnailControl* photo=[[[PhotoThumbnailControl alloc] initWithFrame:CGRectMake(0, 0, 75, 75)] autorelease];
							photo.tag=kTagBeerPhotoThumbnail;
							[photo addTarget:self action:@selector(photoThumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
							[cell.contentView addSubview:photo];
							
							UIView* transparentBackground=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
							transparentBackground.backgroundColor=[UIColor clearColor];
							cell.backgroundView=transparentBackground;
						}

						UILabel* beerNameLabel=(UILabel*)[cell viewWithTag:kTagBeerNameLabel];
						[beerNameLabel setText:[beerObj.data objectForKey:@"name"]];

						UILabel* breweryNameLabel=(UILabel*)[cell viewWithTag:kTagBreweryNameLabel];
						[breweryNameLabel setText:[appDelegate breweryNameFromBeerID:[self.beerObj.data objectForKey:@"brewery_id"]]];

						NSArray* styles=[beerObj.data objectForKey:@"styles"];
						if (styles && [styles isKindOfClass:[NSArray class]] && [styles count])
						{
							NSDictionary* stylesDict=[appDelegate getStylesDictionary];
							NSString* s=[[[stylesDict objectForKey:@"names"] objectForKey:[styles objectAtIndex:0]] objectForKey:@"name"];
							if (s)
							{
								UILabel* styleLabel=(UILabel*)[cell viewWithTag:kTagStyleLabel];
								[styleLabel setText:s]; // Take just the 1st
							}
						}
						
						PhotoThumbnailControl* photo=(PhotoThumbnailControl*)[cell viewWithTag:kTagBeerPhotoThumbnail];
						if (self.thumbnailPhoto)
						{
							photo.image=self.thumbnailPhoto;
							[photo setNeedsDisplay];
						}
					}
					break;
				case 1: // Style
				{
					cell = [tableView dequeueReusableCellWithIdentifier:@"Section0Row1Cell"];
					if (cell == nil)
					{
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section0Row1Cell"] autorelease];
						[cell.textLabel setText:@"Style"];
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					}
					NSDictionary* stylesDict=[appDelegate getStylesDictionary];
					NSArray* style=[beerObj.data objectForKey:@"styles"];
					if (style && [style count])
						[cell.detailTextLabel setText:[[[stylesDict objectForKey:@"names"] objectForKey:[style objectAtIndex:0]] objectForKey:@"name"]]; // Take just the 1st
					break;
				}
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
					[descriptionLabel setFont:[UIFont systemFontOfSize:12.0]];
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
						
						if (self.userRatingControl==nil)
							self.userRatingControl=[[RatingControl alloc] initWithFrame:CGRectMake(80, 7, 180, 30)];
						
						// Set current user's rating (if any)
						NSString* user_rating=[self.userReviewData objectForKey:@"rating"];
						if (user_rating!=nil) // Ther user has a review of this beer
						{
							[cell.textLabel setText:@"My Rating"];
							self.userRatingControl.currentRating=[user_rating integerValue];
							cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
							DLog(@"Current rating:%d",self.userRatingControl.currentRating);
						}
						else if (self.predictedRating) // Show the predicted rating
						{
							[cell.textLabel setText:@"Your Predicted Rating"];
							self.userRatingControl.currentRating=round([self.predictedRating doubleValue]);
							DLog(@"Predicted rating:%@",self.predictedRating);
						}
						
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
						NSUInteger total=[[[self.beerObj.data objectForKey:@"review_summary"] valueForKey:@"total"] unsignedIntegerValue];
						[cell.textLabel setText:[NSString stringWithFormat:@"%d Rating%s",total,(total==1?"":"s")]];

						if (self.overallRatingControl==nil)
						{
							self.overallRatingControl=[[RatingControl alloc] initWithFrame:CGRectMake(80, 7, 180, 30)];
							self.overallRatingControl.userInteractionEnabled=NO; // This rating control should ignore touches
						}
						
						// Set overall rating (if any)
						NSString* overall_rating=[[self.beerObj.data objectForKey:@"review_summary"] objectForKey:@"avg"];
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

						NSString* value=[[self.beerObj.data objectForKey:@"review_summary"] valueForKey:@"body_avg"];
						if (value==nil)
							self.bodySlider.value=1;
						else
							[self.bodySlider setValue:[value floatValue] animated:YES];
						
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

						NSString* value=[[self.beerObj.data objectForKey:@"review_summary"] valueForKey:@"balance_avg"];
						if (value==nil)
							self.balanceSlider.value=1;
						else
							[self.balanceSlider setValue:[value floatValue] animated:YES];

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

						NSString* value=[[self.beerObj.data objectForKey:@"review_summary"] valueForKey:@"aftertaste_avg"];
						if (value==nil)
							self.aftertasteSlider.value=1;
						else
							[self.aftertasteSlider setValue:[value floatValue] animated:YES];

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
						NSArray* flavors=[[self.beerObj.data objectForKey:@"review_summary"] objectForKey:@"flavors"];
						if (flavors==nil)
						{
							[cell.detailTextLabel setText:NSLocalizedString(@"No flavors or aromas reported yet",@"Beer Page: Text when no flavors are specified")];
							[cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
							[cell.detailTextLabel setTextColor:[UIColor grayColor]];
						}
						else
						{
							NSDictionary* flavorsdict=[appDelegate getFlavorsDictionary];

							NSMutableArray* flavorslist=[NSMutableArray arrayWithCapacity:5];
							for (NSString* flavor in flavors) {
								[flavorslist addObject:[[[flavorsdict objectForKey:@"byid"] objectForKey:flavor] objectForKey:@"title"]];
							}
							
							[cell.detailTextLabel setText:[flavorslist componentsJoinedByString:NSLocalizedString(@", ",@"Beer Page: flavors separator")]];
						}
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
						[cell.detailTextLabel setText:[[[colorsDict objectForKey:@"colornamebysrm"] objectForKey:[[self.beerObj.data objectForKey:@"srm"] stringValue]] objectForKey:@"name" ]];
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						break;
					}
					case 2:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row2Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row2Editing"] autorelease];
						
						[cell.textLabel setText:@"ABV"];
						[cell.detailTextLabel setText:[[self.beerObj.data objectForKey:@"abv"] stringValue]];

						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					}
					case 3:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row3Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row3Editing"] autorelease];
						
						[cell.textLabel setText:@"IBUs"];
						[cell.detailTextLabel setText:[[self.beerObj.data objectForKey:@"ibu"] stringValue]];
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					}
					case 4:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row4Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row4Editing"] autorelease];
						
						[cell.textLabel setText:@"OG"];
						[cell.detailTextLabel setText:[[self.beerObj.data objectForKey:@"og"] stringValue]];
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					}
					case 5:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row5Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row5Editing"] autorelease];
						
						[cell.textLabel setText:@"FG"];
						[cell.detailTextLabel setText:[[self.beerObj.data objectForKey:@"fg"] stringValue]];
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					}
					case 6:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row6Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row6Editing"] autorelease];
						
						[cell.textLabel setText:@"Grains"];
						[cell.detailTextLabel setText:[self.beerObj.data objectForKey:@"grains"]];
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					}
					case 7:
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row7Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row7Editing"] autorelease];
						
						[cell.textLabel setText:@"Hops"];
						[cell.detailTextLabel setText:[self.beerObj.data objectForKey:@"hops"]];

						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					case 8:
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row8Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row8Editing"] autorelease];
						
						[cell.textLabel setText:@"Misc Ingredients"];
						[cell.detailTextLabel setText:[self.beerObj.data objectForKey:@"otherings"]];
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					case 9:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row9Editing"];
						if (cell == nil)
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row9Editing"] autorelease];
						
						[cell.textLabel setText:@"Calories/12oz"];
						
						NSNumber* cals=[self.beerObj.data objectForKey:@"calories_per_ml"];
						if ([cals floatValue])
						{
							[cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.0f",[cals floatValue]*355]]; // 355ml=12 fl.oz.
						}
						
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						break;
					}
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
				
				// If it's "long" (>100 chars), put the disclosure arrow on the cell and make it tappable
				if ([descriptionLabel.text length]>100)
				{
					cell.userInteractionEnabled=YES;
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				}
				else
				{
					cell.userInteractionEnabled=NO;
					cell.accessoryType=UITableViewCellAccessoryNone;
				}
				
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
				
				static struct { NSString* name; int tag; } fields[]={
					{@"Availability",kTagDetailsAvailability},
					{@"Color",kTagDetailsColor},
					{@"ABV",kTagDetailsABV},
					{@"IBUs",kTagDetailsIBU},
					{@"OG",kTagDetailsOG},
					{@"FG",kTagDetailsFG},
					{@"Grains",kTagDetailsGrains},
					{@"Hops",kTagDetailsHops},
					{@"Yeast",kTagDetailsYeast},
					{@"Misc Ingredients",kTagDetailsOtherIngs},
					{@"Sizes",kTagDetailsSizes}
				};
				
				if (self.dataTableView==nil)
				{
					dataTableView=[[UIView alloc] initWithFrame:CGRectMake(10, 10, cell.contentView.frame.size.width-20, 100)];
					
					for (int i=0;i<(sizeof(fields)/sizeof(fields[0]));++i)
					{
						// Make left label
						UILabel* label=[[[UILabel alloc] initWithFrame:CGRectMake(0, i*20-1, dataTableView.frame.size.width*1/3-5, 20)] autorelease];
						[label setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
						[label setTextColor:stdBlueColor];
						[label setText:fields[i].name];
						label.textAlignment=UITextAlignmentRight;
						[dataTableView addSubview:label];
						
						// Make right label
						label=[[[UILabel alloc] initWithFrame:CGRectMake(dataTableView.frame.size.width*1/3, i*20, dataTableView.frame.size.width*2/3, 20)] autorelease];
						[label setFont:[UIFont boldSystemFontOfSize:14]];
						label.tag=fields[i].tag;

						if (fields[i].tag==kTagDetailsColor)
						{ // Treat SRM (Color) specially
							CGRect newFrame=label.frame;
							newFrame.origin.x+=25; // Move it over so that the color swatch can be seen
							newFrame.size.width-=25; // Make it narrower too
							label.frame=newFrame;
							
							// Add a color swatch
							UIView* colorSwatch=[[[UIView alloc] initWithFrame:CGRectMake(dataTableView.frame.size.width*1/3, i*20, 20, 20)] autorelease];
							colorSwatch.tag=kTagDetailsColorSwatch;
							[dataTableView addSubview:colorSwatch];
						}

						[dataTableView addSubview:label];
					}
					[cell addSubview:dataTableView];
				}

				UILabel* label=(UILabel*)[dataTableView viewWithTag:kTagDetailsAvailability];
				[label setText:[self.beerObj.data objectForKey:@"availability"]];

				if ([self.beerObj.data objectForKey:@"srm"]!=nil)
				{
					label=(UILabel*)[cell viewWithTag:kTagDetailsColor];
					BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
					NSDictionary* colorsDict=[appDelegate getColorsDictionary];
					NSString* srmval=[[self.beerObj.data objectForKey:@"srm"] stringValue];
					NSDictionary* colorInfo=[[colorsDict objectForKey:@"colornamebysrm"] objectForKey:srmval];
					[label setText:[colorInfo objectForKey:@"name"]];

					NSArray* rgbValues=[colorInfo objectForKey:@"rgb"];
					UIView* swatch=[cell viewWithTag:kTagDetailsColorSwatch];
					swatch.backgroundColor=[UIColor colorWithRed:[[rgbValues objectAtIndex:0] integerValue]/255.0 
																green:[[rgbValues objectAtIndex:1] integerValue]/255.0 
																 blue:[[rgbValues objectAtIndex:2] integerValue]/255.0 
																alpha:1.0];
				}

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsABV];
				[label setText:[[self.beerObj.data objectForKey:@"abv"] stringValue]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsIBU];
				[label setText:[[self.beerObj.data objectForKey:@"ibu"] stringValue]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsOG];
				[label setText:[[self.beerObj.data objectForKey:@"og"] stringValue]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsFG];
				[label setText:[[self.beerObj.data objectForKey:@"fg"] stringValue]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsGrains];
				[label setText:[self.beerObj.data objectForKey:@"grains"]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsHops];
				[label setText:[self.beerObj.data objectForKey:@"hops"]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsYeast];
				[label setText:[self.beerObj.data objectForKey:@"yeast"]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsOtherIngs];
				[label setText:[self.beerObj.data objectForKey:@"otherings"]];

				label=(UILabel*)[dataTableView viewWithTag:kTagDetailsSizes];
				[label setText:[self.beerObj.data objectForKey:@"sizes"]];

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
		case 6:
			cell = [tableView dequeueReusableCellWithIdentifier:@"Section6Cell"];
			if (cell == nil)
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section6Cell"] autorelease];
			[cell.textLabel setText:@"More from this Brewer"];
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
	
	NSMutableDictionary* reviewDoc=[[[NSMutableDictionary alloc] initWithCapacity:3] autorelease];
	[reviewDoc setObject:[NSNumber numberWithInt:rating] forKey:@"rating"];
	[reviewDoc setObject:beerID forKey:@"beer_id"];
	
	// Send the review to the site
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(sendBeerReview:) object:reviewDoc requiresUserCredentials:YES activityHUDText:NSLocalizedString(@"HUD:SendingReview",@"Sending Review to server")];
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
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextName;
						vc.title=NSLocalizedString(@"Name",@"Title: Editing beer name");
						vc.textToEdit=[self.beerObj.data objectForKey:@"name"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 1: // Style
					{
						StylesListTVC* tvc=[[[StylesListTVC alloc] initWithStyleID:nil] autorelease];
						tvc.delegate=self;
						tvc.selectedStyleIDs=[self.beerObj.data objectForKey:@"styles"];
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
						ctvc.selectedColorSRM=[[self.beerObj.data objectForKey:@"srm"] integerValue];
						[self.navigationController pushViewController:ctvc animated:YES];
						break;
					}
					case 2: // ABV edit field
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextABV;
						vc.title=NSLocalizedString(@"ABV",@"Title: Editing beer ABV");
						vc.textType=EditLineVCTextTypeFloat;
						vc.textToEdit=[[self.beerObj.data objectForKey:@"abv"] stringValue];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 3: // IBUs
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextIBU;
						vc.title=NSLocalizedString(@"IBUs",@"Title: Editing beer IBUs");
						vc.textType=EditLineVCTextTypeInteger;
						vc.textToEdit=[[self.beerObj.data objectForKey:@"ibu"] stringValue];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 4: // OG
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextOG;
						vc.title=NSLocalizedString(@"OG",@"Title: Editing beer OG");
						vc.textType=EditLineVCTextTypeFloat;
						vc.textToEdit=[[self.beerObj.data objectForKey:@"og"] stringValue];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 5: // FG
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextFG;
						vc.title=NSLocalizedString(@"FG",@"Title: Editing beer FG");
						vc.textType=EditLineVCTextTypeFloat;
						vc.textToEdit=[[self.beerObj.data objectForKey:@"fg"] stringValue];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 6: // Grains
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextGrains;
						vc.title=NSLocalizedString(@"Grains",@"Title: Editing beer grains");
						vc.textToEdit=[self.beerObj.data objectForKey:@"grains"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 7: // Hops
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextHops;
						vc.title=NSLocalizedString(@"Hops",@"Title: Editing beer hops");
						vc.textToEdit=[self.beerObj.data objectForKey:@"hops"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 8: // Misc Ingredients
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.tag=kTagEditTextOtherIngs;
						vc.title=NSLocalizedString(@"Other Ingredients",@"Title: Editing beer misc ingredients");
						vc.textToEdit=[self.beerObj.data objectForKey:@"otherings"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 9: // Calories/12oz
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.delegate=self;
						vc.textType=EditLineVCTextTypeInteger;
						vc.tag=kTagEditTextCalories;
						vc.title=NSLocalizedString(@"Calories",@"Title: Editing beer calories");
						NSNumber* n=[self.beerObj.data objectForKey:@"calories_per_ml"];
						vc.textToEdit=[NSString stringWithFormat:@"%0.0f",[n floatValue]*355]; // 355ml=12 fl.oz.
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
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
			case 2: // Description cell
			{
				// Navigate to BigTextVC, if the text is too long to fit in the cell
				BigTextVC* vc=[[[BigTextVC alloc] init] autorelease];
				vc.textToDisplay=[self.beerObj.data objectForKey:@"description"];
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			case 3:
			{
				break;
			}
			case 4:
			{
				NearbyTableViewController* vc=[[[NearbyTableViewController alloc] initWithBeerID:self.beerID] autorelease];
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			case 5:
			{
				// Add beerID to wish list
				BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
				[appDelegate performAsyncOperationWithTarget:self selector:@selector(addToWishList:) object:self.beerID requiresUserCredentials:YES activityHUDText:NSLocalizedString(@"HUD:AddToWishList",@"Adding to Wish List")];

				UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
				[cell setSelected:NO animated:YES];
				break;
			}
			case 6: // More from this brewer
			{
				NSString* brewery_id=[self.beerObj.data objectForKey:@"brewery_id"];
				BeerListTableViewController* beerlistVC=[[[BeerListTableViewController alloc] initWithBreweryID:brewery_id] autorelease];
				[self.navigationController pushViewController:beerlistVC animated:YES];
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
	[self.tableView reloadData];
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

#pragma mark ColorsTVCDelegate methods

-(void)colorsTVC:(ColorsTVC*)tvc didSelectColor:(NSUInteger)srm
{
	[self.beerObj.data setObject:[NSNumber numberWithUnsignedInt:srm] forKey:@"srm"];
	[self.tableView reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark StylesListTVCDelegate methods

-(void)stylesTVC:(StylesListTVC*)tvc didSelectStyle:(NSArray*)styleids selectedStyle:(NSString*)styleid
{
	// For now, we only support one style per beer, so only use the one they just selected
	[self.beerObj.data setObject:[NSMutableArray arrayWithObject:styleid] forKey:@"styles"];
	[self.tableView reloadData];
	[self.navigationController popToViewController:self animated:YES];
}

-(void)stylesTVC:(StylesListTVC*)tvc didUnselectStyle:(NSArray*)styleids unselectedStyle:(NSString*)styleid
{
	// For now, we only support one style per beer, so only take the first one in the styleids array (should only be
	// 1 at most anyway since we don't ever store more than one on the beer)
	if ([styleids count])
	{
		[self.beerObj.data setObject:[NSMutableArray arrayWithObject:[styleids objectAtIndex:0]] forKey:@"styles"];
		[self.tableView reloadData];
	}
}

#pragma mark FullBeerReviewTVCDelegate methods

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

-(void)fullBeerReviewVCReviewCancelled:(FullBeerReviewTVC *)vc
{
	// Don't need to do anything here
}

-(NSDictionary*)fullBeerReviewGetBeerData
{
	if (self.originalBeerData)
		return self.originalBeerData;
	return beerObj.data;
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
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(getBeerPhotoset:) object:self.beerID requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"Getting Photos",@"HUD:Getting Photos")];
}

-(void)getBeerPhotoset:(id)beer_id
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* photoset=[appDelegate getPhotoset:beer_id];
	[appDelegate dismissActivityHUD];
	if (photoset)
	{
//		NSArray* photos=[photoset objectForKey:@"photos"];
//		if ([photos count])
//		{
			PhotoViewer* viewer=[[[PhotoViewer alloc] initWithPhotoSet:photoset] autorelease];
			viewer.delegate=self;
			[self.navigationController pushViewController:viewer animated:YES];
//		}
	}
}

#pragma mark PhotoViewerDelegate methods

-(void)photoViewer:(PhotoViewer*)photoViewer didSelectPhotoToUpload:(UIImage*)photo
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(uploadPhoto:) object:photo requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"UploadingPhoto",@"HUD:Uploading Photo")];
}

#pragma mark EditLineVCDelegate methods

-(void)editLineVC:(EditLineVC*)editLineVC doneEditing:(NSString*)text
{
	switch (editLineVC.tag) {
		case kTagEditTextName:
			[self.beerObj.data setObject:text forKey:@"name"];
			break;
		case kTagEditTextABV:
			[self.beerObj.data setObject:[NSNumber numberWithFloat:[text floatValue]] forKey:@"abv"];
			break;
		case kTagEditTextIBU:
			[self.beerObj.data setObject:[NSNumber numberWithFloat:[text floatValue]] forKey:@"ibu"];
			break;
		case kTagEditTextOG:
			[self.beerObj.data setObject:[NSNumber numberWithFloat:[text floatValue]] forKey:@"og"];
			break;
		case kTagEditTextFG:
			[self.beerObj.data setObject:[NSNumber numberWithFloat:[text floatValue]] forKey:@"fg"];
			break;
		case kTagEditTextGrains:
			[self.beerObj.data setObject:text forKey:@"grains"];
			break;
		case kTagEditTextHops:
			[self.beerObj.data setObject:text forKey:@"hops"];
			break;
		case kTagEditTextOtherIngs:
			[self.beerObj.data setObject:text forKey:@"otherings"];
			break;
		case kTagEditTextCalories:
		{
			float f=((float)[text intValue])/355; // 355ml=12 fl.oz.
			[self.beerObj.data setObject:[NSNumber numberWithFloat:f] forKey:@"calories_per_ml"];
			break;
		}
		default:
			break;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
	[self.tableView reloadData];
}

#pragma mark Async operations

-(void)sendBeerReview:(NSDictionary*)reviewDoc
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];

	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_POST_BEER_REVIEW];
	NSString* bodystr=[[[NSString alloc] initWithFormat:@"rating=%@&beer_id=%@", [reviewDoc objectForKey:@"rating"], [reviewDoc objectForKey:@"beer_id"]] autorelease];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[appDelegate sendJSONRequest:url usingMethod:@"POST" withData:bodystr returningJSON:&answer];
	[appDelegate dismissActivityHUD];

	if ([response statusCode]==200) {
		self.userReviewData=answer;
		[self performSelectorOnMainThread:@selector(reviewPostSuccess:) withObject:answer waitUntilDone:NO];
	} else {
		// Inform the user that the review could not be posted
		[self performSelectorOnMainThread:@selector(reviewPostFailed) withObject:nil waitUntilDone:NO];
	}	
	
}

-(void)reviewPostSuccess:(NSDictionary*)reviewData
{
	FullBeerReviewTVC* fbrtvc=[[[FullBeerReviewTVC alloc] initWithReviewObject:self.userReviewData] autorelease];
	fbrtvc.delegate=self;
	[self.navigationController pushViewController:fbrtvc animated:YES];
}

-(void)reviewPostFailed
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sending Review",@"PostReview: failure alert title")
												  message:NSLocalizedString(@"Review not posted",@"PostReview: failure alert message")
												 delegate:nil
										cancelButtonTitle:NSLocalizedString(@"OK",@"PostReview: failure alert cancel button title")
										otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)saveEdits:(id)nothing
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];

	// Save data to server
	NSArray* keyNames=[NSArray arrayWithObjects:
					   @"name",
					   @"description",
					   @"abv",
					   @"ibu",
					   @"og",
					   @"fg",
					   @"srm",
					   @"calories_per_ml",
					   @"grains",
					   @"hops",
					   @"otherings",
					   @"availability",
					   @"styles",
					   nil
					   ];
	
	NSMutableArray* values=appendDifferentValuesToArray(keyNames,self.originalBeerData,self.beerObj.data);
	
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
		
		// Verify that the beer has a non-blank name
		NSString* beername=[[self.beerObj.data objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([beername length]==0)
		{
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil
														  message:NSLocalizedString(@"Beers must have a name",@"SaveBeerEdits: Beers must have a name")
														 delegate:nil
												cancelButtonTitle:NSLocalizedString(@"OK",@"SaveBeerEdits: OK button title")
												otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		else 
		{
			NSString* bodystr=[values componentsJoinedByString:@"&"];
			DLog(@"POST data:%@",bodystr);
			
			NSMutableDictionary* answer;
			NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_BEER_DOC];
			NSHTTPURLResponse* response=[appDelegate sendJSONRequest:url usingMethod:@"POST" withData:bodystr returningJSON:&answer];
			if ([response statusCode]==200)
			{
				self.beerObj.data=answer;
				normalizeBeerData(self.beerObj.data);
				
				[self.dataTableView removeFromSuperview];
				self.dataTableView=nil; // Causes it to be recreated in cellForRowAtIndexPath, which causes the updated data to appear
				
				[self.tableView reloadData];
				
				[self setEditing:NO animated:YES];
				[self.delegate didSaveBeerEdits];
			}
			else if ([response statusCode]==409) // Duplicate beer
			{
				[self performSelectorOnMainThread:@selector(saveEditsFailed:) withObject:[NSString stringWithFormat:NSLocalizedString(@"'%@' is already in Beer Crush",@"SaveBeerEdits: duplicate alert message"), beername] waitUntilDone:NO];
			}
			else
			{
				[self performSelectorOnMainThread:@selector(saveEditsFailed:) withObject:NSLocalizedString(@"Failed to save beer edits",@"SaveBeerEdits: failure alert message") waitUntilDone:NO];
			}
		}
	}
	else
	{
		[self.delegate didCancelBeerEdits];
	}
	
	[appDelegate dismissActivityHUD];
}

-(void)saveEditsFailed:(id)message_string
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Editing Beer",@"SaveBeerEdits: failure alert title")
												  message:message_string
												 delegate:nil
										cancelButtonTitle:NSLocalizedString(@"OK",@"SaveBeerEdits: failure alert cancel button title")
										otherButtonTitles:nil];
	[alert show];
	[alert release];
	
}
-(void)addToWishList:(id)aBeerID
{
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_WISHLIST_DOC];
	NSString* bodystr=[NSString stringWithFormat:@"add_item=%@",aBeerID];
	
	NSData* answer;
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:&answer];
	if ([response statusCode]==200)
	{
		// TODO: signify somehow that it worked
		// TODO: store new wishlist locally (the returned doc)
	}
	else
	{
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wish List",@"AddToWishList: failure alert title")
													  message:NSLocalizedString(@"Failed to save to wish list",@"AddToWishList: failure alert message")
													 delegate:nil
											cancelButtonTitle:NSLocalizedString(@"OK",@"AddToWishList: failure alert cancel button title")
											otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[appDelegate dismissActivityHUD];
}

-(void)uploadPhoto:(id)photoImage
{
	NSData* imageData=UIImageJPEGRepresentation(photoImage, 90);
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_UPLOAD_BEER_IMAGE,self.beerID]];
	NSData* answer;
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"POST" withData:imageData returningData:&answer];
	if ([response statusCode]==200)
	{
		DLog(@"Successfully uploaded photo");
		UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Your photo was sent to Beer Crush. It will appear soon.",@"Beer Page: photo uploaded") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	else {
		DLog(@"Failed to upload photo");
		UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"Oops" message:NSLocalizedString(@"BeerCrush didn't accept the photo for some reason. Please try again.",@"Beer Page: photo upload failed") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
	}

	[appDelegate dismissActivityHUD];
}

#pragma mark UIAlertView Delegate methods

- (void) alertView:(UIAlertView*)alert didDismissWithButtonIndex:(NSInteger)index
{
	// See http://www.iphonedevsdk.com/forum/iphone-sdk-development-advanced-discussion/17373-wait_fences-failed-receive-reply-10004003-a.html for an explanation for this.
    DLog(@"Doing nothing in didDismissWithButtonIndex to avoid 'wait_fences: failed to receive reply:' error message");
}

#pragma mark AvailabilityTVCDelegate methods

-(void)availabilityTVC:(AvailabilityTVC*)tvc didSelectAvailability:(NSString*)s
{
	[self.beerObj.data setObject:s forKey:@"availability"];
	[self.tableView reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Action Target methods

-(void)didCancelBeerEdits:(id)sender
{
	if (self.delegate)
		[self.delegate didCancelBeerEdits];
	else {
		[self setEditing:NO animated:YES];
	}

}

@end


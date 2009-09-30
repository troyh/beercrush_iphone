//
//  BreweryTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "PlaceTableViewController.h"
#import "ReviewsTableViewController.h"
#import "BeerListTableViewController.h"
#import "PhoneNumberEditTableViewController.h"
#import "RatingControl.h"
#import "JSON.h"
#import "PhotoThumbnailControl.h"

@implementation PlaceTableViewController

@synthesize placeID;
@synthesize placeData;
@synthesize originalPlaceData;
@synthesize delegate;
@synthesize userReviewData;

enum mytags {
	kTagEditTextOwnerDescription=1,
	kTagEditTextHours,
	kTagSwitchControlFreeWiFi,
	kTagSwitchControlOutdoorSeating,
	kTagSwitchControlKidFriendly,
	kTagSwitchControlBottlesCans,
	kTagSwitchControlGrowlers,
	kTagSwitchControlKegs,
	kTagEditTextPlaceName
};


-(id) initWithPlaceID:(NSString*)place_id
{
	self.placeID=place_id;
	
	self.title=@"Place";
	
	[super initWithStyle:UITableViewStyleGrouped];

	self.placeData=[[NSMutableDictionary alloc] initWithCapacity:10];
	normalizePlaceData(self.placeData);
	
	return self;
}

- (void)dealloc {
	[self.placeID release];
	[self.placeData release];
	[self.originalPlaceData release];
	
	[super dealloc];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	if (editing==YES)
	{
		[super setEditing:editing animated:animated];

		if (self.placeID)
			self.title=@"Editing Place";
		else
			self.title=@"New Place";

		[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editingPlaceCancelButtonClicked:)] autorelease]];

		[self.tableView beginUpdates];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationFade];

		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:
												[NSIndexPath indexPathForRow:1 inSection:0],
												nil] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];

		/* Note that NSDictionary does not recursively make copies, it seems to only make copies of the first
		   level. So deeper levels point to the original, which is wrong. */
		self.originalPlaceData=[[NSMutableDictionary alloc] initWithDictionary:self.placeData copyItems:YES];
	}
	else
	{
		NSArray* keyNames=[NSArray arrayWithObjects:
			@"name",
			@"phone",
			@"placestyle",
			@"placetype",
			@"uri",
			@"kid_friendly",
			@"description",
			@"restaurant:price_range",
			@"restaurant:outdoor_seating",
			@"restaurant:food_description",
			@"hours:open",
			@"@attributes:wifi",
			@"@attributes:bottled_beer_to_go",
			@"@attributes:growlers_to_go",
			@"@attributes:kegs_to_go",
			@"address:street",
			@"address:city",
			@"address:state",
			@"address:zip",
			@"address:country",
			nil
		];
		
		BOOL endEditMode=YES;

		if (self.placeID==nil)
		{
			if ([[self.placeData objectForKey:@"name"] length] == 0)
			{
				UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"Can't Save a New Place" message:@"The place must have a name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
				[alert show];
				
				endEditMode=NO;
			}
		}

		NSMutableArray* values=appendDifferentValuesToArray(keyNames,self.originalPlaceData,self.placeData);

		if ([values count])
		{
			// If we're editing an existing place (i.e., we have its ID), add place_id
			if (self.placeID)
				[values addObject:[NSString stringWithFormat:@"place_id=%@",self.placeID]];
			
			// Save data to server
			NSString* bodystr=[values componentsJoinedByString:@"&"];
			DLog(@"POST data:%@",bodystr);

			BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_PLACE_DOC];
			NSData* answer;
			NSHTTPURLResponse* response=[appDelegate sendRequest:url  usingMethod:@"POST" withData:bodystr returningData:&answer];
			
			if ([response statusCode]==200)
			{
				NSString* json=[[[NSString alloc] initWithData:answer encoding:NSUTF8StringEncoding] autorelease];
				self.placeData=[json JSONValue];
				normalizePlaceData(self.placeData);
			} 
			else 
			{
				endEditMode=NO;
				// TODO: inform the user that the download could not be made
			}	
		}

		if (endEditMode)
		{
			[super setEditing:editing animated:animated];

			self.title=@"Place";
			
			[self.tableView beginUpdates];
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:
													[NSIndexPath indexPathForRow:1 inSection:0],
													nil] withRowAnimation:UITableViewRowAnimationFade];
			
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView endUpdates];
			
			[self.delegate placeVCDidCancelEditing:self];
		}
	}
}


//- (void)editPlace:(id)sender
//{
////	UIBarButtonItem* button=(UIBarButtonItem*)sender;
////	button.style=UIBarButtonItemStyleDone;
//	self.editButtonItem.style=UIBarButtonItemStyleDone;
//	self.title=@"Editing Place";
//	[self.tableView setEditing:(self.tableView.editing==YES?NO:YES) animated:YES];
//}

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
//	 SEL oldsel=self.navigationItem.rightBarButtonItem.action;
//	 self.navigationItem.rightBarButtonItem.action=@selector(editPlace:);
//	 UINavigationController* nav=(UINavigationController*)self.parentViewController;
//	 [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPlace)]];

 }


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if (self.placeID==nil)
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
	}
	else
	{
		if (self.editing==YES)
		{
		}
		else
		{
			// Retrieve JSON doc for this place
			BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			[appDelegate performAsyncOperationWithTarget:self selector:@selector(getPlaceDoc:) object:self.placeID withActivityHUD:YES andActivityHUDText:NSLocalizedString(@"HUD:GettingPlaceInfo",@"Getting Place Info")];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.editing?6:7;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return self.editing?2:1;
			break;
		case 1:
			return self.editing?1:3;
			break;
		case 2:
			return self.editing?3:1;
			break;
		case 3:
			return self.editing?1:1;
			break;
		case 4:
			return self.editing?5:3;
			break;
		case 5:
			return self.editing?3:1;
			break;
		case 6:
			return self.editing?0:1;
			break;
		default:
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.editing)
	{
		switch (section) {
			case 3:
				return @"Owner's Description";
				break;
			case 4:
				return @"Details";
				break;
			case 5:
				return @"To Go";
				break;
			default:
				break;
		}
	}
	else 
	{
		switch (section) {
			case 5:
				return @"Owner's Description";
				break;
			case 6:
				return @"Details";
				break;
			default:
				break;
		}
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.editing)
	{
		switch (indexPath.section) {
			case 0: // Place name
				return 50;
				break;
			case 2:
				switch (indexPath.row) {
					case 0: // Address
						return 80;
						break;
					default:
						break;
				}
				break;
			case 3: // Owner's Description
				return 80;
				break;
			case 4: // Details
			{
				switch (indexPath.row) 
				{
					case 0:
						return 100;
						break;
					default:
						break;
				}
			}
			break;
		}
	}
	else 
	{
		switch (indexPath.section) {
			case 0: // Place name
				return 50;
				break;
			case 1:
			{
				switch (indexPath.row) {
					case 1: // Overall Ratings
						return 140;
						break;
					default:
						break;
				}
				break;
			}
			case 4:
			{
				switch (indexPath.row) {
					case 0: // Address
						return 80;
						break;
					default:
						break;
				}
				break;
			}
			case 5: // Owner's Description
				return 80;
				break;
			case 6: // Details
				return 130;
				break;
		}
	}
	
	return tableView.rowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  
    UITableViewCell *cell = nil;
    
	tableView.allowsSelectionDuringEditing=YES;

	if (self.editing)
	{
		switch (indexPath.section) {
			case 0:
			{
				switch (indexPath.row) {
					case 0:
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPlaceName"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditPlaceName"] autorelease];
							[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
						}
						
						[cell.textLabel setText:[self.placeData objectForKey:@"name"]];
						break;
					case 1:
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPlaceType"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditPlaceType"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[self.placeData objectForKey:@"placetype"]];
						[cell.textLabel setText:@"type"];
						break;
					default:
						break;
				}
				break;
			}
			case 1:
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"EditPlaceStyle"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditPlaceStyle"] autorelease];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				}
				
				BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
				NSDictionary* styleDict=[appDelegate getPlaceStylesDictionary];
				[cell.detailTextLabel setText:[[[styleDict objectForKey:@"byid"] objectForKey:[placeData objectForKey:@"placestyle"]] objectForKey:@"name"]];
				[cell.textLabel setText:@"style"];
				break;
			}
			case 2:
			{
				switch (indexPath.row) {
					case 0: // Address
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditAddress"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditAddress"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							cell.detailTextLabel.numberOfLines=3;
						}
						
						NSDictionary* addr;
						addr=[placeData objectForKey:@"address"];

						[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@%@ %@ %@\n%@",
													   [addr objectForKey:@"street"],
													   [addr objectForKey:@"city"],
													   ([[addr objectForKey:@"state"] length]?@",":@""),
													   [addr objectForKey:@"state"],
													   [addr objectForKey:@"zip"],
													   [addr objectForKey:@"country"]]];

						[cell.textLabel setText:@"address"];
						break;
					case 1: // Phone
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPhone"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditPhone"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[self.placeData objectForKey:@"phone"]];
						[cell.textLabel setText:@"phone"];
						break;
					case 2: // Web site
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditURI"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditURI"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[self.placeData objectForKey:@"uri"]];
						break;
					default:
						break;
				}
				break;
			}
			case 3: // Owner's Description
				cell = [tableView dequeueReusableCellWithIdentifier:@"EditOwnerDescription"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditOwnerDescription"] autorelease];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				}
				
				[cell.detailTextLabel setText:[self.placeData objectForKey:@"description"]];
				break;
			case 4: // Details
			{
				switch (indexPath.row) {
					case 0: // Hours
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditHours"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditHours"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[[self.placeData objectForKey:@"hours"] objectForKey:@"open"]];
						[cell.textLabel setText:@"hours"];
						break;
					case 1: // Price
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPrice"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditPrice"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						NSArray* dollars=[NSArray arrayWithObjects:@"",@"$",@"$$",@"$$$",@"$$$$",nil];
						NSUInteger n=[[[placeData objectForKey:@"restaurant"] objectForKey:@"price_range"] unsignedIntValue];
						[cell.detailTextLabel setText:[dollars objectAtIndex:n]];
						[cell.textLabel setText:@"price"];
						break;
					}
					case 2: // Free WiFi
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditWiFi"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditWiFi"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							UISwitch* switchControl=[[[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 30, 30)] autorelease];
							switchControl.tag=kTagSwitchControlFreeWiFi;
							[switchControl addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
							[cell.contentView addSubview:switchControl];
						}
						
						UISwitch* switchControl=(UISwitch*)[cell viewWithTag:kTagSwitchControlFreeWiFi];
						[switchControl setOn:[[[self.placeData objectForKey:@"@attributes"] objectForKey:@"wifi"] intValue]?YES:NO];
						[cell.textLabel setText:@"free wifi"];
						break;
					case 3: // Outdoor seating
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditOutdoorSeating"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditOutdoorSeating"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							UISwitch* switchControl=[[[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 30, 30)] autorelease];
							switchControl.tag=kTagSwitchControlOutdoorSeating;
							[switchControl addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
							[cell.contentView addSubview:switchControl];
						}
						
						UISwitch* switchControl=(UISwitch*)[cell viewWithTag:kTagSwitchControlOutdoorSeating];
						[switchControl setOn:([[[self.placeData objectForKey:@"restaurant"] objectForKey:@"outdoor_seating"] intValue]?YES:NO) animated:NO];
						[cell.textLabel setText:@"outdoor seating"];
						break;
					}
					case 4: // Kid-friendly
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditKidFriendly"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditKidFriendly"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							UISwitch* switchControl=[[[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 30, 30)] autorelease];
							switchControl.tag=kTagSwitchControlKidFriendly;
							[switchControl addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
							[cell.contentView addSubview:switchControl];
						}
						
						UISwitch* switchControl=(UISwitch*)[cell viewWithTag:kTagSwitchControlKidFriendly];
						[switchControl setOn:([[self.placeData objectForKey:@"kid_friendly"] intValue]?YES:NO) animated:NO];
						[cell.textLabel setText:@"kid-friendly"];
						break;
					}
					default:
						break;
				}
				break;
			}
				break;
			case 5: // To Go
			{
				switch (indexPath.row) {
					case 0: // Bottles/cans
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditBottlesCans"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditBottlesCans"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							UISwitch* switchControl=[[[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 30, 30)] autorelease];
							switchControl.tag=kTagSwitchControlBottlesCans;
							[switchControl addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
							[cell.contentView addSubview:switchControl];
						}
						
						UISwitch* switchControl=(UISwitch*)[cell viewWithTag:kTagSwitchControlBottlesCans];
						[switchControl setOn:[[[self.placeData objectForKey:@"@attributes"] objectForKey:@"bottled_beer_to_go"] intValue]?YES:NO];
						[cell.textLabel setText:@"bottles/cans"];
						break;
					case 1: // Growlers
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditGrowlers"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditGrowlers"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							UISwitch* switchControl=[[[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 30, 30)] autorelease];
							switchControl.tag=kTagSwitchControlGrowlers;
							[switchControl addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
							[cell.contentView addSubview:switchControl];
						}
						
						UISwitch* switchControl=(UISwitch*)[cell viewWithTag:kTagSwitchControlGrowlers];
						[switchControl setOn:[[[self.placeData objectForKey:@"@attributes"] objectForKey:@"growlers_to_go"] intValue]?YES:NO];
						[cell.textLabel setText:@"growlers"];
						break;
					}
					case 2: // Kegs
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditKegs"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditKegs"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							UISwitch* switchControl=[[[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 30, 30)] autorelease];
							switchControl.tag=kTagSwitchControlKegs;
							[switchControl addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
							[cell.contentView addSubview:switchControl];
						}
						
						UISwitch* switchControl=(UISwitch*)[cell viewWithTag:kTagSwitchControlKegs];
						[switchControl setOn:[[[self.placeData objectForKey:@"@attributes"] objectForKey:@"kegs_to_go"] intValue]?YES:NO];
						[cell.textLabel setText:@"kegs"];
						break;
					}
					default:
						break;
				}
				break;
			}
			default:
				break;
		}
	}
	else 
	{
		switch (indexPath.section) 
		{
			case 0: // Name & Photo
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceName"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PlaceName"] autorelease];
					
					UILabel* nameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 0, 220, 45)] autorelease];
					nameLabel.font=[UIFont boldSystemFontOfSize:20];
					nameLabel.backgroundColor=[UIColor clearColor];
					nameLabel.numberOfLines=2;
					nameLabel.adjustsFontSizeToFitWidth=YES;
					nameLabel.minimumFontSize=14.0;
					nameLabel.lineBreakMode=UILineBreakModeWordWrap;
					nameLabel.tag=1;
					
					UILabel* styleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 40, 220, 20)] autorelease];
					styleLabel.font=[UIFont boldSystemFontOfSize:15];
					styleLabel.textColor=[UIColor grayColor];
					styleLabel.backgroundColor=[UIColor clearColor];
					styleLabel.text=[self.placeData objectForKey:@"placestyle"];
					styleLabel.tag=2;
					
					PhotoThumbnailControl* photo=[[[PhotoThumbnailControl alloc] initWithFrame:CGRectMake(0, 0, 75, 75)] autorelease];
					[photo addTarget:self action:@selector(photoThumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
					
					[cell.contentView addSubview:nameLabel];
					[cell.contentView addSubview:styleLabel];
					[cell.contentView addSubview:photo];
					
					UIView* transparentBackground=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
					transparentBackground.backgroundColor=[UIColor clearColor];
					cell.backgroundView=transparentBackground;
					cell.backgroundColor=[UIColor clearColor];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
				}
				
				[(UILabel*)[cell.contentView viewWithTag:1] setText:[self.placeData objectForKey:@"name"]];
				BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
				NSDictionary* styleDict=[appDelegate getPlaceStylesDictionary];
				[(UILabel*)[cell.contentView viewWithTag:2] setText:[[[styleDict objectForKey:@"byid"] objectForKey:[self.placeData objectForKey:@"placestyle"]] objectForKey:@"name"]];
				break;
			}
			case 1: // My Rating, others' ratings and reviews
			{
				switch (indexPath.row) {
					case 0: // My Rating
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"MyRating"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"MyRating"] autorelease];
							[cell.textLabel setText:@"My Rating"];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;

							RatingControl* ratingctl=[[[RatingControl alloc] initWithFrame:CGRectMake(80, 7, 180, 30)] autorelease];
							ratingctl.tag=1;
							// Set the callback for a review
							[ratingctl addTarget:self action:@selector(ratingButtonTapped:event:) forControlEvents:UIControlEventValueChanged];
							
							[cell.contentView addSubview:ratingctl];
						}

						// Set current user's rating (if any)
						NSString* user_rating=[self.placeData objectForKey:@"user_rating"];
						if (user_rating!=nil) // No user review
						{
							RatingControl* ratingctl=(RatingControl*)[cell viewWithTag:1];
							ratingctl.currentRating=[user_rating integerValue];
							DLog(@"Current rating:%d",ratingctl.currentRating);
							cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
						}
						
						break;
					}
					case 1: // Others' overall ratings
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"OverallRating"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OverallRating"] autorelease];
							[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							UILabel* overallRatingLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10,   7, 70, 30)] autorelease];
							UILabel* serviceRatingLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10,  40, 70, 30)] autorelease];
							UILabel* atmosphRatingLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10,  73, 70, 30)] autorelease];
							UILabel* foodRatingLabel   =[[[UILabel alloc] initWithFrame:CGRectMake(10, 106, 70, 30)] autorelease];
							
							[overallRatingLabel setText:[NSString stringWithFormat:@"%d Ratings",0]];
							overallRatingLabel.font=[UIFont systemFontOfSize:12];
							overallRatingLabel.textAlignment=UITextAlignmentRight;
							overallRatingLabel.textColor=[UIColor blueColor];
							
							[serviceRatingLabel setText:@"service"];
							serviceRatingLabel.font=[UIFont systemFontOfSize:12];
							serviceRatingLabel.textAlignment=UITextAlignmentRight;
							serviceRatingLabel.textColor=[UIColor blueColor];
							
							[atmosphRatingLabel setText:@"atmosphere"];
							atmosphRatingLabel.font=[UIFont systemFontOfSize:12];
							atmosphRatingLabel.textAlignment=UITextAlignmentRight;
							atmosphRatingLabel.textColor=[UIColor blueColor];
							
							[foodRatingLabel    setText:@"food"];
							foodRatingLabel.font=[UIFont systemFontOfSize:12];
							foodRatingLabel.textAlignment=UITextAlignmentRight;
							foodRatingLabel.textColor=[UIColor blueColor];
							
							[cell.contentView addSubview:overallRatingLabel];
							[cell.contentView addSubview:serviceRatingLabel];
							[cell.contentView addSubview:atmosphRatingLabel];
							[cell.contentView addSubview:foodRatingLabel];
							
							RatingControl* overallRating=[[[RatingControl alloc] initWithFrame:CGRectMake(80,   7, 180, 30)] autorelease];
							RatingControl* serviceRating=[[[RatingControl alloc] initWithFrame:CGRectMake(80,  40, 180, 30)] autorelease];
							RatingControl* atmosphRating=[[[RatingControl alloc] initWithFrame:CGRectMake(80,  73, 180, 30)] autorelease];
							RatingControl* foodRating   =[[[RatingControl alloc] initWithFrame:CGRectMake(80, 106, 180, 30)] autorelease];
							
							[cell.contentView addSubview:overallRating];
							[cell.contentView addSubview:serviceRating];
							[cell.contentView addSubview:atmosphRating];
							[cell.contentView addSubview:foodRating];
						}
						
						break;
					}
					case 2: // Reviews
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Reviews"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Reviews"] autorelease];
							[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						break;
					}
				}
				break;
			}
			case 2: // Available Beers
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"AvailableBeers"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditNameCell"] autorelease];
					[cell.textLabel setText:[NSString stringWithFormat:@"%d Available Beers",0]];
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				}
				break;
			}
			case 3: // Affiliations
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Affiliations"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Affiliations"] autorelease];
					[cell.textLabel setText:[NSString stringWithFormat:@"Affiliated with %@",@""]];
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				}
				break;
			}
			case 4: // Map, phone and web
			{
				switch (indexPath.row)
				{
					case 0: // Address
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Address"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Address"] autorelease];
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							
							[cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
							cell.detailTextLabel.numberOfLines=3;

							[cell.textLabel setText:@"map"];
						}

						NSDictionary* addr;
						addr=[placeData objectForKey:@"address"];
						
						[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@, %@ %@\n%@",
													   [addr objectForKey:@"street"],
												 [addr objectForKey:@"city"],
												 [addr objectForKey:@"state"],
												 [addr objectForKey:@"zip"],
												 [addr objectForKey:@"country"]]];
						break;
					}
					case 1: // Phone
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Phone"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Phone"] autorelease];
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
							[cell.textLabel setText:@"call"];
						}
						[cell.detailTextLabel setText:[self.placeData objectForKey:@"phone"]];
						break;
					}
					case 2: // Web site
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"URI"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"URI"] autorelease];
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.textLabel setText:[self.placeData objectForKey:@"uri"]];
						break;
					}
					default:
						break;
				}
				break;
			}
			case 5: // Owner's Description
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"OwnerDescription"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"OwnerDescription"] autorelease];
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					cell.textLabel.numberOfLines=3;
					cell.textLabel.font=[UIFont systemFontOfSize:15];
				}
				
				[cell.textLabel setText:[self.placeData objectForKey:@"description"]];
				break;
			}
			case 6: // Details
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Details"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Details"] autorelease];
					
					UILabel* hoursLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 20)] autorelease];
					hoursLabel.font=[UIFont systemFontOfSize:12];
					hoursLabel.textColor=[UIColor blueColor];
					hoursLabel.textAlignment=UITextAlignmentRight;
					[hoursLabel setText:@"hours"];

					UILabel* priceLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10, 25, 80, 20)] autorelease];
					priceLabel.font=[UIFont systemFontOfSize:12];
					priceLabel.textColor=[UIColor blueColor];
					priceLabel.textAlignment=UITextAlignmentRight;
					[priceLabel	setText:@"price"];

					UILabel* kidFriendlyLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10, 45, 80, 20)] autorelease];
					kidFriendlyLabel.font=[UIFont systemFontOfSize:12];
					kidFriendlyLabel.textColor=[UIColor blueColor];
					kidFriendlyLabel.textAlignment=UITextAlignmentRight;
					[kidFriendlyLabel setText:@"kid-friendly"];

					UILabel* togoLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10, 65, 80, 20)] autorelease];
					togoLabel.font=[UIFont systemFontOfSize:12];
					togoLabel.textColor=[UIColor blueColor];
					togoLabel.textAlignment=UITextAlignmentRight;
					[togoLabel setText:@"to go"];

					UILabel* wifiLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10, 85, 80, 20)] autorelease];
					wifiLabel.font=[UIFont systemFontOfSize:12];
					wifiLabel.textColor=[UIColor blueColor];
					wifiLabel.textAlignment=UITextAlignmentRight;
					[wifiLabel setText:@"wifi"];

					UILabel* outdoorSeatingLabel=[[[UILabel alloc] initWithFrame:CGRectMake(10, 105, 80, 20)] autorelease];
					outdoorSeatingLabel.font=[UIFont systemFontOfSize:12];
					outdoorSeatingLabel.textColor=[UIColor blueColor];
					outdoorSeatingLabel.textAlignment=UITextAlignmentRight;
					[outdoorSeatingLabel setText:@"outdoor seating"];
					
					UILabel* hoursTextLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 200, 20)] autorelease];
					hoursTextLabel.font=[UIFont boldSystemFontOfSize:12];
					hoursTextLabel.tag=1;
					
					UILabel* priceTextLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100, 25, 200, 20)] autorelease];
					priceTextLabel.font=[UIFont boldSystemFontOfSize:12];
					priceTextLabel.tag=2;

					UILabel* kidFriendlyTextLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100, 45, 200, 20)] autorelease];
					kidFriendlyTextLabel.font=[UIFont boldSystemFontOfSize:12];
					kidFriendlyTextLabel.tag=3;

					UILabel* togoTextLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100, 65, 200, 20)] autorelease];
					togoTextLabel.font=[UIFont boldSystemFontOfSize:12];
					togoTextLabel.tag=4;

					UILabel* wifiTextLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100, 85, 200, 20)] autorelease];
					wifiTextLabel.font=[UIFont boldSystemFontOfSize:12];
					wifiTextLabel.tag=5;

					UILabel* outdoorSeatingTextLabel=[[[UILabel alloc] initWithFrame:CGRectMake(100, 105, 200, 20)] autorelease];
					outdoorSeatingTextLabel.font=[UIFont boldSystemFontOfSize:12];
					outdoorSeatingTextLabel.tag=6;

					[cell.contentView addSubview:hoursLabel];
					[cell.contentView addSubview:hoursTextLabel];
					[cell.contentView addSubview:priceLabel];
					[cell.contentView addSubview:priceTextLabel];
					[cell.contentView addSubview:kidFriendlyLabel];
					[cell.contentView addSubview:kidFriendlyTextLabel];
					[cell.contentView addSubview:togoLabel];
					[cell.contentView addSubview:togoTextLabel];
					[cell.contentView addSubview:wifiLabel];
					[cell.contentView addSubview:wifiTextLabel];
					[cell.contentView addSubview:outdoorSeatingLabel];
					[cell.contentView addSubview:outdoorSeatingTextLabel];
				}
				
				[(UILabel*)[cell.contentView viewWithTag:1] setText:[[self.placeData objectForKey:@"hours"] objectForKey:@"open"]];

				NSArray* dollars=[NSArray arrayWithObjects:@"",@"$",@"$$",@"$$$",@"$$$$",nil];
				[(UILabel*)[cell.contentView viewWithTag:2] setText:[dollars objectAtIndex:[[[self.placeData objectForKey:@"restaurant"] objectForKey:@"price_range"] integerValue]]];
				[(UILabel*)[cell.contentView viewWithTag:3] setText:[self.placeData objectForKey:@"kid_friendly"]?@"yes":@"no"];
		
				NSMutableArray* togoValues=[NSMutableArray arrayWithCapacity:3];
				if ([[[self.placeData objectForKey:@"@attributes"] objectForKey:@"bottled_beer_to_go"] boolValue])
					[togoValues addObject:@"bottles/cans"];
				if ([[[self.placeData objectForKey:@"@attributes"] objectForKey:@"growlers_to_go"] boolValue])
					[togoValues addObject:@"growlers"];
				if ([[[self.placeData objectForKey:@"@attributes"] objectForKey:@"kegs_to_go"] boolValue])
					[togoValues addObject:@"kegs"];
				[(UILabel*)[cell.contentView viewWithTag:4] setText:[togoValues componentsJoinedByString:@", "]];

				[(UILabel*)[cell.contentView viewWithTag:5] setText:[[[self.placeData objectForKey:@"@attributes"] objectForKey:@"wifi"] boolValue] ?@"yes":@"no"];
				[(UILabel*)[cell.contentView viewWithTag:6] setText:[[[self.placeData objectForKey:@"restaurant"] objectForKey:@"outdoor_seating"] boolValue]?@"yes":@"no"];

				break;
			}
		}
	}
	
    return cell;
}

-(void)ratingButtonTapped:(id)sender event:(id)event
{
	RatingControl* ctl=(RatingControl*)sender;
	NSInteger rating=ctl.currentRating;
	
	// Send the review to the site
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(sendReview:) object:[NSNumber numberWithInt:rating] withActivityHUD:YES andActivityHUDText:NSLocalizedString(@"HUD:SendingReview",@"Sending Review")];
}

-(void)photoThumbnailClicked:(id)sender
{
	NSArray* photoList=[NSArray arrayWithObjects:@"beer.png",@"brewery.png",@"bar.png",nil];
	PhotoViewer* viewer=[[[PhotoViewer alloc] initWithPhotoList:photoList] autorelease];
	viewer.delegate=self;
	[self.navigationController pushViewController:viewer animated:YES];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (self.editing)
	{
		switch (indexPath.section) {
			case 0:
			{
				switch (indexPath.row) {
					case 0: // Place Name
					{
						EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
						vc.tag=kTagEditTextPlaceName;
						vc.delegate=self;
						vc.textToEdit=[self.placeData objectForKey:@"name"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 1: // Place type
					{
						PlaceTypeTVC* ptvc=[[[PlaceTypeTVC alloc] init] autorelease];
						ptvc.delegate=self;
						ptvc.currentlySelectedType=[self.placeData objectForKey:@"placetype"];
						[self.navigationController pushViewController:ptvc animated:YES];
						break;
					}
					default:
						break;
				}
				break;
			}
			case 1: // Place style (i.e., cuisine)
			{
				PlaceStyleTVC* pstvc=[[[PlaceStyleTVC alloc] init] autorelease];
				pstvc.delegate=self;
				pstvc.currentlySelectedStyle=[self.placeData objectForKey:@"placestyle"];
				[self.navigationController pushViewController:pstvc animated:YES];
				break;
			}
			case 2:
			{
				switch (indexPath.row) {
					case 0: // Address
					{
						EditAddressVC* vc=[[[EditAddressVC alloc] init] autorelease];
						vc.delegate=self;
						vc.addressToEdit=[self.placeData objectForKey:@"address"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 1: // Phone
					{
						PhoneNumberEditTableViewController* vc=[[[PhoneNumberEditTableViewController alloc] init] autorelease];
						vc.delegate=self;
						vc.phoneNumberToEdit=[self.placeData objectForKey:@"phone"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 2: // Web site
					{
						EditURIVC* vc=[[[EditURIVC alloc] init] autorelease];
						vc.delegate=self;
						vc.uriToEdit=[self.placeData objectForKey:@"uri"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					default:
						break;
				}
				break;
			}
			case 3: // Owner's Description
			{
				EditTextVC* vc=[[[EditTextVC alloc] init] autorelease];
				vc.tag=kTagEditTextOwnerDescription;
				vc.delegate=self;
				vc.textToEdit=[self.placeData objectForKey:@"description"];
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			case 4: // Details section
			{
				switch (indexPath.row) {
					case 0: // Hours
					{
						EditTextVC* vc=[[[EditTextVC alloc] init] autorelease];
						vc.tag=kTagEditTextHours;
						vc.delegate=self;
						vc.textToEdit=[[self.placeData objectForKey:@"restaurant"] objectForKey:@"hours"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 1: // Price
					{
						PlacePriceTVC* pptvc=[[[PlacePriceTVC alloc] init] autorelease];
						pptvc.delegate=self;
						pptvc.currentlySelectedPrice=[[[self.placeData objectForKey:@"restaurant"] objectForKey:@"price_range"] unsignedIntValue];
						[self.navigationController pushViewController:pptvc animated:YES];
					}
						break;
					case 2: // Free WiFi
						break;
					case 3: // Outdoor seating
						break;
					case 4: // Kid-friendly
						break;
					default:
						break;
				}
				break;
			}
			case 5: // To Go section
			{
				switch (indexPath.row) {
					case 0: // Bottles/cans
						break;
					case 1: // Growlers
						break;
					case 2: // Kegs
						break;
					default:
						break;
				}
				break;
			}
			default:
				break;
		}
		
	}
	else 
	{
		switch (indexPath.section) 
		{
			case 0: // Place Name
				break;
			case 1:
			{
				switch (indexPath.row) {
					case 0: // My Rating
					{
						break;
					}
					case 1: // Overall ratings
					{
						ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.placeID dataType:Place];
						[self.navigationController pushViewController: rtvc animated:YES];
						[rtvc release];
						break;
					}
					case 2: // Reviews
					{
						break;
					}
					default:
						break;
				}
				break;
			}
			case 2: // Available Beers
			{
				BeerListTableViewController* bltvc=[[BeerListTableViewController alloc] initWithBreweryID:self.placeID];
				[self.navigationController pushViewController: bltvc animated:YES];
				[bltvc release];
				break;
			}
			case 3: // Affiliated With
			{
				break;
			}
			case 4:
			{
				switch (indexPath.row) {
					case 0: // Address
					{
						NSMutableDictionary* addr=[placeData valueForKey:@"address"];
						NSString* url=[[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@, %@ %@ %@",
										[addr objectForKey:@"street"],
										[addr objectForKey:@"city"],
										[addr objectForKey:@"state"],
										[addr objectForKey:@"zip"]] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
						
						DLog(@"Opening URL:%@",url);
						[[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:url ] autorelease]];
						break;
					}
					case 1: // Phone
					{
						NSString* s=[[[[placeData valueForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""] 
									  stringByReplacingOccurrencesOfString:@"(" withString:@""] 
									 stringByReplacingOccurrencesOfString:@")" withString:@""];
						NSString* url=[NSString stringWithFormat:@"tel:%@",s];
						DLog(@"Opening URL:%@", url);
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
						break;
					}
					case 2: // Web site
					{
						[[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:[placeData valueForKey:@"uri"]] autorelease]];
						break;
					}
					default:
						break;
				}
				break;
			}
		}
	}
}


 // Override to support conditional editing of the table view.
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


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

#pragma mark EditLineVCDelegate methods

-(void)editLineVC:(EditLineVC*)editLineVC didChangeText:(NSString*)text
{
	if (editLineVC.tag==kTagEditTextPlaceName)
		[self.placeData setObject:text forKey:@"name"];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark EditTextVCDelegate methods

-(void)editTextVC:(id)sender didChangeText:(NSString*)text
{
	EditTextVC* vc=(EditTextVC*)sender;
	if (vc.tag==kTagEditTextOwnerDescription)
		[self.placeData setObject:text forKey:@"description"];
	else if (vc.tag==kTagEditTextHours)
		[[self.placeData objectForKey:@"hours"] setObject:text forKey:@"open"];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PlaceTypeTVCDelegate methods

-(void)placeType:(PlaceTypeTVC*)placeType didSelectType:(NSString*)typeName
{
	[self.placeData setObject:typeName forKey:@"placetype"];
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark PlaceStyleTVCDelegate methods

-(void)placeStyleTVC:(id)placeStyleTVC didSelectStyle:(NSDictionary*)style
{
	DLog(@"Selected style:%@ (id=%@)",[style objectForKey:@"name"], [style objectForKey:@"id"]);
	[self.placeData setObject:[style objectForKey:@"id"] forKey:@"placestyle"];
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark PlacePriceTVCDelegate methods

-(void)placePriceTVC:(PlacePriceTVC*)tvc didSelectPrice:(NSUInteger)price
{
	[[self.placeData objectForKey:@"restaurant"] setValue:[NSNumber numberWithUnsignedInt:price] forKey:@"price_range"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Target Action methods

-(void)toggleSwitchChanged:(id)sender
{
	UISwitch* switchControl=(UISwitch*)sender;
	switch (switchControl.tag) {
		case kTagSwitchControlFreeWiFi:
			[[self.placeData objectForKey:@"@attributes"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"wifi"];
			break;
		case kTagSwitchControlOutdoorSeating:
			[[self.placeData objectForKey:@"restaurant"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"outdoor_seating"];
			break;
		case kTagSwitchControlKidFriendly:
			[self.placeData setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"kid_friendly"];
			break;
		case kTagSwitchControlBottlesCans:
			[[self.placeData objectForKey:@"@attributes"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"bottled_beer_to_go"];
			break;
		case kTagSwitchControlGrowlers:
			[[self.placeData objectForKey:@"@attributes"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"growlers_to_go"];
			break;
		case kTagSwitchControlKegs:
			[[self.placeData objectForKey:@"@attributes"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"kegs_to_go"];
			break;
		default:
			break;
	}
}

-(void)editingPlaceCancelButtonClicked:(id)sender
{
	[self.delegate placeVCDidCancelEditing:self];
}

#pragma mark EditAddressVCDelegate methods

-(void)editAddressVC:(EditAddressVC *)editAddressVC didEditAddress:(NSDictionary *)dict
{
	[self.placeData setObject:dict forKey:@"address"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark EditURIVCDelegate methods

-(void)editURIVC:(EditURIVC *)editURIVC didEditURI:(NSString *)uri
{
	[self.placeData setObject:uri forKey:@"uri"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PhoneNumberEditVCDelegate methods

-(void)editPhoneNumber:(PhoneNumberEditTableViewController*)editPhoneNumber didChangePhoneNumber:(NSString*)phoneNumber
{
	[self.placeData setObject:phoneNumber forKey:@"phone"];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)editPhoneNumberdidCancelEdit:(PhoneNumberEditTableViewController*)editPhoneNumber
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PhotoViewerDelegate methods

-(void)photoViewer:(PhotoViewer*)photoViewer didSelectPhotoToUpload:(UIImage*)photo
{
	NSData* imageData=UIImageJPEGRepresentation(photo, 1.0);
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_UPLOAD_PLACE_IMAGE,self.placeID]];
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

#pragma mark Async operations

-(void)getPlaceDoc:(NSString*)aPlaceID
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.placeData=[appDelegate getPlaceDoc:aPlaceID];
	[self.tableView reloadData];
	[appDelegate dismissActivityHUD];
	
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(getUserReviewDoc:) object:self.placeID withActivityHUD:YES andActivityHUDText:NSLocalizedString(@"HUD:GettingPlaceInfo", @"Getting Place Info")];
}

-(void)getUserReviewDoc:(NSString*)aPlaceID
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.userReviewData=[appDelegate getPlaceReviews:aPlaceID byUser:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]];
	[self.tableView reloadData];
	[appDelegate dismissActivityHUD];
}

-(void)sendReview:(NSNumber*)rating
{
	NSString* bodystr=[[[NSString alloc] initWithFormat:@"rating=%@&place_id=%@", rating, self.placeID] autorelease];
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_POST_PLACE_REVIEW];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[appDelegate sendJSONRequest:url usingMethod:@"POST" withData:bodystr returningJSON:&answer];
	if ([response statusCode]==200)
	{
		self.userReviewData=answer;
		normalizePlaceReviewData(self.userReviewData);
	}
	
	[appDelegate dismissActivityHUD];
}

@end


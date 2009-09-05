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

@implementation PlaceTableViewController

@synthesize placeID;
@synthesize placeObject;
@synthesize currentElemValue;
@synthesize xmlPostResponse;
@synthesize overlay;
@synthesize spinner;
@synthesize xmlParserPath;

enum mytags {
	kTagEditTextOwnerDescription=1,
	kTagEditTextHours,
	kTagEditTextMeals,
	kTagSwitchControlFreeWiFi,
	kTagSwitchControlOutdoorSeating,
	kTagSwitchControlKidFriendly,
	kTagSwitchControlBottlesCans,
	kTagSwitchControlGrowlers,
	kTagSwitchControlKegs
};


-(id) initWithPlaceID:(NSString*)place_id
{
	self.placeID=place_id;
	self.overlay=nil;
	self.spinner=nil;
	self.xmlPostResponse=nil;
	self.currentElemValue=nil;
	self.xmlParserPath=[NSMutableArray arrayWithCapacity:10];
	
	self.title=@"Place";
	
	[super initWithStyle:UITableViewStyleGrouped];
	
	placeObject=[[PlaceObject alloc] init];
	
	
//	NSArray* parts=[self.placeID componentsSeparatedByString:@":"];
//	
//	// Retrieve XML doc from server
//	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_PLACE_DOC, [parts objectAtIndex:1]]];
//	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
//	[parser setDelegate:self];
//	[parser parse];
	
	return self;
}

- (void)dealloc {
	[self.placeID release];
	[self.placeObject release];
	[super dealloc];
}

void appendValuesToPostBodyString(NSMutableString* bodystr,NSMutableDictionary* orig,NSDictionary* newvalues,NSString* prefix)
{
	NSEnumerator* iter=[newvalues keyEnumerator];
	id key;
	while ((key=[iter nextObject])!=nil)
	{
		[orig setObject:[newvalues objectForKey:key] forKey:key];
		
		if ([key isKindOfClass:[NSString class]]) // Just make sure, they should always be NSStrings
		{
			id obj=[newvalues objectForKey:key];
			if ([obj isKindOfClass:[NSDictionary class]])
			{
//				[bodystr appendFormat:@"&address:city=%@",[s stringByReplacingOccurrencesOfString:@"&" withString:@"%26"]];
				NSMutableString* newprefix=[NSMutableString string];
				[newprefix appendFormat:@"%@%@:",prefix,key];
//				[newprefix appendString:prefix];
//				[newprefix appendString:key];
//				[newprefix appendString:@":"];
					
				appendValuesToPostBodyString(bodystr,orig,obj,newprefix);
			}
			else if ([obj isKindOfClass:[NSString class]])
			{
				NSString* s=obj;
				[bodystr appendFormat:@"&%@%@=%@",prefix,key,[s stringByReplacingOccurrencesOfString:@"&" withString:@"%26"]];
			}
		}
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	if (editing==YES)
	{
		self.title=@"Editing Place";

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
		
		// Initialize editeddata
		if (self.placeObject.editeddata)
			[self.placeObject.editeddata release];
		self.placeObject.editeddata=[[NSMutableDictionary alloc] initWithCapacity:10];
	}
	else
	{
//		if (self.placeObject.editeddata && [self.placeObject.editeddata count])
//		{
//			// Save data to server
//			NSMutableString* bodystr=[[[NSMutableString alloc] initWithFormat:@"place_id=%@",self.placeID] autorelease];
//			// Copy edited data fields to the real data fields
//			appendValuesToPostBodyString(bodystr,self.placeObject.data,self.placeObject.editeddata,@"");
//			
//			DLog(@"POST data:%@",bodystr);
//			NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];
//			
//			NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_PLACE_DOC]
//																	cachePolicy:NSURLRequestUseProtocolCachePolicy
//																timeoutInterval:60.0];
//			[theRequest setHTTPMethod:@"POST"];
//			[theRequest setHTTPBody:body];
//			[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//			
//			// create the connection with the request and start loading the data
//			NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
//			
//			if (theConnection) {
//				// Create the NSMutableData that will hold
//				// the received data
//				// receivedData is declared as a method instance elsewhere
//				xmlPostResponse=[[NSMutableData data] retain];
//			} else {
//				// TODO: inform the user that the download could not be made
//			}	
//			
//			[self.placeObject.editeddata removeAllObjects];
//			[self.placeObject.editeddata release];
//			self.placeObject.editeddata=nil;
//		}
		
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
		self.title=@"New Place";
	}
	else
	{
		if (self.editing==YES)
		{
		}
		else
		{
			// Separate the 2 parts of the place ID
			NSArray* idparts=[self.placeID componentsSeparatedByString:@":"];

			// Retrieve XML doc for this place
			NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_PLACE_DOC, [idparts objectAtIndex:1]]];
			NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
			[parser setDelegate:self];
			BOOL retval=[parser parse];
			[parser release];
			
			if (retval==YES)
			{
				// Retrieve user's review for this place (if any)
				url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_PLACE_REVIEW_DOC, 
										  [idparts objectAtIndex:1], 
										  [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]]];
				parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
				[parser setDelegate:self];
				retval=[parser parse];
				[parser release];
				
				if (retval==YES)
				{
					// The user has a review for this place
					DLog(@"User rating:%@", [self.placeObject.data objectForKey:@"user_rating"]);
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
			return self.editing?6:3;
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
			case 3: // Owner's Description
				return 80;
				break;
			case 4: // Details
			{
				switch (indexPath.row) 
				{
					case 0:
					case 1:
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
						return 100;
						break;
					default:
						break;
				}
				break;
			}
			case 4:
			{
				switch (indexPath.row) {
					case 0:
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
				return 100;
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
						
						[cell.textLabel setText:[placeObject.data valueForKey:@"name"]];
						break;
					case 1:
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPlaceType"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditPlaceType"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[placeObject.data valueForKey:@"placetype"]];
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
				
				[cell.detailTextLabel setText:[placeObject.data valueForKey:@"placestyle"]];
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
						}
						
						[cell.detailTextLabel setText:[placeObject.data valueForKey:@""]];
						[cell.textLabel setText:@"address"];
						break;
					case 1: // Phone
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPhone"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditPhone"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[placeObject.data valueForKey:@""]];
						[cell.textLabel setText:@"phone"];
						break;
					case 2: // Web site
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditURI"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditURI"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[placeObject.data valueForKey:@"uri"]];
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
				
				[cell.detailTextLabel setText:[self.placeObject.data objectForKey:@"description"]];
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
						
						[cell.detailTextLabel setText:[placeObject.data objectForKey:@"hours"]];
						[cell.textLabel setText:@"hours"];
						break;
					case 1: // Meals
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditMeals"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditMeals"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.detailTextLabel setText:[placeObject.data objectForKey:@"meals"]];
						[cell.textLabel setText:@"meals"];
						break;
					case 2: // Price
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPrice"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditPrice"] autorelease];
							cell.selectionStyle=UITableViewCellSelectionStyleNone;
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						NSArray* dollars=[NSArray arrayWithObjects:@"",@"$",@"$$",@"$$$",@"$$$$",nil];
						NSUInteger n=[[placeObject.data valueForKey:@"price"] unsignedIntValue];
						[cell.detailTextLabel setText:[dollars objectAtIndex:n]];
						[cell.textLabel setText:@"price"];
						break;
					}
					case 3: // Free WiFi
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
						[switchControl setOn:[self.placeObject.data objectForKey:@"freewifi"]?YES:NO];
						[cell.textLabel setText:@"free wifi"];
						break;
					case 4: // Outdoor seating
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
						[switchControl setOn:[self.placeObject.data objectForKey:@"outdoorseating"]?YES:NO];
						[cell.textLabel setText:@"outdoor seating"];
						break;
					}
					case 5: // Kid-friendly
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
						[switchControl setOn:[self.placeObject.data objectForKey:@"kidfriendly"]?YES:NO];
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
						[switchControl setOn:[[self.placeObject.data objectForKey:@"togo"] objectForKey:@"bottlescans"]?YES:NO];
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
						[switchControl setOn:[[self.placeObject.data objectForKey:@"togo"] objectForKey:@"growlers"]?YES:NO];
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
						[switchControl setOn:[[self.placeObject.data objectForKey:@"togo"] objectForKey:@"kegs"]?YES:NO];
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
					[cell.textLabel setFont:[UIFont boldSystemFontOfSize:20]];
					cell.textLabel.backgroundColor=[UIColor clearColor];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					UIView* transparentBackground=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
					transparentBackground.backgroundColor=[UIColor clearColor];
					cell.backgroundView=transparentBackground;
					cell.backgroundColor=[UIColor clearColor];
				}
				
				[cell.textLabel setText:[placeObject.data valueForKey:@"name"]];
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
						NSString* user_rating=[self.placeObject.data objectForKey:@"user_rating"];
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
						addr=[placeObject.data objectForKey:@"address"];
						
						[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@, %@ %@ %@",
												 [addr objectForKey:@"street"],
												 [addr objectForKey:@"city"],
												 [addr objectForKey:@"state"],
												 [addr objectForKey:@"zip"]]];
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
						
						[cell.detailTextLabel setText:[placeObject.data valueForKey:@"phone"]];
						break;
					}
					case 2: // Web site
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"URI"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"URI"] autorelease];
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						
						[cell.textLabel setText:[placeObject.data valueForKey:@"uri"]];
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
				}
				
				[cell.textLabel setText:[placeObject.data valueForKey:@"description"]];
				break;
			}
			case 6: // Details
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Details"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Details"] autorelease];
				}
				
				break;
			}
		}
	}
	
    return cell;
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
	
	NSString* bodystr=[[[NSString alloc] initWithFormat:@"rating=%u&place_id=%@", rating, placeID] autorelease];
	NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_POST_PLACE_REVIEW]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:30.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:body];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
	
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

	if (self.editing)
	{
		switch (indexPath.section) {
			case 0:
			{
				switch (indexPath.row) {
					case 0: // Place Name
						break;
					case 1: // Place type
					{
						PlaceTypeTVC* ptvc=[[[PlaceTypeTVC alloc] init] autorelease];
						ptvc.delegate=self;
						ptvc.currentlySelectedType=[self.placeObject.data objectForKey:@"placetype"];
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
				pstvc.currentlySelectedStyle=[self.placeObject.data objectForKey:@"placestyle"];
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
						vc.addressToEdit=[self.placeObject.data objectForKey:@"address"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 1: // Phone
					{
						PhoneNumberEditTableViewController* vc=[[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 2: // Web site
					{
						EditURIVC* vc=[[[EditURIVC alloc] init] autorelease];
						vc.delegate=self;
						vc.uriToEdit=[self.placeObject.data objectForKey:@"uri"];
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
				vc.textToEdit=[self.placeObject.data objectForKey:@"description"];
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
						vc.textToEdit=[self.placeObject.data objectForKey:@"hours"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 1: // Meals
					{
						EditTextVC* vc=[[[EditTextVC alloc] init] autorelease];
						vc.tag=kTagEditTextMeals;
						vc.delegate=self;
						vc.textToEdit=[self.placeObject.data objectForKey:@"meals"];
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 2: // Price
					{
						PlacePriceTVC* pptvc=[[[PlacePriceTVC alloc] init] autorelease];
						pptvc.delegate=self;
						pptvc.currentlySelectedPrice=(NSUInteger)[self.placeObject.data valueForKey:@"price"];
						[self.navigationController pushViewController:pptvc animated:YES];
					}
						break;
					case 3: // Free WiFi
						break;
					case 4: // Outdoor seating
						break;
					case 5: // Kid-friendly
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
						NSMutableDictionary* addr=[placeObject.data valueForKey:@"address"];
						NSString* url=[[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@, %@ %@ %@",
										[addr valueForKey:@"street"],
										[addr valueForKey:@"city"],
										[addr valueForKey:@"state"],
										[addr valueForKey:@"zip"]] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
						
						DLog(@"Opening URL:%@",url);
						[[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:url ] autorelease]];
						break;
					}
					case 1: // Phone
					{
						NSString* s=[[[[placeObject.data valueForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""] 
									  stringByReplacingOccurrencesOfString:@"(" withString:@""] 
									 stringByReplacingOccurrencesOfString:@")" withString:@""];
						NSString* url=[NSString stringWithFormat:@"tel:%@",s];
						DLog(@"Opening URL:%@", url);
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
						break;
					}
					case 2: // Web site
					{
						[[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:[placeObject.data valueForKey:@"uri"]] autorelease]];
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

#pragma mark EditTextVCDelegate methods

-(void)editTextVC:(id)sender didChangeText:(NSString*)text
{
	EditTextVC* vc=(EditTextVC*)sender;
	if (vc.tag==kTagEditTextOwnerDescription)
		[self.placeObject.data setObject:text forKey:@"description"];
	else if (vc.tag==kTagEditTextHours)
		[self.placeObject.data setObject:text forKey:@"hours"];
	else if (vc.tag==kTagEditTextMeals)
		[self.placeObject.data setObject:text forKey:@"meals"];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PlaceTypeTVCDelegate methods

-(void)placeType:(PlaceTypeTVC*)placeType didSelectType:(NSString*)typeName
{
	[self.placeObject.data setObject:typeName forKey:@"placetype"];
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark PlaceStyleTVCDelegate methods

-(void)placeStyleTVC:(id)placeStyleTVC didSelectStyle:(NSDictionary*)style
{
	DLog(@"Selected style:%@",[style objectForKey:@"name"]);
	[self.placeObject.data setObject:[style objectForKey:@"name"] forKey:@"placestyle"];
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark PlacePriceTVCDelegate methods

-(void)placePriceTVC:(PlacePriceTVC*)tvc didSelectPrice:(NSUInteger)price
{
	[self.placeObject.data setValue:[NSNumber numberWithUnsignedInt:price] forKey:@"price"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UISwitch action method

-(void)toggleSwitchChanged:(id)sender
{
	UISwitch* switchControl=(UISwitch*)sender;
	switch (switchControl.tag) {
		case kTagSwitchControlFreeWiFi:
			[self.placeObject.data setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"freewifi"];
			break;
		case kTagSwitchControlOutdoorSeating:
			[self.placeObject.data setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"outdoorseating"];
			break;
		case kTagSwitchControlKidFriendly:
			[self.placeObject.data setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"kidfriendly"];
			break;
		case kTagSwitchControlBottlesCans:
			[[self.placeObject.data objectForKey:@"togo"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"bottlescans"];
			break;
		case kTagSwitchControlGrowlers:
			[[self.placeObject.data objectForKey:@"togo"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"growlers"];
			break;
		case kTagSwitchControlKegs:
			[[self.placeObject.data objectForKey:@"togo"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"kegs"];
			break;
		default:
			break;
	}
}

#pragma mark EditAddressVCDelegate methods

-(void)editAddressVC:(EditAddressVC *)editAddressVC didEditAddress:(NSDictionary *)dict
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark EditURIVCDelegate methods

-(void)editURIVC:(EditURIVC *)editURIVC didEditURI:(NSString *)uri
{
	[self.placeObject.data setObject:uri forKey:@"uri"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark NSXMLParser delegate methods

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
	 Sample Review:
	 
	<review>
	<type>review</type>
	<timestamp>1249427886</timestamp>
	<user_id>troyh</user_id>
	<place_id>place:Elliot-Bay-Brewhouse-and-Pub-Burien-Washington</place_id>
	<rating>4</rating>
	</review>

	 Sample Place:
	<place id="place:Elliot-Bay-Brewhouse-and-Pub-Burien-Washington" in_operation="yes" specializes_in_beer="yes" tied="no" bottled_beer_to_go="no" growlers_to_go="no" kegs_to_go="no" brew_on_premises="no" taps="" casks="" bottles="" wheelchair_accessible="" music="" wifi="">
	<_id>place:Elliot-Bay-Brewhouse-and-Pub-Burien-Washington</_id>
	<_rev>3183007484</_rev>
	<type>place</type>
	<timestamp>1249415199</timestamp>
	<name>Elliot Bay Brewhouse &amp; Pub</name>
	<description/>
	<phone/>
	<uri/>
	<established/>
	<address>
    <street/>
    <city>Burien</city>
    <state>Washington</state>
    <zip/>
    <country>United States</country>
    <neighborhood/>
	</address>
	<hours>
    <open/>
    <tour/>
    <tasting/>
	</hours>
	<tour_info/>
	<restaurant reservations="" alcohol="" accepts_credit_cards="" good_for_groups="" outdoor_seating="" smoking="">
    <food_description/>
    <menu_uri/>
    <price_range/>
    <attire/>
    <waiter_service>
	</waiter_service>
	</restaurant>
	<parking/>
	<kid_friendly/>
	</place>
	 */
	
	if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"place",nil]])
	{
		if ([elementName isEqualToString:@"name"] ||
			[elementName isEqualToString:@"uri"] ||
			[elementName isEqualToString:@"phone"])
			self.currentElemValue=[NSMutableString string];
	}
	else if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"place",@"address",nil]])
	{
		if ([elementName isEqualToString:@"street"] ||
			[elementName isEqualToString:@"city"] ||
			[elementName isEqualToString:@"state"] ||
			[elementName isEqualToString:@"zip"] ||
			[elementName isEqualToString:@"country"])
		{
			self.currentElemValue=[NSMutableString string];
		}
	}
	else if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
	{
		if ([elementName isEqualToString:@"rating"])
		{
			self.currentElemValue=[NSMutableString string];
		}
	}
	
	// Add the element to the xmlParserPath
	[self.xmlParserPath addObject:elementName];
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	// Pop the element name off the XML parser path array
	[self.xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"place",nil]])
		{
			if ([elementName isEqualToString:@"name"])
				[placeObject.data setObject:currentElemValue forKey:@"name"];
			else if ([elementName isEqualToString:@"uri"])
				[placeObject.data setObject:currentElemValue forKey:@"uri"];
			else if ([elementName isEqualToString:@"phone"])
				[placeObject.data setObject:currentElemValue forKey:@"phone"];
		}
		else if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"place",@"address",nil]])
		{
			if ([elementName isEqualToString:@"street"])
			{
				NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
				[addr setObject:currentElemValue forKey:@"street"];
			}
			else if ([elementName isEqualToString:@"city"])
			{
				NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
				[addr setObject:currentElemValue forKey:@"city"];
			}
			else if ([elementName isEqualToString:@"state"])
			{
				NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
				[addr setObject:currentElemValue forKey:@"state"];
			}
			else if ([elementName isEqualToString:@"zip"])
			{
				NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
				[addr setObject:currentElemValue forKey:@"zip"];
			}
		}
		else if ([self.xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"review",nil]])
		{
			if ([elementName isEqualToString:@"rating"])
				[placeObject.data setObject:currentElemValue forKey:@"user_rating"];
		}
			
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
		DLog(@"Need to login...");
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate login];
		// TODO: once logged in, re-try the HTTP request
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
	
    // inform the user
    DLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    DLog(@"PlaceTableViewController:connectionDidFinishLoading Succeeded! Received %d bytes of data",[xmlPostResponse length]);
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


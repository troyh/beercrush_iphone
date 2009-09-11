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
#import "RatingControl.h"
#import "PhotoThumbnailControl.h"

@implementation BreweryObject

@synthesize data;

-(id)init
{
	self.data=[[NSMutableDictionary alloc] initWithCapacity:10];
	
	// Init address data to empty strings (so we don't see '(null)' pop up anywhere)
	NSMutableDictionary* addr=[[[NSMutableDictionary alloc] initWithCapacity:4] autorelease];
	[addr setObject:@"" forKey:@"street"];
	[addr setObject:@"" forKey:@"city"];
	[addr setObject:@"" forKey:@"state"];
	[addr setObject:@"" forKey:@"zip"];
	[addr setObject:@"" forKey:@"country"];
	[self.data setObject:addr forKey:@"address"];

	// Init with blank values for these
	[self.data setObject:@"" forKey:@"uri"];
	[self.data setObject:@"" forKey:@"phone"];
	[self.data setObject:@"" forKey:@"tourinfo"];
	[self.data setObject:@"" forKey:@"tasting"];
	[self.data setObject:@"" forKey:@"hours"];
	
	[self.data setObject:[[[NSMutableDictionary alloc] initWithCapacity:3] autorelease] forKey:@"togo"];

	return self;
}

-(void)dealloc
{
	[self.data release];
	
	[super dealloc];
}

@end


@implementation BreweryTableViewController

@synthesize breweryID;
@synthesize breweryObject;
@synthesize originalBreweryData;
@synthesize currentElemValue;
@synthesize xmlParserPath;
@synthesize delegate;

static const int kTagSwitchControlKegs=1;
static const int kTagSwitchControlGrowlers=2;
static const int kTagSwitchControlBottles=3;
static const int kTagTextViewTasting=4;
static const int kTagTextViewTourInfo=5;
static const int kTagTextViewHours=6;


-(id) initWithBreweryID:(NSString*)brewery_id
{
	[super initWithStyle:UITableViewStyleGrouped];
	
	if (brewery_id==nil)
	{
	}
	else 
	{
		self.breweryID=brewery_id;
		self.xmlParserPath=[NSMutableArray arrayWithCapacity:10];
		self.currentElemValue=nil;
		
		self.title=@"Brewery";
		
		breweryObject=[[BreweryObject alloc] init];

		NSArray* parts=[self.breweryID componentsSeparatedByString:@":"];
		if ([parts count]==2)
		{
			// Retrieve XML doc from server
			NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_DOC, [parts objectAtIndex:1] ]];
			NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
			[parser setDelegate:self];
			[parser parse];
			[parser	release];
		}
		else
		{
			// TODO: alert user of problem
		}
	}
	
	return self;
}

-(void)dealloc
{
	[self.breweryID release];
	[self.breweryObject release];
	[self.originalBreweryData release];
	[self.currentElemValue release];
	[self.xmlParserPath release];
	
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
		// Make a copy of the brewery object so we can determine which data changed so that we only send changes to the server
		self.originalBreweryData=[[NSDictionary alloc] initWithDictionary:self.breweryObject.data copyItems:YES];
		
		if (self.breweryID)
			self.title=@"Editing Brewery";
		else
			self.title=@"New Brewery";

		[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editingBreweryCancelButtonClicked:)] autorelease]];

		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:
												[NSIndexPath indexPathForRow:0 inSection:2],
												[NSIndexPath indexPathForRow:3 inSection:4],
												nil
												] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
		
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:
												[NSIndexPath indexPathForRow:0 inSection:1], // Edit Street
												[NSIndexPath indexPathForRow:1 inSection:1], // Edit Street 2
												[NSIndexPath indexPathForRow:2 inSection:1], // Edit City, State ZIP
												[NSIndexPath indexPathForRow:3 inSection:1], // Edit Country
												nil] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
		
		[self.tableView reloadData];
	}
	else
	{
		// Save data to server
		NSMutableArray* values=[NSMutableArray arrayWithCapacity:10];
		// Add in changed fields to the POST data
		if ([[[self.originalBreweryData objectForKey:@"address"] objectForKey:@"street"] isEqualToString:[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"street"]]==NO)
			[values addObject:[NSString stringWithFormat:@"address:street=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"street"]]];
		if ([[[self.originalBreweryData objectForKey:@"address"] objectForKey:@"city"] isEqualToString:[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"city"]]==NO)
			[values addObject:[NSString stringWithFormat:@"address:city=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"city"]]];
		if ([[[self.originalBreweryData objectForKey:@"address"] objectForKey:@"state"] isEqualToString:[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"state"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&address:state=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"state"]]];
		if ([[[self.originalBreweryData objectForKey:@"address"] objectForKey:@"zip"] isEqualToString:[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"zip"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&address:zip=%@",[[self.breweryObject.data objectForKey:@"address"] objectForKey:@"zip"]]];
		if ([[self.originalBreweryData objectForKey:@"name"] isEqualToString:[self.breweryObject.data objectForKey:@"name"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&name=%@",[self.breweryObject.data objectForKey:@"name"]]];
		if ([[self.originalBreweryData objectForKey:@"phone"] isEqualToString:[self.breweryObject.data objectForKey:@"phone"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&phone=%@",[self.breweryObject.data objectForKey:@"phone"]]];
		if ([[self.originalBreweryData objectForKey:@"uri"] isEqualToString:[self.breweryObject.data objectForKey:@"uri"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&uri=%@",[self.breweryObject.data objectForKey:@"uri"]]];
		if ([[self.originalBreweryData objectForKey:@"tourinfo"] isEqualToString:[self.breweryObject.data objectForKey:@"tourinfo"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&tourinfo=%@",[self.breweryObject.data objectForKey:@"tourinfo"]]];
		if ([[self.originalBreweryData objectForKey:@"tasting"] isEqualToString:[self.breweryObject.data objectForKey:@"tasting"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&tasting=%@",[self.breweryObject.data objectForKey:@"tasting"]]];
		if ([[self.originalBreweryData objectForKey:@"hours"] isEqualToString:[self.breweryObject.data objectForKey:@"hours"]]==NO)
			[values addObject:[NSString stringWithFormat:@"&hours=%@",[self.breweryObject.data objectForKey:@"hours"]]];
		
		NSDictionary* old=[self.originalBreweryData objectForKey:@"togo"];
		NSDictionary* new=[self.breweryObject.data objectForKey:@"togo"];
		if ([old isEqualToDictionary:new]==NO) // If they are not the same, change it
		{
			NSMutableArray* togovalues=[[[NSMutableArray alloc] initWithCapacity:3] autorelease];
			if ([[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"kegs"])
				[togovalues addObject:@"kegs"];
			if ([[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"growlers"])
				[togovalues addObject:@"growlers"];
			if ([[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"bottles"])
				[togovalues addObject:@"bottles"];
			[values addObject:[NSString stringWithFormat:@"togo=%@",[togovalues componentsJoinedByString:@" "]]];
		}
		 
		if ([values count])
		{
			NSMutableString* bodystr=[[[NSMutableString alloc] initWithFormat:@"brewery_id=%@&",self.breweryID] autorelease];
			[bodystr appendString:[values componentsJoinedByString:@"&"]];

			BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSData* answer;
			NSHTTPURLResponse* response=[appDelegate sendRequest:[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_BREWERY_DOC] usingMethod:@"POST" withData:bodystr returningData:&answer];
			if ([response statusCode]==200)
			{
				// Parse the XML response, which is the new brewery doc
				NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
				[parser setDelegate:self];
				[parser parse];
				[parser release];
				
				self.title=@"Brewery";
				
				[self.tableView beginUpdates];
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:
														[NSIndexPath indexPathForRow:0 inSection:1],
														[NSIndexPath indexPathForRow:1 inSection:1],
														[NSIndexPath indexPathForRow:2 inSection:1],
														[NSIndexPath indexPathForRow:3 inSection:1],
														nil] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
				
				[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:
														[NSIndexPath indexPathForRow:0 inSection:2],
														[NSIndexPath indexPathForRow:3 inSection:4],
														nil] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView endUpdates];
				
			}
			else
			{
				self.editing=YES; // Nope, we're staying in Edit mode
			}
		}
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.editing?5:6;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return self.editing?1:1;
			break;
		case 1:
			return self.editing?6:1;
			break;
		case 2:
			return self.editing?1:3;
			break;
		case 3:
			return self.editing?3:1;
			break;
		case 4:
			return self.editing?3:4;
			break;
		case 5:
			return 1;
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
			case 2:
				return @"Owner's Description";
				break;
			case 3:
				return @"Details";
				break;
			case 4:
				return @"Buy to go";
				break;
			default:
				break;
		}
	}
	else 
	{
		switch (section) {
			case 3:
				return @"Owner's Description";
				break;
			case 4:
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
			case 0: // Brewery name
				return 50;
				break;
			case 2: // Owner's Description
				return 80;
				break;
			case 3: // Details
				return 80;
				break;
		}
		
	}
	else 
	{
		switch (indexPath.section) {
			case 0: // Brewery name
				return 50;
				break;
			case 2:
			{
				switch (indexPath.row) {
					case 0: // Address
						return 80;
						break;
				}
				break;
			}
			case 3:
				return 80;
				break;
		}
	}
	
	return tableView.rowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	tableView.allowsSelectionDuringEditing=YES;
	
	UITableViewCell *cell=nil;
	
	if (self.editing)
	{
		switch (indexPath.section) 
		{
			case 0: // Name and photo
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"EditNameCell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditNameCell"] autorelease];

					UITextField* textField=[[[UITextField alloc] initWithFrame:CGRectMake(15, 10, 290, 30)] autorelease];
					textField.font=[UIFont boldSystemFontOfSize:20];
					textField.tag=1;
					textField.placeholder=@"Name";
//					textField.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|
//												UIViewAutoresizingFlexibleWidth|
//												UIViewAutoresizingFlexibleRightMargin|
//												UIViewAutoresizingFlexibleHeight|
//												UIViewAutoresizingFlexibleTopMargin|
//												UIViewAutoresizingFlexibleBottomMargin;
//					[textField sizeToFit];
					[cell addSubview:textField];
				}
				UITextField* textField=(UITextField*)[cell viewWithTag:1];
				[textField setText:[self.breweryObject.data objectForKey:@"name"]];
				break;
			}
			case 1: // Address, phone & URI
			{
				NSDictionary* addr=[self.breweryObject.data objectForKey:@"address"];
				
				switch (indexPath.row) {
					case 0: // Street
					case 1: // Street #2
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditStreetCell"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditStreetCell"] autorelease];
							UITextField* textField=[[[UITextField alloc] initWithFrame:CGRectMake(5, 8, 290, 30)] autorelease];
							textField.tag=1;
							textField.placeholder=@"Street";
							textField.font=[UIFont boldSystemFontOfSize:16];
							[cell.contentView addSubview:textField];
						}
						UITextField* textField=(UITextField*)[cell viewWithTag:1];
						if (indexPath.row==0)
							[textField setText:[addr objectForKey:@"street"]];
						else
							[textField setText:[addr objectForKey:@"street2"]];
						break;
					case 2: // City, State & Zip
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditCityStateZIPCell"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditCityStateZIPCell"] autorelease];

							UITextField* cityTextField=[[[UITextField alloc] initWithFrame:CGRectMake(5, 8, 150, 30)] autorelease];
							cityTextField.tag=1;
							cityTextField.placeholder=@"City";
							cityTextField.font=[UIFont boldSystemFontOfSize:16];
							[cell.contentView addSubview:cityTextField];

							UITextField* stateTextField=[[[UITextField alloc] initWithFrame:CGRectMake(155, 8, 30, 30)] autorelease];
							stateTextField.tag=2;
							stateTextField.placeholder=@"State";
							stateTextField.keyboardType=UIKeyboardTypeAlphabet;
							stateTextField.font=[UIFont boldSystemFontOfSize:16];
							[cell.contentView addSubview:stateTextField];

							UITextField* zipTextField=[[[UITextField alloc] initWithFrame:CGRectMake(180, 8, 110, 30)] autorelease];
							zipTextField.tag=3;
							zipTextField.placeholder=@"Zip";
							zipTextField.keyboardType=UIKeyboardTypeNumberPad;
							zipTextField.font=[UIFont boldSystemFontOfSize:16];
							[cell.contentView addSubview:zipTextField];
						}
						
						UITextField* cityTextField=(UITextField*)[cell viewWithTag:1];
						UITextField* stateTextField=(UITextField*)[cell viewWithTag:2];
						UITextField* zipTextField=(UITextField*)[cell viewWithTag:3];
						
						[cityTextField setText:[addr objectForKey:@"city"]];
						[stateTextField setText:[addr objectForKey:@"state"]];
						[zipTextField setText:[addr objectForKey:@"zip"]];
						break;
					}
					case 3: // Country
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditCountry"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditCountry"] autorelease];
							cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						}
						[cell.textLabel setText:[addr objectForKey:@"country"]];
						break;
					}
					case 4: // Phone
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditPhone"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditPhone"] autorelease];
							
							UITextField* phoneTextField=[[[UITextField alloc] initWithFrame:CGRectMake(5, 8, 300, 30)] autorelease];
							phoneTextField.tag=1;
							phoneTextField.placeholder=@"Phone";
							phoneTextField.font=[UIFont systemFontOfSize:20];
							phoneTextField.textAlignment=UITextAlignmentCenter;
							phoneTextField.keyboardType=UIKeyboardTypePhonePad;
							[cell addSubview:phoneTextField];
						}
						
						UITextField* textField=(UITextField*)[cell viewWithTag:1];
						[textField setText:[self.breweryObject.data objectForKey:@"phone"]];
						break;
					}
					case 5: // Web site
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"EditURI"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditURI"] autorelease];
							
							UITextField* uriTextField=[[[UITextField alloc] initWithFrame:CGRectMake(5, 8, 300, 30)] autorelease];
							uriTextField.tag=1;
							uriTextField.placeholder=@"Web site";
							uriTextField.textAlignment=UITextAlignmentCenter;
							uriTextField.keyboardType=UIKeyboardTypeURL;
							uriTextField.autocorrectionType=UITextAutocorrectionTypeNo;
							[cell addSubview:uriTextField];
						}
						
						UITextField* textField=(UITextField*)[cell viewWithTag:1];
						[textField setText:[self.breweryObject.data objectForKey:@"uri"]];
						break;
					}
					default:
						break;
				}
				break;
			}
			case 2: // Owner's Description
				cell = [tableView dequeueReusableCellWithIdentifier:@"EditOwnerDescription"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditOwnerDescription"] autorelease];
				}
				
				[cell.textLabel setText:[self.breweryObject.data objectForKey:@"description"]];
				cell.textLabel.numberOfLines=3;
				break;
			case 3: // Details
				cell = [tableView dequeueReusableCellWithIdentifier:@"EditDetails"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"EditDetails"] autorelease];
					
					UITextView* textView=[[[UITextView alloc] initWithFrame:CGRectMake(80, 5, 210, 70)] autorelease];
					switch (indexPath.row) {
						case 0:
							textView.tag=kTagTextViewTasting;
							break;
						case 1:
							textView.tag=kTagTextViewTourInfo;
							break;
						case 2:
							textView.tag=kTagTextViewHours;
							break;
						default:
							break;
					}
					textView.delegate=self;
					textView.font=[UIFont systemFontOfSize:15];
					[textView sizeToFit];
					[cell.contentView addSubview:textView];
				}
				
				switch (indexPath.row) {
					case 0:
					{
						[cell.textLabel setText:@"tasting"];
						UITextView* tv=(UITextView*)[cell.contentView viewWithTag:kTagTextViewTasting];
						[tv setText:[self.breweryObject.data objectForKey:@"tasting"]];
						break;
					}
					case 1:
					{
						[cell.textLabel setText:@"tour info"];
						UITextView* tv=(UITextView*)[cell.contentView viewWithTag:kTagTextViewTourInfo];
						[tv setText:[self.breweryObject.data objectForKey:@"tourinfo"]];
						break;
					}
					case 2:
					{
						[cell.textLabel setText:@"hours"];
						UITextView* tv=(UITextView*)[cell.contentView viewWithTag:kTagTextViewHours];
						[tv setText:[self.breweryObject.data objectForKey:@"hours"]];
						break;
					}
					default:
						break;
				}
				break;
			case 4: // Buy to go
				cell = [tableView dequeueReusableCellWithIdentifier:@"EditToGo"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditToGo"] autorelease];
					
					UISwitch* switchControl=[[[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 30, 30)] autorelease];
					switch (indexPath.row)
					{
						case 0:
							switchControl.tag=kTagSwitchControlKegs;
							break;
						case 1:
							switchControl.tag=kTagSwitchControlGrowlers;
							break;
						case 2:
							switchControl.tag=kTagSwitchControlBottles;
							break;
					}
					[switchControl addTarget:self action:@selector(toggleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:switchControl];
				}
				switch (indexPath.row) {
					case 0:
					{
						[cell.textLabel setText:@"Kegs"];
						UISwitch* sc=(UISwitch*)[cell viewWithTag:kTagSwitchControlKegs];
						[sc setOn:[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"kegs"]?YES:NO animated:NO];
						break;
					}
					case 1:
					{
						[cell.textLabel setText:@"Growlers"];
						UISwitch* sc=(UISwitch*)[cell viewWithTag:kTagSwitchControlGrowlers];
						[sc setOn:[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"growlers"]?YES:NO animated:NO];
						break;
					}
					case 2:
					{
						[cell.textLabel setText:@"Bottles/cans"];
						UISwitch* sc=(UISwitch*)[cell viewWithTag:kTagSwitchControlBottles];
						[sc setOn:[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"bottles"]?YES:NO animated:NO];
						break;
					}
					default:
						break;
				}
				break;
		}
	}
	else 
	{
		switch (indexPath.section) 
		{
			case 0: // Name and photo
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section0Cell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section0Cell"] autorelease];
					
					UIView* transparentBackground=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
					transparentBackground.backgroundColor=[UIColor clearColor];
					cell.backgroundView=transparentBackground;
					cell.backgroundColor=[UIColor clearColor];
					
					UILabel* nameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 0, 200, 30)] autorelease];
					nameLabel.font=[UIFont boldSystemFontOfSize:20];
					nameLabel.tag=1;
					nameLabel.backgroundColor=[UIColor clearColor];
					
					PhotoThumbnailControl* photo=[[[PhotoThumbnailControl alloc] initWithFrame:CGRectMake(0, 0, 75, 75)] autorelease];
					[photo addTarget:self action:@selector(photoThumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
					
					[cell.contentView addSubview:nameLabel];
					[cell.contentView addSubview:photo];
					
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
				}

				UILabel* nameLabel=(UILabel*)[cell viewWithTag:1];
				[nameLabel setText:[breweryObject.data objectForKey:@"name"]];
				break;
			}
			case 1: // Beers Brewed
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section1Cell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section1Cell"] autorelease];
				}
				[cell.textLabel setText:[NSString stringWithFormat:@"%d Beers Brewed",0]];
				break;
			}
			case 2: // Address, phone and web site
			{
				switch (indexPath.row)
				{
					case 0:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row0Cell"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row0Cell"] autorelease];
						}
						
						NSMutableDictionary* addr=[breweryObject.data objectForKey:@"address"];
						[cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@, %@ %@\n%@",
												[addr objectForKey:@"street"],
												[addr objectForKey:@"city"],
												[addr objectForKey:@"state"],
												[addr objectForKey:@"zip"],
												[addr objectForKey:@"country"]]];
						cell.detailTextLabel.numberOfLines=3;
						//[cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
						//[cell.detailTextLabel setTextAlignment:UITextAlignmentCenter];
						[cell.textLabel setText:@"map"];
						break;
					}
					case 1:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row1Cell"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section2Row1Cell"] autorelease];
						}
						
						[cell.detailTextLabel setText:[breweryObject.data objectForKey:@"phone"]];
	//					[cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
						[cell.textLabel setText:@"call"];
						break;
					}
					case 2:
					{
						cell = [tableView dequeueReusableCellWithIdentifier:@"Section2Row2Cell"];
						if (cell == nil) {
							cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section2Row2Cell"] autorelease];
						}
						
						[cell.textLabel setText:[breweryObject.data objectForKey:@"uri"]];
	//					[cell.textLabel setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
						[cell.textLabel setTextAlignment:UITextAlignmentCenter];
						break;
					}
					default:
						break;
				}
				break;
			}
			case 3: // Owner's Description
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section3Cell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section3Cell"] autorelease];
					
					UILabel* descriptionLabel=[[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 275, 30)] autorelease];
					descriptionLabel.font=[UIFont systemFontOfSize:14];
					descriptionLabel.numberOfLines=3;
					[descriptionLabel setText:[self.breweryObject.data objectForKey:@"description"]];
					[cell.contentView addSubview:descriptionLabel];
				}
				break;
			}
			case 4: // Details
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section4Cell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section4Cell"] autorelease];
				}
				switch (indexPath.row)
				{
					case 0:
						[cell.textLabel setText:@"tastings"];
						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"tastings"]];
						break;
					case 1:
						[cell.textLabel setText:@"tour info"];
						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"tourinfo"]];
						break;
					case 2:
						[cell.textLabel setText:@"hours"];
						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"hours"]];
						break;
					case 3:
						[cell.textLabel setText:@"to go"];
//						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"togo"]];
						break;
				}
				break;
			}
			case 5: // Affiliated bars/restaurants
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section5Cell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section5Cell"] autorelease];
				}
				[cell.textLabel setText:[NSString stringWithFormat:@"%d Affiliated Bars/Restaurants",0]];
				break;
			}
		}
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (self.editing)
	{
		switch (indexPath.section) {
			case 0:
				break;
			case 1:
			{
				switch (indexPath.row) 
				{
					case 3: // Pick Country
					{
						CountryListTVC* cltvc=[[[CountryListTVC alloc] init] autorelease];
						cltvc.delegate=self;
						[self.navigationController pushViewController:cltvc animated:YES];
						break;
					}
				}
				break;
			}
			case 2: // Owner's Description
			{
				EditTextVC* editText=[[[EditTextVC alloc] init] autorelease];
				editText.delegate=self;
				editText.textToEdit=[self.breweryObject.data objectForKey:@"description"];
				[self.navigationController pushViewController:editText animated:YES];
				break;
			}
		}
	}
	else
	{
		switch (indexPath.section) {
			case 2:
			{
				switch (indexPath.row) 
				{
					case 0: // Address
					{
						NSMutableDictionary* addr=[breweryObject.data valueForKey:@"address"];
						NSString* url=[[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@, %@ %@ %@",
										[addr valueForKey:@"street"],
										[addr valueForKey:@"city"],
										[addr valueForKey:@"state"],
										[addr valueForKey:@"zip"]] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
						
						DLog(@"Opening URL:%@",url);
						[[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:url] autorelease]];
						break;
					}
					case 1: // Phone
					{
						NSString* s=[[[[breweryObject.data objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""] 
									  stringByReplacingOccurrencesOfString:@"(" withString:@""] 
									 stringByReplacingOccurrencesOfString:@")" withString:@""];
						NSString* url=[NSString stringWithFormat:@"tel:%@",s];
						DLog(@"Opening URL:%@", url);
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
						break;
					}
					case 2: // Web site
					{
						NSString* uri=[breweryObject.data objectForKey:@"uri"];
						if ([uri length])
							[[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString: uri] autorelease]];
						break;
					}
				}
			}
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

#pragma mark Target Actions

-(void)toggleSwitchChanged:(id)sender
{
	UISwitch* switchControl=(UISwitch*)sender;
	if (switchControl.tag==kTagSwitchControlKegs)
		[[self.breweryObject.data objectForKey:@"togo"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"kegs"];
	else if (switchControl.tag == kTagSwitchControlGrowlers)
		[[self.breweryObject.data objectForKey:@"togo"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"growlers"];
	else if (switchControl.tag == kTagSwitchControlBottles)
		[[self.breweryObject.data objectForKey:@"togo"] setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"bottles"];

}

#pragma mark UITextViewDelegate methods

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if (textView.tag==kTagTextViewTasting)
		[self.breweryObject.data setObject:textView.text forKey:@"tasting"];
	else if (textView.tag==kTagTextViewTourInfo)
		[self.breweryObject.data setObject:textView.text forKey:@"tourinfo"];
	else if (textView.tag==kTagTextViewHours)
		[self.breweryObject.data setObject:textView.text forKey:@"hours"];
}

#pragma mark EditTextVCDelegate methods

-(void)editTextVC:(id)sender didChangeText:(NSString*)text
{
	[self.breweryObject.data setObject:text forKey:@"description"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark CountryListTVCDelegate methods

-(void)countryList:(CountryListTVC*)countryList didSelectCountry:(NSString*)countryName
{
	DLog(@"Selected country:%@",countryName);
	[[self.breweryObject.data objectForKey:@"address"] setObject:countryName forKey:@"country"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Action methods

-(void)photoThumbnailClicked:(id)sender
{
	NSArray* photoList=[NSArray arrayWithObjects:@"beer.png",@"brewery.png",@"bar.png",nil];
	PhotoViewer* viewer=[[[PhotoViewer alloc] initWithPhotoList:photoList] autorelease];
	viewer.delegate=self;
	[self.navigationController pushViewController:viewer animated:YES];
}

-(void)editingBreweryCancelButtonClicked:(id)sender
{
	[self.delegate breweryVCDidCancelEditing:self];
}


#pragma mark PhotoViewerDelegate methods

-(void)photoViewer:(PhotoViewer*)photoViewer didSelectPhotoToUpload:(UIImage*)photo
{
	NSData* imageData=UIImageJPEGRepresentation(photo, 1.0);
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_UPLOAD_BREWERY_IMAGE,self.breweryID]];
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

@end


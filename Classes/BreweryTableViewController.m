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
#import "JSON.h"


@implementation BreweryObject

@synthesize data;

-(id)init
{
	self.data=[[NSMutableDictionary alloc] initWithCapacity:10];
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
@synthesize delegate;
@synthesize editingWasCanceled;

enum TAGS {
	kTagSwitchControlKegs=1,
	kTagSwitchControlGrowlers,
	kTagSwitchControlBottles,
	kTagEditTextDescription,
	kTagEditTextTasting,
	kTagEditTextTourInfo,
	kTagEditTextHours
};


-(id) initWithBreweryID:(NSString*)brewery_id
{
	[super initWithStyle:UITableViewStyleGrouped];

	breweryObject=[[BreweryObject alloc] init];
	
	if (brewery_id==nil)
	{
	}
	else 
	{
		self.breweryID=brewery_id;
		
		self.title=@"Brewery";
		
		NSArray* parts=[self.breweryID componentsSeparatedByString:@":"];
		if ([parts count]==2)
		{
			// Retrieve JSON doc from server
			BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			self.breweryObject.data=[appDelegate getBreweryDoc:self.breweryID];
		}
		else
		{
			// TODO: alert user of problem
		}
	}
	
	normalizeBreweryData(self.breweryObject.data);
	
	return self;
}

-(void)dealloc
{
	[self.breweryID release];
	[self.breweryObject release];
	[self.originalBreweryData release];
	
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
	if (editing==YES)
	{
		[super setEditing:editing animated:animated];
		
		// Make a copy of the brewery object so we can determine which data changed so that we only send changes to the server
		self.originalBreweryData=[[NSDictionary alloc] initWithDictionary:self.breweryObject.data copyItems:YES];
		
		if (self.breweryID)
			self.title=@"Editing Brewery";
		else
			self.title=@"New Brewery";

		[self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editingBreweryCancelButtonClicked:)] autorelease]];

		[self startEditingMode];
		
		[self.tableView reloadData];
	}
	else
	{
		if (self.editingWasCanceled)
		{
			[super setEditing:editing animated:animated];
			[self.navigationItem setLeftBarButtonItem:nil];
		}
		else
		{
			NSArray* keyNames=[NSArray arrayWithObjects:
							   @"name",
							   @"phone",
							   @"uri",
							   @"description",
							   @"tourinfo",
							   @"tasting",
							   @"hours",
							   @"togo:bottles",
							   @"togo:growlers",
							   @"togo:kegs",
							   @"address:street",
							   @"address:city",
							   @"address:state",
							   @"address:zip",
							   @"address:country",
							   nil
							   ];
			
			// Save data to server
			NSMutableArray* values=appendDifferentValuesToArray(keyNames,self.originalBreweryData,self.breweryObject.data);

			if ([values count]==0)
			{
				[super setEditing:editing animated:animated];
				[self endEditingMode];
			}
			else
			{
				if (self.breweryID)
					[values addObject:[NSString stringWithFormat:@"brewery_id=%@",self.breweryID]];
				
				NSString* bodystr=[values componentsJoinedByString:@"&"];

				BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
				[appDelegate performAsyncOperationWithTarget:self selector:@selector(saveEdits:) object:bodystr requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"HUD:Saving",@"Saving")];
			}
		}
	}
}

-(void)startEditingMode
{
	[self.tableView beginUpdates];

	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:
											[NSIndexPath indexPathForRow:3 inSection:5],
											nil
											] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	
	[self.tableView insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
//	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:
//											[NSIndexPath indexPathForRow:0 inSection:1], // Edit Street
//											[NSIndexPath indexPathForRow:1 inSection:1], // Edit Street 2
//											[NSIndexPath indexPathForRow:2 inSection:1], // Edit City, State ZIP
//											[NSIndexPath indexPathForRow:3 inSection:1], // Edit Country
//											nil] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

-(void)endEditingMode
{
//	self.editing=NO;
	self.title=@"Brewery";
	
	[self.tableView beginUpdates];
//	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:
//											[NSIndexPath indexPathForRow:0 inSection:1],
//											[NSIndexPath indexPathForRow:1 inSection:1],
//											[NSIndexPath indexPathForRow:2 inSection:1],
//											[NSIndexPath indexPathForRow:3 inSection:1],
//											nil] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationFade];
	
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:
											[NSIndexPath indexPathForRow:3 inSection:5],
											nil] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
	
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
			return self.editing?3:1;
			break;
		case 2:
			return self.editing?1:1;
			break;
		case 3:
			return self.editing?3:3;
			break;
		case 4:
			return self.editing?3:1;
			break;
		case 5:
			return self.editing?0:4;
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
			case 4:
				return @"Owner's Description";
				break;
			case 5:
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
			case 1:
			{
				switch (indexPath.row) {
					case 0: // Address
						return 80;
						break;
					case 1: // Phone
						break;
					case 2: // Web site
						break;
					default:
						break;
				}
				break;
			}
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
			case 3:
			{
				switch (indexPath.row) {
					case 0: // Address
						return 80;
						break;
				}
				break;
			}
			case 4:
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
				}
				[cell.textLabel setText:[self.breweryObject.data objectForKey:@"name"]];
				break;
			}
			case 1: // Address, phone & URI
			{

				switch (indexPath.row) {
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
						[cell.textLabel setText:@"address"];
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
						[cell.textLabel setText:@"phone"];
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
				}
				
				switch (indexPath.row) {
					case 0:
					{
						[cell.textLabel setText:@"tasting"];
						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"tasting"]];
						break;
					}
					case 1:
					{
						[cell.textLabel setText:@"tour info"];
						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"tourinfo"]];
						break;
					}
					case 2:
					{
						[cell.textLabel setText:@"hours"];
						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"hours"]];
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
						[sc setOn:[[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"kegs"] boolValue]?YES:NO animated:NO];
						break;
					}
					case 1:
					{
						[cell.textLabel setText:@"Growlers"];
						UISwitch* sc=(UISwitch*)[cell viewWithTag:kTagSwitchControlGrowlers];
						[sc setOn:[[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"growlers"] boolValue]?YES:NO animated:NO];
						break;
					}
					case 2:
					{
						[cell.textLabel setText:@"Bottles/cans"];
						UISwitch* sc=(UISwitch*)[cell viewWithTag:kTagSwitchControlBottles];
						[sc setOn:[[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"bottles"] boolValue]?YES:NO animated:NO];
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
			case 2: // Affiliated bars/restaurants
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section5Cell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section5Cell"] autorelease];
				}
				[cell.textLabel setText:[NSString stringWithFormat:@"%d Affiliated Bars/Restaurants",0]];
				break;
			}
			case 3: // Address, phone and web site
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
			case 4: // Owner's Description
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
			case 5: // Details
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"Section4Cell"];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Section4Cell"] autorelease];
				}
				switch (indexPath.row)
				{
					case 0:
						[cell.textLabel setText:@"tastings"];
						[cell.detailTextLabel setText:[self.breweryObject.data objectForKey:@"tasting"]];
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
					{
						[cell.textLabel setText:@"to go"];
						
						NSMutableArray* values=[NSMutableArray arrayWithCapacity:3];
						if ([[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"bottles"] boolValue]) 
							[values addObject:@"Bottles"];
						if ([[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"growlers"] boolValue]) 
							[values addObject:@"Growlers"];
						if ([[[self.breweryObject.data objectForKey:@"togo"] objectForKey:@"kegs"] boolValue]) 
							[values addObject:@"Kegs"];
						
						[cell.detailTextLabel setText:[values componentsJoinedByString:@", "]];
						break;
					}
				}
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
			case 0: // Brewery name
			{
				EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
				vc.textToEdit=[self.breweryObject.data objectForKey:@"name"];
				vc.delegate=self;
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			case 1:
			{
				switch (indexPath.row) 
				{
					case 0: // Address
					{
						EditAddressVC* vc=[[[EditAddressVC alloc] init] autorelease];
						vc.addressToEdit=[self.breweryObject.data objectForKey:@"address"];
						vc.delegate=self;
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 1: // Phone
					{
						PhoneNumberEditTableViewController* vc=[[[PhoneNumberEditTableViewController alloc] init] autorelease];
						vc.phoneNumberToEdit=[self.breweryObject.data objectForKey:@"phone"];
						vc.delegate=self;
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
					case 2: // Web site
					{
						EditURIVC* vc=[[[EditURIVC alloc] init] autorelease];
						vc.uriToEdit=[self.breweryObject.data objectForKey:@"uri"];
						vc.delegate=self;
						[self.navigationController pushViewController:vc animated:YES];
						break;
					}
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
				editText.tag=kTagEditTextDescription;
				editText.textToEdit=[self.breweryObject.data objectForKey:@"description"];
				[self.navigationController pushViewController:editText animated:YES];
				break;
			}
			case 3:
			{
				switch (indexPath.row) {
					case 0:
					{
						EditTextVC* editText=[[[EditTextVC alloc] init] autorelease];
						editText.delegate=self;
						editText.tag=kTagEditTextTasting;
						editText.textToEdit=[self.breweryObject.data objectForKey:@"tasting"];
						[self.navigationController pushViewController:editText animated:YES];
						break;
					}
					case 1:
					{
						EditTextVC* editText=[[[EditTextVC alloc] init] autorelease];
						editText.delegate=self;
						editText.tag=kTagEditTextTourInfo;
						editText.textToEdit=[self.breweryObject.data objectForKey:@"tourinfo"];
						[self.navigationController pushViewController:editText animated:YES];
						break;
					}
					case 2:
					{
						EditTextVC* editText=[[[EditTextVC alloc] init] autorelease];
						editText.delegate=self;
						editText.tag=kTagEditTextHours;
						editText.textToEdit=[self.breweryObject.data objectForKey:@"hours"];
						[self.navigationController pushViewController:editText animated:YES];
						break;
					}
					default:
						break;
				}
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

#pragma mark EditTextVCDelegate methods

-(void)editTextVC:(id)sender didChangeText:(NSString*)text
{
	EditTextVC* vc=(EditTextVC*)sender;
	switch (vc.tag) {
		case kTagEditTextDescription:
			[self.breweryObject.data setObject:text forKey:@"description"];
			break;
		case kTagEditTextTasting:
			[self.breweryObject.data setObject:text forKey:@"tasting"];
			break;
		case kTagEditTextTourInfo:
			[self.breweryObject.data setObject:text forKey:@"tourinfo"];
			break;
		case kTagEditTextHours:
			[self.breweryObject.data setObject:text forKey:@"hours"];
			break;
		default:
			break;
	}
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
	self.editingWasCanceled=YES;
	if (self.delegate)
		[self.delegate breweryVCDidCancelEditing:self];
	else {
		self.editing=NO;
		[self.tableView reloadData];
	}
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

#pragma mark EditLineVCDelegate methods

-(void)editLineVC:(EditLineVC*)editLineVC didChangeText:(NSString*)text
{
	[self.breweryObject.data setObject:text forKey:@"name"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark EditURIVCDelegate methods

-(void)editURIVC:(EditURIVC *)editURIVC didEditURI:(NSString *)uri
{
	[self.breweryObject.data setObject:uri forKey:@"uri"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark EditAddressVCDelegate methods

-(void)editAddressVC:(EditAddressVC *)editAddressVC didEditAddress:(NSDictionary *)dict
{
	[self.breweryObject.data setObject:dict forKey:@"address"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark EditPhoneNumberTVCDelegate methods

-(void)editPhoneNumberdidCancelEdit:(PhoneNumberEditTableViewController *)editPhoneNumber
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)editPhoneNumber:(PhoneNumberEditTableViewController *)editPhoneNumber didChangePhoneNumber:(NSString *)phoneNumber
{
	[self.breweryObject.data setObject:phoneNumber forKey:@"phone"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Async operations

-(void)saveEdits:(NSString*)bodystring
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[appDelegate sendJSONRequest:[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_BREWERY_DOC] usingMethod:@"POST" withData:bodystring returningJSON:&answer];
	if ([response statusCode]==200)
	{
		self.breweryObject.data=answer;
		normalizeBreweryData(self.breweryObject.data);
		
		[super setEditing:self.editing animated:YES];
		[self endEditingMode];
		[self.navigationItem setLeftBarButtonItem:nil];
		
		// Tell the delegate
		[self.delegate breweryVCDidFinishEditing:self];
	}
	else
	{
		// Nope, we're staying in Edit mode
		[self performSelectorOnMainThread:@selector(saveEditsFailed) withObject:nil waitUntilDone:NO];
	}
}

-(void)saveEditsFailed
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Editing Brewery",@"SaveBreweryEditsFailed: failure alert title")
												  message:NSLocalizedString(@"Unable to save brewery edits",@"SaveBreweryEditsFailed: failure alert message")
												 delegate:nil
										cancelButtonTitle:NSLocalizedString(@"OK",@"SaveBreweryEditsFailed: failure alert cancel button title")
										otherButtonTitles:nil];
	[alert show];
	[alert release];
	[alert show];
	[alert release];
}

@end


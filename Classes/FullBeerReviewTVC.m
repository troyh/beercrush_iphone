//
//  FullBeerReviewTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "SearchVC.h"
#import "FullBeerReviewTVC.h"

@implementation FullBeerReviewTVC

@synthesize ratingControl;
@synthesize userReview;
@synthesize bodySlider;
@synthesize balanceSlider;
@synthesize aftertasteSlider;
@synthesize flavorsLabel;
@synthesize commentsTextView;
@synthesize delegate;

//const int kTagFlavorsLabel=1;
//const int kTagCommentsTextView=2;
//const int kTagBodySlider=3;
//const int kTagBalanceSlider=4;
//const int kTagAftertasteSlider=5;
//const int kTagRatingControl=6;

-(id)initWithReviewObject:(NSDictionary*)review
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.userReview=[[NSMutableDictionary alloc] initWithDictionary:review];
		self.title=@"Review";
		
		// TODO: if the review is not the user's, all controls should be read-only
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

	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)] autorelease];
}

-(void)doneButtonClicked
{
	[self.userReview setValue:[NSNumber numberWithUnsignedInt:ratingControl.currentRating] forKey:@"rating"];
	[self.userReview setValue:[NSNumber numberWithFloat:bodySlider.value] forKey:@"body"];
	[self.userReview setValue:[NSNumber numberWithFloat:balanceSlider.value] forKey:@"balance"];
	[self.userReview setValue:[NSNumber numberWithFloat:aftertasteSlider.value] forKey:@"aftertaste"];
	[self.userReview setValue:commentsTextView.text forKey:@"comments"];
	// NOTE: flavors are already in self.userReview, they were put there as the user added/removed them 
	
	[delegate fullBeerReview:self.userReview withChanges:YES];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// FlavorsAromasTVCDelegate protocol methods

-(NSArray*)getCurrentFlavors
{
	return [self.userReview objectForKey:@"flavors"];
}

-(void)didSelectFlavor:(NSString*)flavorID
{
	DLog(@"Flavor selected:%@",flavorID);
	NSMutableArray* flavors=[self.userReview objectForKey:@"flavors"];
	if (flavors==nil)
	{
		flavors=[NSMutableArray arrayWithCapacity:10];
		[self.userReview setObject:flavors	forKey:@"flavors"];
	}
	
	if ([flavors indexOfObject:flavorID]==NSNotFound)
	{
		[flavors addObject:flavorID];
	}
}

-(void)didUnselectFlavor:(NSString*)flavorID
{
	DLog(@"Flavor unselected:%@",flavorID);
	NSMutableArray* flavors=[self.userReview objectForKey:@"flavors"];
	if (flavors)
	{
		NSUInteger idx=[flavors indexOfObject:flavorID];
		if (idx!=NSNotFound)
		{
			[flavors removeObjectAtIndex:idx];
		}
	}
}

-(void)doneSelectingFlavors
{
	// Populate Flavors & Aromas text field with the text names for the flavor ids in the review's flavors array
	[self.flavorsLabel setText:[self getFlavorsCellText]];
	
	[self.navigationController popToViewController:self animated:YES];
}

-(NSString*)getFlavorsCellText
{
	BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSDictionary* flavorsdict=[[del getFlavorsDictionary] objectForKey:@"byid"];
	
	NSArray* flavors=[self.userReview objectForKey:@"flavors"];
	if (flavors)
	{
		NSMutableArray* flavornames=[NSMutableArray arrayWithCapacity:10];
		for (NSUInteger i=0; i<[flavors count]; ++i) {
			NSString* title=[[flavorsdict objectForKey:[flavors objectAtIndex:i]] objectForKey:@"title"];
			[flavornames addObject:title];
		}
	
		return [flavornames componentsJoinedByString:@", "];
	}
	return @"";
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: // Beer title and brewery
			return 1;
			break;
		case 1: // My rating
			return 1;
			break;
		case 2: // Review parameters
			return 4;
			break;
		case 3: // Additional comments
			return 1;
			break;
		case 4: // How served/drank and where
			return 4;
			break;
		case 5: // Social networking stuff
			return 2;
			break;
		default:
			break;
	}
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section==3)
	{
		return @"Comments:";
	}
	else if (section==4)
		return @"Improve our listings:";
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==3 && indexPath.row==0)
	{
		return tableView.rowHeight*3;
	}
	return tableView.rowHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell=nil;
	
	switch (indexPath.section) {
		case 0:
		{
			static NSString *CellIdentifier = @"Section0Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

				UIView* transparentBackground=[[UIView alloc] initWithFrame:CGRectZero];
				transparentBackground.backgroundColor=[UIColor clearColor];
				cell.backgroundView=transparentBackground;
				cell.backgroundColor=[UIColor clearColor];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
			}
			
			switch (indexPath.row)
			{
				case 0:
				{
					NSString* n=[[userReview objectForKey:@"beer"] objectForKey:@"name"];
					if (n==nil)
						n=[self.delegate beerName];
					[cell.textLabel setText:n];
					break;
				}
				default:
					break;
			}
			break;
		}
		case 1:
		{
			static NSString *CellIdentifier = @"Section1Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
				cell.detailTextLabel.backgroundColor=[UIColor clearColor];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;

				if (self.ratingControl==nil)
					self.ratingControl=[[[RatingControl alloc] initWithFrame:CGRectMake(120,(tableView.rowHeight-30)/2,170,30)] autorelease];
				[cell.contentView addSubview:self.ratingControl];
			}
			
			switch (indexPath.row)
			{
				case 0:
					[cell.detailTextLabel setText:@"My Rating"];

					// Set current user's rating (if any)
					NSString* user_rating=[self.userReview objectForKey:@"rating"];
					if (user_rating!=nil) // There is a user review
					{
						if (self.ratingControl)
						{
							self.ratingControl.currentRating=[user_rating integerValue];
							DLog(@"Current rating:%d",self.ratingControl.currentRating);
						}
					}
					
					break;
				default:
					break;
			}
			break;
		}
		case 2:
		{
			/* The cells in this section are too different to bother reusing them, so alloc them every time they're requested. 
			The view isn't that big so there's not going to be a lot of scrolling/releasing/re-allocing anyway. */
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
			cell.detailTextLabel.backgroundColor=[UIColor clearColor];
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			
			switch (indexPath.row)
			{
				case 0:
				{
					[cell.detailTextLabel setText:@"Body"];

					// Add slider control
					if (self.bodySlider==nil)
					{
						self.bodySlider=[[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)] autorelease];
						bodySlider.minimumValue=1.0;
						bodySlider.maximumValue=5.0;
						bodySlider.value=[[self.userReview objectForKey:@"body"] integerValue];
						[bodySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
					}
					
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
					
					[cell.contentView addSubview:bodySlider];
					break;
				}
				case 1:
				{
					[cell.detailTextLabel setText:@"Balance"];

					// Add slider control
					if (self.balanceSlider==nil)
					{
						self.balanceSlider=[[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)] autorelease];
						balanceSlider.minimumValue=1.0;
						balanceSlider.maximumValue=5.0;
						balanceSlider.value=[[self.userReview objectForKey:@"balance"] integerValue];
						[balanceSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
					}

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
					
					[cell.contentView addSubview:balanceSlider];
					break;
				}
				case 2:
				{
					[cell.detailTextLabel setText:@"Aftertaste"];

					// Add slider control
					if (self.aftertasteSlider==nil)
					{
						self.aftertasteSlider=[[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)] autorelease];
						aftertasteSlider.minimumValue=1.0;
						aftertasteSlider.maximumValue=5.0;
						aftertasteSlider.value=[[self.userReview objectForKey:@"aftertaste"] integerValue];
						[aftertasteSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
					}

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
					
					[cell.contentView addSubview:aftertasteSlider];
					break;
				}
				case 3: // Flavors & Aromas
					if (self.flavorsLabel==nil)
					{
						self.flavorsLabel=[[[UILabel alloc] initWithFrame:CGRectInset(cell.contentView.frame,25.0,5.0)] autorelease];
						
						self.flavorsLabel.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
						self.flavorsLabel.textAlignment=UITextAlignmentLeft;
						self.flavorsLabel.lineBreakMode=UILineBreakModeWordWrap;
						self.flavorsLabel.numberOfLines=0;
					}
					
					[cell.contentView addSubview:self.flavorsLabel];
					self.flavorsLabel.text=[self getFlavorsCellText];
					break;
				default:
					break;
			}
			break;
		}
		case 3:
		{
			static NSString *CellIdentifier = @"Section4Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
			}

			switch (indexPath.row)
			{
				case 0:  // Comments

					if (self.commentsTextView==nil)
					{
						self.commentsTextView=[[[UITextView alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width-40, 100)] autorelease];
						self.commentsTextView.text=[self.userReview objectForKey:@"comments"];
					
						self.commentsTextView.contentSize=CGSizeMake(100,100);
					}

					[cell.contentView addSubview:self.commentsTextView];
					break;
				default:
					break;
			}
			break;
		}
		case 4: // Improve our listings:
		{
			static NSString *CellIdentifier = @"WhereDrankCells";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
			}
			
			switch (indexPath.row)
			{
				case 0:  // Purchased at
					[cell.textLabel setText:@"Purchased at"];
					[cell.detailTextLabel setText:[[self.userReview objectForKey:@"purchase_place_details"] objectForKey:@"name"]];
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1: // Poured from
				{
					[cell.textLabel setText:@"Poured from"];
					
					NSString* value=[self.userReview objectForKey:@"poured_from"];
					if ([value isEqualToString:@"can"])
						[cell.detailTextLabel setText:NSLocalizedString(@"PouredFromCan",nil)];
					else if ([value isEqualToString:@"bottle"])
						[cell.detailTextLabel setText:NSLocalizedString(@"PouredFromBottle",nil)];
					else if ([value isEqualToString:@"largebottle"])
						[cell.detailTextLabel setText:NSLocalizedString(@"PouredFromLargeBottle",nil)];
					else if ([value isEqualToString:@"cask"])
						[cell.detailTextLabel setText:NSLocalizedString(@"PouredFromCask",nil)];
					else if ([value isEqualToString:@"draft"])
						[cell.detailTextLabel setText:NSLocalizedString(@"PouredFromDraft",nil)];
					
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					break;
				}
				case 2: // Date
					[cell.textLabel setText:@"Date"];
					[cell.detailTextLabel setText:[self.userReview objectForKey:@"date_drank"]];
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 3: // Price
				{
					[cell.textLabel setText:@"Price"];
					NSNumber* n=[self.userReview objectForKey:@"purchase_price"];
					if (n && [n intValue])
					{
						[cell.detailTextLabel setText:[n stringValue]];
					}
					break;
				}
				default:
					break;
			}
			break;
		}
		case 5: // Social networking stuff
		{
			static NSString *CellIdentifier = @"SocialNetworking";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
			}
			
			switch (indexPath.row)
			{
				case 0:  // Twitter this
					[cell.textLabel setText:@"Twitter this"];
					break;
				case 1: // Post to Facebook
					[cell.textLabel setText:@"Post to Facebook"];
					break;
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
	
    return cell;
}

-(void)sliderValueChanged:(id)sender
{
	// Round the value to an integer and reposition the thumb
	UISlider* slider=(UISlider*)sender;
	slider.value=round(slider.value);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section==2 && indexPath.row==3) // Selected the Flavors & Aromas cell
	{
		FlavorsAromasTVC* fatvc=[[[FlavorsAromasTVC alloc] initWithFlavorSet:nil] autorelease];
		fatvc.delegate=self;
		[self.navigationController pushViewController:fatvc animated:YES];
	}
	else if (indexPath.section==4)
	{
		switch (indexPath.row) {
			case 0: // Purchased at
			{
				SearchVC* vc=[[[SearchVC alloc] init] autorelease];
				vc.searchTypes=BeerCrushSearchTypePlaces;
				vc.delegate=self;
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			case 1: // Poured from
			{
				PouredFromVC* vc=[[[PouredFromVC alloc] init] autorelease];
				vc.delegate=self;
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			case 2: // Date
			{
				DatePickerVC* vc=[[[DatePickerVC alloc] init] autorelease];
				vc.delegate=self;
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			case 3: // Price
			{
				EditLineVC* vc=[[[EditLineVC alloc] init] autorelease];
				vc.delegate=self;
				vc.textType=EditLineVCTextTypeCurrency;
				vc.textToEdit=[[self.userReview objectForKey:@"purchase_price"] stringValue];
				[self.navigationController pushViewController:vc animated:YES];
				break;
			}
			default:
				break;
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
	[userReview release];
	[ratingControl release];
	[bodySlider release];
	[balanceSlider release];
	[aftertasteSlider release];
	[flavorsLabel release];
	[commentsTextView release];
	
    [super dealloc];
}

#pragma mark DatePickerVCDelegate methods

-(void)datePickerVC:(DatePickerVC *)datePickerVC didChooseDate:(NSDate *)date
{
	[self.userReview setObject:[date description] forKey:@"date_drank"];
	[self performSelectorOnMainThread:@selector(myReloadData) withObject:nil waitUntilDone:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PouredFromVCDelegate methods

-(void)pouredFromVC:(PouredFromVC *)vc didChoosePouredFrom:(PouredFromVCValueType)value
{
	NSString* s=nil;
	
	switch (value) {
		case PouredFromVCValueTypeCan:
			s=@"can";
			break;
		case PouredFromVCValueTypeBottle:
			s=@"bottle";
			break;
		case PouredFromVCValueTypeLargeBottle:
			s=@"largebottle";
			break;
		case PouredFromVCValueTypeCask:
			s=@"cask";
			break;
		case PouredFromVCValueTypeDraft:
			s=@"draft";
			break;
		default:
			break;
	}
	
	if (s)
	{
		[self.userReview setObject:s forKey:@"poured_from"];
		[self performSelectorOnMainThread:@selector(myReloadData) withObject:nil waitUntilDone:NO];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark FullBeerReviewTVCDelegate methods

-(BOOL)searchVC:(SearchVC *)searchVC didSelectSearchResult:(NSString *)id_string
{
	[self.userReview setObject:id_string forKey:@"purchase_place"];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(getWherePurchasedText:) object:nil withActivityHUD:NO andActivityHUDText:nil];

	[self.navigationController popViewControllerAnimated:YES];
	return NO; // Do not continue 
}

#pragma mark Async methods

-(void)myReloadData
{
	[self.tableView reloadData];
}

-(void)getWherePurchasedText:(id)obj
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSDictionary* doc=[appDelegate getPlaceDoc:[self.userReview objectForKey:@"purchase_place"]];
	[self.userReview setObject:doc forKey:@"purchase_place_details"];
	[self performSelectorOnMainThread:@selector(myReloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark EditLineVCDelegate methods

-(void)editLineVC:(EditLineVC*)editLineVC didChangeText:(NSString*)text
{
	[self.userReview setObject:[NSNumber numberWithFloat:[text floatValue]] forKey:@"purchase_price"];
	[self performSelectorOnMainThread:@selector(myReloadData) withObject:nil waitUntilDone:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

@end


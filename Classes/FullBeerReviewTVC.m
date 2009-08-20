//
//  FullBeerReviewTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FullBeerReviewTVC.h"
#import "RatingControl.h"
#import "FlavorsAromasTVC.h"
#import "BeerCrushAppDelegate.h"

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
		self.userReview=[review copy];
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
	// It is the delegate's responsibility to provide a user review NSMutableDictionary. If the delegate doesn't have a review, we ignore this.
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
	// It is the delegate's responsibility to provide a user review NSMutableDictionary. If the delegate doesn't have a review, we ignore this.
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
	
	[self.navigationController popViewControllerAnimated:YES];
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
			[flavornames addObject:[flavorsdict objectForKey:[flavors objectAtIndex:i]]];
		}
	
		return [flavornames componentsJoinedByString:@", "];
	}
	return @"";
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 3;
			break;
		case 3:
			return 1;
			break;
		case 4:
			return 1;
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
		return @"Flavors & Aromas:";
	}
	else if (section==4)
	{
		return @"Comments:";
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==4 && indexPath.row==0)
	{
		return tableView.rowHeight*3;
	}
	return tableView.rowHeight;
}

-(UIView*)view:(UIView*)view findSubviewOfClass:(Class)class
{
	for (NSUInteger i=0,j=[view.subviews count];i<j;++i)
	{
		UIView* v=[view.subviews objectAtIndex:i];
		DLog(@"subview #%d=%@",i,v);
		if ([v isKindOfClass:class])
		{
			return v;
		}
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	DLog(@"indexPath.section=%d row=%d",indexPath.section,indexPath.row);

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
					[cell.textLabel setText:[userReview objectForKey:@"beer_name"]];
					break;
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
			static NSString *CellIdentifier = @"Section2Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
				cell.detailTextLabel.backgroundColor=[UIColor clearColor];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
			}
			
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
					}

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
					}

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
					}
					
					[cell.contentView addSubview:aftertasteSlider];
					break;
				}
				default:
					break;
			}
			break;
		}
		case 3:
		{
			static NSString *CellIdentifier = @"Section3Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			
			switch (indexPath.row)
			{
				case 0: // Flavors & Aromas
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
		case 4:
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
		default:
			break;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section==3 && indexPath.row==0) // Selected the Flavors & Aromas cell
	{
		FlavorsAromasTVC* fatvc=[[FlavorsAromasTVC alloc] initWithStyle:UITableViewStyleGrouped];
		fatvc.delegate=self;
		[self.navigationController pushViewController:fatvc animated:YES];
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


@end


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

@synthesize beerObj;
@synthesize balanceSlider;
@synthesize bodySlider;
@synthesize aftertasteSlider;
@synthesize ratingControl;
@synthesize delegate;

const int kViewTagFlavorsLabel=1;
const int kViewTagCommentsTextView=2;

-(id)initWithBeerObject:(BeerObject*)beer
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.beerObj=beer;
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
	// Post the review
	
	NSArray* flavors=nil;
	if ([delegate hasUserReview])
	{
		flavors=[[delegate getUserReview] objectForKey:@"flavors"];
	}
	
	NSMutableArray* values=[NSMutableArray arrayWithCapacity:10];
	if (values)
	{
		[values addObject:[NSString stringWithFormat:@"beer_id=%@",[beerObj.data objectForKey:@"beer_id"]]];
		[values addObject:[NSString stringWithFormat:@"rating=%d",ratingControl.currentRating]];
		[values addObject:[NSString stringWithFormat:@"body=%.0f",round(bodySlider.value)]];
		[values addObject:[NSString stringWithFormat:@"aftertaste=%.0f",round(aftertasteSlider.value)]];
		[values addObject:[NSString stringWithFormat:@"balance=%.0f",round(balanceSlider.value)]];
		[values addObject:[NSString stringWithFormat:@"comments=%@",[(UITextView*)[self.view viewWithTag:kViewTagCommentsTextView] text]]];
		[values addObject:[NSString stringWithFormat:@"flavors=%@",[flavors componentsJoinedByString:@" "]]];

		NSString* bodystr=[values componentsJoinedByString:@"&"];

		BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_POST_BEER_REVIEW];
		NSHTTPURLResponse* response=[del sendRequest:url usingMethod:@"POST" withData:bodystr returningData:nil];
		if ([response statusCode]==200)
		{
			[delegate fullBeerReviewPosted];
		}
		else
		{
			// TODO: handle this gracefully
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	// Populate the fields with values from the user's review (if there is one)
	if ([delegate hasUserReview])
	{
		NSDictionary* review=[delegate getUserReview];
		DLog(@"User's review=%@",review);
	}
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
	return [[delegate getUserReview] objectForKey:@"flavors"];
}

-(void)didSelectFlavor:(NSString*)flavorID
{
	DLog(@"Flavor selected:%@",flavorID);
	// It is the delegate's responsibility to provide a user review NSMutableDictionary. If the delegate doesn't have a review, we ignore this.
	if ([delegate hasUserReview])
	{
		NSMutableArray* flavors=[[delegate getUserReview] objectForKey:@"flavors"];
		if (flavors==nil)
		{
			flavors=[NSMutableArray arrayWithCapacity:10];
			[[delegate getUserReview] setObject:flavors	forKey:@"flavors"];
		}
		
		if ([flavors indexOfObjectIdenticalTo:flavorID]==NSNotFound)
		{
			[flavors addObject:flavorID];
		}
	}
}

-(void)didUnselectFlavor:(NSString*)flavorID
{
	DLog(@"Flavor unselected:%@",flavorID);
	// It is the delegate's responsibility to provide a user review NSMutableDictionary. If the delegate doesn't have a review, we ignore this.
	if ([delegate hasUserReview])
	{
		NSMutableArray* flavors=[[delegate getUserReview] objectForKey:@"flavors"];
		if (flavors)
		{
			NSUInteger idx=[flavors indexOfObjectIdenticalTo:flavorID];
			if (idx!=NSNotFound)
			{
				[flavors removeObjectAtIndex:idx];
			}
		}
	}
}

-(void)doneSelectingFlavors
{
	// Populate Flavors & Aromas text field with the text names for the flavor ids in the review's flavors array
	[(UILabel*)[self.view viewWithTag:kViewTagFlavorsLabel] setText:[self getFlavorsCellText]];
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(NSString*)getFlavorsCellText
{
	if ([delegate hasUserReview])
	{
		BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSDictionary* flavorsdict=[[del getFlavorsDictionary] objectForKey:@"byid"];
		
		NSArray* flavors=[[delegate getUserReview] objectForKey:@"flavors"];
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


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	DLog(@"indexPath.section=%d row=%d",indexPath.section,indexPath.row);

	UITableViewCell *cell=nil;
	
	switch (indexPath.section) {
		case 0:
		{
			static NSString *CellIdentifier = @"BeerNameCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			
			switch (indexPath.row)
			{
				case 0:
					if ([beerObj.data objectForKey:@"beer_name"])
						[cell.textLabel setText:[beerObj.data objectForKey:@"beer_name"]];
					else
						[cell.textLabel setText:[beerObj.data objectForKey:@"name"]];
					UIView* transparentBackground=[[UIView alloc] initWithFrame:CGRectZero];
					transparentBackground.backgroundColor=[UIColor clearColor];
					cell.backgroundView=transparentBackground;
					cell.backgroundColor=[UIColor clearColor];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					break;
				default:
					break;
			}
			break;
		}
		case 1:
		{
			static NSString *CellIdentifier = @"Value2Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			}
			
			switch (indexPath.row)
			{
				case 0:
					[cell.detailTextLabel setText:@"My Rating"];
					cell.detailTextLabel.backgroundColor=[UIColor clearColor];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					ratingControl=[[[RatingControl alloc] initWithFrame:CGRectMake(80,(tableView.rowHeight-30)/2,260,30)] autorelease];
					
					// Set current user's rating (if any)
					if ([delegate hasUserReview])
					{
						NSString* user_rating=[[delegate getUserReview] objectForKey:@"rating"];
						if (user_rating!=nil) // No user review
							ratingControl.currentRating=[user_rating integerValue];
						DLog(@"Current rating:%d",ratingControl.currentRating);
					}
					
					[cell.contentView addSubview:ratingControl];
					break;
				default:
					break;
			}
			break;
		}
		case 2:
		{
			static NSString *CellIdentifier = @"Value2Cell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
			}
			switch (indexPath.row)
			{
				case 0:
				{
					[cell.detailTextLabel setText:@"Body"];
					cell.detailTextLabel.backgroundColor=[UIColor clearColor];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					bodySlider=[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)];
					bodySlider.minimumValue=1.0;
					bodySlider.maximumValue=5.0;
					
					if ([delegate hasUserReview])
						bodySlider.value=[[[delegate getUserReview] objectForKey:@"body"] integerValue];
					
					[cell.contentView addSubview:bodySlider];
					break;
				}
				case 1:
				{
					[cell.detailTextLabel setText:@"Balance"];
					cell.detailTextLabel.backgroundColor=[UIColor clearColor];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					balanceSlider=[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)];
					balanceSlider.minimumValue=1.0;
					balanceSlider.maximumValue=5.0;

					if ([delegate hasUserReview])
						balanceSlider.value=[[[delegate getUserReview] objectForKey:@"balance"] integerValue];

					[cell.contentView addSubview:balanceSlider];
					break;
				}
				case 2:
				{
					[cell.detailTextLabel setText:@"Aftertaste"];
					cell.detailTextLabel.backgroundColor=[UIColor clearColor];
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					aftertasteSlider=[[UISlider alloc] initWithFrame:CGRectMake(125,(tableView.rowHeight-30)/2,150,30)];
					aftertasteSlider.minimumValue=1.0;
					aftertasteSlider.maximumValue=5.0;

					if ([delegate hasUserReview])
						aftertasteSlider.value=[[[delegate getUserReview] objectForKey:@"aftertaste"] integerValue];

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
			static NSString *CellIdentifier = @"DefaultCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			
			switch (indexPath.row)
			{
				case 0: // Flavors & Aromas
				{
					UILabel* label=[[UILabel alloc] initWithFrame:CGRectInset(cell.contentView.frame,25.0,5.0)];
					label.tag=kViewTagFlavorsLabel;
					label.text=[self getFlavorsCellText];
					
					label.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
					label.textAlignment=UITextAlignmentLeft;
					label.lineBreakMode=UILineBreakModeWordWrap;
					label.numberOfLines=0;
					
					[cell.contentView addSubview:label];
					
					[label release];
					break;
				}
				default:
					break;
			}
			break;
		}
		case 4:
		{
			static NSString *CellIdentifier = @"CommentsCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}

			switch (indexPath.row)
			{
				case 0:  // Comments
				{
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
					
					UITextView* tv=[[UITextView alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width-40, 100)];
					if ([delegate hasUserReview])
					{
						tv.text=[[delegate getUserReview] objectForKey:@"comments"];
					}
					tv.contentSize=CGSizeMake(100,100);
					tv.tag=kViewTagCommentsTextView;

					[cell.contentView addSubview:tv];

					[tv release];
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
	[beerObj release];
	[balanceSlider release];
	[bodySlider release];
	[aftertasteSlider release];
	
    [super dealloc];
}


@end


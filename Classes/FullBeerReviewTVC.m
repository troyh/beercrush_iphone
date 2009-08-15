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

@implementation FullBeerReviewTVC

@synthesize beerObj;
@synthesize balanceSlider;
@synthesize bodySlider;
@synthesize aftertasteSlider;
@synthesize ratingControl;

-(id)initWithBeerObject:(BeerObject*)beer
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.beerObj=beer;
		self.title=@"Review";
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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked)] autorelease];
}

-(void)doneButtonClicked
{
	// Post the review
	NSString* bodystr=[NSString stringWithFormat:@"beer_id=%@&rating=%d&body=%.0f&aftertaste=%.0f&balance=%.0f",
														[beerObj.data objectForKey:@"beer_id"],
													    ratingControl.currentRating,
														round(bodySlider.value),
														round(aftertasteSlider.value),
														round(balanceSlider.value)];

	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_POST_BEER_REVIEW];
	NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:nil];
	if ([response statusCode]==200)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		// TODO: handle this gracefully
	}
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
					NSString* user_rating=[beerObj.data objectForKey:@"user_rating"];
					if (user_rating!=nil) // No user review
						ratingControl.currentRating=[user_rating integerValue];
					DLog(@"Current rating:%d",ratingControl.currentRating);
					
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
					break;
				default:
					break;
			}
			break;
		}
		case 4:
		{
			static NSString *CellIdentifier = @"DefaultCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}

			switch (indexPath.row)
			{
				case 0:  // Comments
					cell.selectionStyle=UITableViewCellSelectionStyleNone;
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
	[ratingControl release];
    [super dealloc];
}


@end


//
//  UserReviewsTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 7/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UserReviewsTVC.h"

@implementation UserReviewsTVC

@synthesize reviewsList;
@synthesize totalReviews;
@synthesize seqNext;
@synthesize seqMax;

static const NSInteger kTagBreweryNameLabel=1;
static const NSInteger kTagBeerNameLabel=2;

- (id)init {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.title=@"My Reviews";
		self.reviewsList=[[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

-(NSObject*)navigationRestorationData
{
	return nil;
}


/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

-(void)retrieveReviews:(NSNumber*)seqnum
{
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];

	// Fetch list of user's beer reviews from the server
	NSString* user_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
	if (user_id==nil)
	{
		// TODO: ask the user to login
	}
	else
	{
		NSUInteger origcnt=[self.reviewsList count];
		
		NSMutableDictionary* reviews=[delegate getBeerReviewsByUser:user_id seqNum:seqnum];
		[self.reviewsList addObjectsFromArray:[reviews objectForKey:@"reviews"]];
		self.totalReviews=[[[reviews objectForKey:@"meta"] objectForKey:@"total"] integerValue];
		
		if ([seqnum unsignedIntValue]>0)
		{
			// Insert more rows
			[self.tableView beginUpdates];
			
			NSUInteger n=[[reviews objectForKey:@"reviews"] count];
			NSMutableArray* indexPaths=[NSMutableArray arrayWithCapacity:n];
			for (int i=0;i<n;++i)
			{
				[indexPaths addObject:[NSIndexPath indexPathForRow:origcnt+i inSection:0]];
			}
			[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
			if ([self.reviewsList count]>=self.totalReviews) // We have no more reviews to load?
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:origcnt inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
			
			[self.tableView endUpdates];
		}
		
		[self.tableView reloadData];
	}
	
	[delegate dismissActivityHUD];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[self.reviewsList removeAllObjects];
	self.totalReviews=0;
	self.seqNext=0;
	self.seqMax=0;
	[delegate performAsyncOperationWithTarget:self selector:@selector(retrieveReviews:) object:[NSNumber numberWithInt:0] requiresUserCredentials:YES activityHUDText:NSLocalizedString(@"HUD:GettingReviews",@"Getting Reviews")];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.reviewsList count]+(self.totalReviews-[self.reviewsList count]?1:0);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"URTVCCell";
	
	UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];

		UILabel* breweryNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(45, 1, 200, 12)] autorelease];
		breweryNameLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		breweryNameLabel.textColor=[UIColor grayColor];
		breweryNameLabel.tag=kTagBreweryNameLabel;
		[cell.contentView addSubview:breweryNameLabel];
	}
	
	if (indexPath.row<[self.reviewsList count])
	{
		// Set up the cell...

		NSMutableDictionary* review=[self.reviewsList objectAtIndex:indexPath.row];
//		NSString* s=[[review objectForKey:@"beer"] objectForKey:@"name"];
		NSString* s=[review objectForKey:@"beer_id"];
		if (s==nil)
			[cell.textLabel setText:@"???"];
		else
		{
			BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSDictionary* beer=[appDelegate getBeerDoc:s];
			[cell.textLabel setText:[beer objectForKey:@"name"]];
			
			UILabel* breweryNameLabel=(UILabel*)[cell viewWithTag:kTagBreweryNameLabel];
			[breweryNameLabel setText:[appDelegate breweryNameFromBeerID:[beer objectForKey:@"brewery_id"]]];

			NSArray* starsfmt=[NSArray arrayWithObjects:
							   @"☆☆☆☆☆",
							   @"★☆☆☆☆",
							   @"★★☆☆☆",
							   @"★★★☆☆",
							   @"★★★★☆",
							   @"★★★★★",
							   nil];
			
			// Set up the cell...
			[cell.detailTextLabel setText:[starsfmt objectAtIndex:[[review objectForKey:@"rating"] integerValue]]];
			[beer release];
		}
	}
	else
	{
		// Add the "More reviews..." table cell
		cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
		[cell.textLabel setText:[NSString stringWithFormat:@"%d more reviews",self.totalReviews-[self.reviewsList count]]];
		cell.textLabel.textAlignment=UITextAlignmentCenter;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row<[self.reviewsList count])
	{
		NSDictionary* reviewData=[self.reviewsList objectAtIndex:indexPath.row];
		FullBeerReviewTVC* fbrtvc=[[[FullBeerReviewTVC alloc] initWithReviewObject:reviewData] autorelease];
		fbrtvc.delegate=self;
		[self.navigationController pushViewController:fbrtvc animated:YES];
	}
	else if (self.totalReviews-[self.reviewsList count])
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		// Query the server for the next set of reviews
		// TODO: put spinner in accessoryview so the user knows network stuff is going on
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(retrieveReviews:) object:[NSNumber numberWithInt:self.seqNext] requiresUserCredentials:YES activityHUDText:NSLocalizedString(@"HUD:GettingReviews",@"Getting Reviews")];
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
	[self.reviewsList release];
    [super dealloc];
}

#pragma mark FullBeerReviewTVCDelegate methods

-(NSDictionary*)fullBeerReviewGetBeerData
{
	return nil; // TODO: what to do here? Is this method even necessary? Can't the caller just ask the App Delegate to retrieve the beer doc from the server or its cache?
}

-(void)fullBeerReviewVCReviewCancelled:(FullBeerReviewTVC *)vc
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)fullBeerReview:(NSDictionary*)review withChanges:(BOOL)edited
{
	if (edited)
	{
		BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSData* answer;
		if ([[del postBeerReview:review returningData:&answer] statusCode]==200)
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

-(NSString*)beerName
{
	return nil;
}

-(NSString*)breweryName
{
	return nil;
}


@end


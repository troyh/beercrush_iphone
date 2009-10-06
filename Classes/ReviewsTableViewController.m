//
//  ReviewsTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReviewsTableViewController.h"
#import "RatingView.h"

@implementation ReviewsTableViewController

@synthesize reviewedDocID;
@synthesize reviewsList;
@synthesize totalReviews;
@synthesize reviewsSeqNum;
@synthesize reviewsSeqMax;
@synthesize fullBeerReviewDelegate;

-(id)initWithID:(NSString*)docid dataType:(ResultType)t
{
	self.reviewedDocID=docid;

	self.title=@"Reviews";

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
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addReviewButtonClicked:)] autorelease];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(getReviews:) object:self.reviewedDocID withActivityHUD:YES andActivityHUDText:NSLocalizedString(@"HUD:GettingReviews", @"Getting Reviews")];
}
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
-(void)getReviews:(NSString*)docid
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSDictionary* doc=[appDelegate getReviewsForDocID:docid];
	if (doc)
	{
		self.reviewsList=[doc objectForKey:@"reviews"];
		self.totalReviews=0;
		self.reviewsSeqNum=0;
		self.reviewsSeqMax=0;

		id v=[doc valueForKey:@"total"];
		if ([v isKindOfClass:[NSNumber class]])
			self.totalReviews=[(NSNumber*)v unsignedIntValue];

		v=[doc valueForKey:@"seqnum"];
		if ([v isKindOfClass:[NSNumber class]])
			self.reviewsSeqNum=[(NSNumber*)v unsignedIntValue];

		v=[doc valueForKey:@"seqmax"];
		if ([v isKindOfClass:[NSNumber class]])
			self.reviewsSeqMax=[(NSNumber*)v unsignedIntValue];
		
		[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	}
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.totalReviews>[self.reviewsList count])
		return [self.reviewsList count]+1; // Extra row for the button to get more reviews
    return [self.reviewsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	enum {
		kTagUserIDLabel=1,
		kTagDateLabel,
		kTagTextLabel,
		kTagStarsView,
		kTagAvatarView
	};
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];

		// Create user_id view
		UILabel* userIDLabel=[[[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, 20)] autorelease];
		userIDLabel.tag=kTagUserIDLabel;
		userIDLabel.font=[UIFont boldSystemFontOfSize:16];
		[cell.contentView addSubview:userIDLabel];
		
		// Create Date view
		UILabel* dateLabel=[[[UILabel alloc] initWithFrame:CGRectMake(260, 0, 80, 20)] autorelease];
		dateLabel.tag=kTagDateLabel;
		dateLabel.font=[UIFont systemFontOfSize:12];
		[cell.contentView addSubview:dateLabel];

		// Create text view
		UILabel* textLabel=[[[UILabel alloc] initWithFrame:CGRectMake(3, 40, 300, 20)] autorelease];
		textLabel.tag=kTagTextLabel;
		textLabel.font=[UIFont systemFontOfSize:14];
		[cell.contentView addSubview:textLabel];

		// Create stars view
		RatingView* ratingView=[[[RatingView alloc] initWithFrame:CGRectMake(40, 20, 80, 20)] autorelease];
		ratingView.tag=kTagStarsView;
		[cell.contentView addSubview:ratingView];
		
		// Create avatar view
		UIImageView* avatarView=[[[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 35, 35)] autorelease];
		avatarView.tag=kTagAvatarView;
		[cell.contentView addSubview:avatarView];
		
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
	
	if (indexPath.row >= [self.reviewsList count])
	{
		[cell.textLabel setText:[NSString stringWithFormat:@"%d more reviews",(self.totalReviews-[self.reviewsList count]),nil]];
	}
	else
	{
		UILabel* label=(UILabel*)[cell viewWithTag:kTagUserIDLabel];
		[label setText:[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"user_id"]];

		label=(UILabel*)[cell viewWithTag:kTagDateLabel];
		id v=[[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"meta"] objectForKey:@"mtime"];
		if ([v isKindOfClass:[NSNumber class]])
		{
			NSDate* date=[NSDate dateWithTimeIntervalSince1970:[(NSNumber*)v unsignedIntValue]];
			NSDateFormatter* df=[[[NSDateFormatter alloc] init] autorelease];
			[df setDateStyle:NSDateFormatterShortStyle];
			[df setTimeStyle:NSDateFormatterNoStyle];
			[label setText:[df stringFromDate:date]];
		}

		label=(UILabel*)[cell viewWithTag:kTagTextLabel];
		[label setText:[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"comments"]];

		RatingView* rv=(RatingView*)[cell viewWithTag:kTagStarsView];
		v=[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"rating"];
		if ([v isKindOfClass:[NSNumber class]])
		{
			[rv setRating:[(NSNumber*)v floatValue]];
		}
		
		UIImageView* avatar=(UIImageView*)[cell viewWithTag:kTagAvatarView];
		avatar.image=[UIImage imageNamed:@"avatar_default.png"];

	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Find out what type of document this review is for...
	UIViewController* vc=nil;
	
	if ([[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"beer_id"]!=nil) // It's a beer review
	{
		FullBeerReviewTVC* fbrtvc=[[[FullBeerReviewTVC alloc] initWithReviewObject:[self.reviewsList objectAtIndex:indexPath.row]] autorelease];
		fbrtvc.delegate=self.fullBeerReviewDelegate?self.fullBeerReviewDelegate:self;
		vc=fbrtvc;
	}
	
	if (vc!=nil)
		[self.navigationController pushViewController:vc animated:YES];
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
	[reviewedDocID release];
	[reviewsList release];

    [super dealloc];
}

#pragma mark FullBeerReviewTVCDelegate methods

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

-(void)fullBeerReviewVCReviewCancelled:(FullBeerReviewTVC *)vc
{
	[self dismissModalViewControllerAnimated:YES];
}

-(NSDictionary*)fullBeerReviewGetBeerData
{
	return [self.fullBeerReviewDelegate fullBeerReviewGetBeerData];
}

-(NSString*)beerName
{
	return nil;
}

-(NSString*)breweryName
{
	return nil;
}

#pragma mark Action methods

-(void)addReviewButtonClicked:(id)sender
{
	FullBeerReviewTVC* vc=[[[FullBeerReviewTVC alloc] initAsNewReviewOfBeer:[self.fullBeerReviewDelegate fullBeerReviewGetBeerData]] autorelease];
	vc.delegate=self;
	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	[self presentModalViewController:nc animated:YES];
}

@end


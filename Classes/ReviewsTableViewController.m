//
//  ReviewsTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ReviewsTableViewController.h"

@implementation ReviewsTableViewController

@synthesize reviewedDocID;
@synthesize xmlParserPath;
@synthesize currentElemValue;
@synthesize reviewsList;
@synthesize totalReviews;
@synthesize fullBeerReviewDelegate;

-(id)initWithID:(NSString*)docid dataType:(ResultType)t
{
	self.reviewedDocID=docid;
	self.xmlParserPath=[NSMutableArray arrayWithCapacity:5];
	self.reviewsList=[NSMutableArray arrayWithCapacity:10];
	self.totalReviews=0;

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

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(getReviews:) object:self.reviewedDocID withActivityHUD:YES andActivityHUDText:@"Getting Reviews"];
}

-(void)getReviews:(NSString*)docid
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate getReviewsForDocID:docid];
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


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if (indexPath.row > [self.reviewsList count])
	{
		[cell.textLabel setText:[NSString stringWithFormat:@"%d more reviews",(self.totalReviews-[self.reviewsList count]),nil]];
	}
	else
	{
		NSArray* starsfmt=[NSArray arrayWithObjects:
			@"☆☆☆☆☆ %@",
			@"★☆☆☆☆ %@",
			@"★★☆☆☆ %@",
			@"★★★☆☆ %@",
			@"★★★★☆ %@",
			@"★★★★★ %@",
			nil];

		// Set up the cell...
		[cell.textLabel setText:[NSString stringWithFormat:[starsfmt objectAtIndex:[[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"rating"] integerValue]],
							[[self.reviewsList objectAtIndex:indexPath.row] objectForKey:@"user_id"]
							
		]];
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
	currentElemValue=nil;
	[reviewsList release];
	[xmlParserPath release];

    [super dealloc];
}

// FullBeerReviewTVCDelegate methods

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


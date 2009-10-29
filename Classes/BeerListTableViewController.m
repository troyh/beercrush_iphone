//
//  BeerListTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "BeerListTableViewController.h"
#import "BrowseBrewersTVC.h"

@implementation BeerListTableViewController

@synthesize delegate;
@synthesize breweryID;
@synthesize placeID;
@synthesize wishlistID;
// TODO: just use one ID string above and use an enum to signify the type of ID it is
@synthesize beerList;
@synthesize btvc;
@synthesize setRightBarButtonItem;

static const NSInteger kTagBreweryNameLabel=1;
static const NSInteger kTagBeerNameLabel=2;

-(id)initWithBreweryID:(NSString*)brewery_id
{
	[super initWithStyle:UITableViewStylePlain];
	
	self.setRightBarButtonItem=YES;
	
	NSArray* parts=[brewery_id componentsSeparatedByString:@":"];
	if ([[parts objectAtIndex:0] isEqualToString:@"place"])
	{
		self.placeID=brewery_id;
		self.title=@"Beer List";
	}
	else if ([[parts objectAtIndex:0] isEqualToString:@"brewery"])
	{
		self.breweryID=brewery_id;
		self.title=@"Beer List";
	}
	else if ([[parts objectAtIndex:0] isEqualToString:@"wishlist"])
	{
		self.wishlistID=brewery_id;
		self.title=@"Wish List";
	}
	
	self.beerList=nil;
	
	return self;
}

- (void)dealloc {
//	DLog(@"currentElemValue retainCount=%d",[self.currentElemValue retainCount]);
//	DLog(@"currentElemAttribs retainCount=%d",[self.currentElemAttribs retainCount]);
	[self.breweryID release];
	[self.beerList release];
	
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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	if (setRightBarButtonItem)
	{
		if (self.placeID)
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd	target:self action:@selector(browseBrewersPanel)] autorelease];
		else if (self.breweryID)
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd	target:self action:@selector(newBeerPanel)] autorelease];
	}
}

/*
 * New beers panel
 */
-(void)newBeerPanel
{
//	UIActionSheet* sheet=[[[UIActionSheet alloc] initWithTitle:@"New Beer" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
//	[sheet showInView:self.tableView];

	UIViewController* vc=[[[UIViewController alloc] init] autorelease];
	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	
	self.btvc=[[BeerTableViewController alloc] initWithBeerID:nil];
	self.btvc.breweryID=self.breweryID;
	self.btvc.delegate=self;
	[nc pushViewController:btvc	animated:NO];
	
//	// Add cancel and save buttons
//	UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(newBeerCancelButtonClicked)] autorelease];
//	UIBarButtonItem* saveButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(newBeerSaveButtonClicked)] autorelease];
	
	[btvc setEditing:YES animated:NO];
	
	[self presentModalViewController:nc animated:YES];
//	[nc.navigationBar.topItem setLeftBarButtonItem:cancelButton animated:NO];
//	[nc.navigationBar.topItem setRightBarButtonItem:saveButton animated:NO];
	
}

-(void)didSaveBeerEdits
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)didCancelBeerEdits
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

/*
 * Browse Brewers panel
 */
-(void)browseBrewersPanel
{
	SearchVC* vc=[[[SearchVC alloc] init] autorelease];
	vc.delegate=self;
	vc.searchTypes=BeerCrushSearchTypeBeers|BeerCrushSearchTypeBreweries;
	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	[self presentModalViewController:nc animated:YES];
	
//	//	UIActionSheet* sheet=[[[UIActionSheet alloc] initWithTitle:@"New Beer" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
//	//	[sheet showInView:self.tableView];
//	
//	UIViewController* vc=[[[UIViewController alloc] init] autorelease];
//	UINavigationController* nc=[[UINavigationController alloc] initWithRootViewController:vc];
//	
//	BrowseBrewersTVC* bbtvc=[[[BrowseBrewersTVC alloc] init] autorelease];
//	[nc pushViewController:bbtvc animated:NO];
//	
//	// Add cancel buttons
//	UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(browseBrewersCancelButtonClicked)] autorelease];
//	
//	[self presentModalViewController:nc animated:YES];
//	// Take the (left) Back button off the navbar
//	[nc.navigationBar.topItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]] autorelease]];
//	// Put a cancel button on the right
//	[nc.navigationBar.topItem setRightBarButtonItem:cancelButton animated:NO];
//
//	// Set onBeerSelected selector so we're called when the user selects a beer
//	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
//	[delegate setOnBeerSelectedAction:@selector(addBeerToMenu:) target:self];
}

-(void)browseBrewersCancelButtonClicked
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)addBeerToMenu:(NSString*)beerID
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(postBeerToMenu:) object:beerID requiresUserCredentials:NO activityHUDText:@""];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate performAsyncOperationWithTarget:self selector:@selector(getBeerList:) object:nil requiresUserCredentials:wishlistID?YES:NO activityHUDText:NSLocalizedString(@"HUD:GettingBeerList",@"Retrieveing beer list from server")];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [NSString string];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.wishlistID)
		return [[beerList objectForKey:@"items"] count];
    return [[beerList objectForKey:@"beers"] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BeerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

		UILabel* beerNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(45, 8, 250, 30)] autorelease];
		beerNameLabel.font=[UIFont boldSystemFontOfSize:15];
		beerNameLabel.textColor=[UIColor blackColor];
		beerNameLabel.tag=kTagBeerNameLabel;
		[cell.contentView addSubview:beerNameLabel];
		
		UILabel* breweryNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(45, 1, 200, 12)] autorelease];
		breweryNameLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		breweryNameLabel.textColor=[UIColor grayColor];
		breweryNameLabel.tag=kTagBreweryNameLabel;
		[cell.contentView addSubview:breweryNameLabel];
    }
    
    // Set up the cell...
	NSDictionary* beer=nil;
	if (self.wishlistID)
		beer=[[beerList objectForKey:@"items"] objectAtIndex:indexPath.row];
	else
		beer=[[beerList objectForKey:@"beers"] objectAtIndex:indexPath.row];
	
	UILabel* beerNameLabel=(UILabel*)[cell.contentView viewWithTag:kTagBeerNameLabel];
	[beerNameLabel setText:[beer objectForKey:@"name"]];

	cell.imageView.image=[UIImage imageNamed:@"beer.png"];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	UILabel* breweryNameLabel=(UILabel*)[cell.contentView viewWithTag:kTagBreweryNameLabel];

	/*
	 Wish List docs and beerlist docs are in different formats. Those should probably be changed on the server to be more consistent.
	 */
	NSString* beer_id=[beer objectForKey:@"beer_id"];
	if (beer_id==nil)
	{
		// Uh oh.
	}
	
	[breweryNameLabel setText:[appDelegate breweryNameFromBeerID:beer_id]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary* beer=nil;
	if (self.wishlistID)
		beer=[[beerList objectForKey:@"items"] objectAtIndex:indexPath.row];
	else
		beer=[[beerList objectForKey:@"beers"] objectAtIndex:indexPath.row];
	
	/*
	 Wish List docs and beerlist docs are in different formats. Those should probably be changed on the server to be more consistent.
	 */
	NSString* beer_id=[beer objectForKey:@"beer_id"];
	if (beer_id)
	{
		if (self.delegate && [self.delegate beerListTVCDidSelectBeer:beer_id]==NO)
		{
			// The delegate doesn't want us to continue navigating
		}
		else
		{
			BeerTableViewController* vc=[[[BeerTableViewController alloc] initWithBeerID:beer_id] autorelease];
			[self.navigationController pushViewController:vc animated:YES];
		}
	}
}

#pragma mark Async operations

-(void)getBeerList:(NSObject*)obj
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];

	self.beerList=nil;

	// Retrieve a JSON doc from server
	if (breweryID)
	{	// Get brewery doc, it includes the beer list
		self.beerList=[appDelegate getBeerList:self.breweryID];
	}
	else
	{
		NSURL* url=nil;
		if (placeID)
		{	// Get the place menu doc
			NSArray* idparts=[placeID componentsSeparatedByString:@":"];
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_MENU_DOC, [idparts objectAtIndex:0], [idparts objectAtIndex:1]]];
		}
		else if (wishlistID)
		{	 // Get the wishlist doc
			NSString* user_id=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
			if (user_id==nil)
				user_id=@"";
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_WISHLIST_DOC, user_id]];
		}

		if (url)
		{
			NSMutableDictionary* answer;
			NSHTTPURLResponse* response=[appDelegate sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
			if ([response statusCode]==200)
			{
				self.beerList=answer;
			}
			else {
				[self performSelectorOnMainThread:@selector(getBeerListFailed) withObject:nil waitUntilDone:NO];
			}
		}
	}

	[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[appDelegate dismissActivityHUD];
}

-(void)postBeerToMenu:(NSString*)beerID
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_MENU_DOC];
	NSString* postdata=[[NSString alloc] initWithFormat:
						@"place_id=%@&"
						"add_item=%@",
						self.placeID,
						beerID];
	NSMutableDictionary* answer=nil;
	NSHTTPURLResponse* response=[appDelegate sendJSONRequest:url usingMethod:@"POST" withData:postdata returningJSON:&answer];
	[appDelegate dismissActivityHUD];
	if ([response statusCode]==200)
	{
		self.beerList=answer;
	}
	else 
	{
		self.beerList=nil;
		[self performSelectorOnMainThread:@selector(postBeerToMenuFailed) withObject:nil waitUntilDone:NO];
	}

	[postdata release];
	
}

-(void)getBeerListFailed
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Beer List",@"GetBeerList: failure alert title")
												  message:NSLocalizedString(@"Failed to get beer list",@"GetBeerList: failure alert message")
												 delegate:nil
										cancelButtonTitle:NSLocalizedString(@"OK",@"GetBeerList: failure alert cancel button title")
										otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)postBeerToMenuFailed
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add to Menu",@"AddToBeerMenu: failure alert title")
												  message:NSLocalizedString(@"Failed to add beer to menu",@"AddToBeerMenu: failure alert message")
												 delegate:nil
										cancelButtonTitle:NSLocalizedString(@"OK",@"AddToBeerMenu: failure alert cancel button title")
										otherButtonTitles:nil];
	[alert show];
	[alert release];
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

#pragma mark SearchVCDelegate methods

-(BOOL)searchVC:(SearchVC*)searchVC didSelectSearchResult:(NSString*)id_string
{
	if ([[id_string substringToIndex:5] isEqualToString:@"beer:"])
	{
		[self addBeerToMenu:id_string];
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
	else if ([[id_string substringToIndex:8] isEqualToString:@"brewery:"])
	{
		// Show the brewery's beer list
		BeerListTableViewController* vc=[[[BeerListTableViewController alloc] initWithBreweryID:id_string] autorelease];
		vc.delegate=self;
		if (self.modalViewController)
		{
			UINavigationController* nc=(UINavigationController*)self.modalViewController;
			[nc pushViewController:vc animated:YES];
		}
	}
	return NO;
}

#pragma mark BeerListTVCDelegate methods

-(BOOL)beerListTVCDidSelectBeer:(NSString*)beer_id
{
	[self addBeerToMenu:beer_id];
	[self.navigationController dismissModalViewControllerAnimated:YES];
	return NO;
}


@end


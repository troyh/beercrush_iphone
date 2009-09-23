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

@synthesize breweryID;
@synthesize placeID;
@synthesize wishlistID;
// TODO: just use one ID string above and use an enum to signify the type of ID it is
@synthesize currentElemValue;
@synthesize	currentElemAttribs;
@synthesize xmlParserPath;
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
	
	self.currentElemAttribs=nil;
	self.currentElemValue=nil;
	self.xmlParserPath=nil;
	self.beerList=nil;
	
	
	beerList=[[NSMutableArray alloc] initWithCapacity:10];
	
	return self;
}

- (void)dealloc {
//	DLog(@"currentElemValue retainCount=%d",[self.currentElemValue retainCount]);
//	DLog(@"currentElemAttribs retainCount=%d",[self.currentElemAttribs retainCount]);
	[self.breweryID release];
	[self.beerList release];
	[self.currentElemValue release];
	self.currentElemValue=nil;
	[self.currentElemAttribs release];
	
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
	//	UIActionSheet* sheet=[[[UIActionSheet alloc] initWithTitle:@"New Beer" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
	//	[sheet showInView:self.tableView];
	
	UIViewController* vc=[[[UIViewController alloc] init] autorelease];
	UINavigationController* nc=[[UINavigationController alloc] initWithRootViewController:vc];
	
	BrowseBrewersTVC* bbtvc=[[[BrowseBrewersTVC alloc] init] autorelease];
	[nc pushViewController:bbtvc animated:NO];
	
	// Add cancel buttons
	UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(browseBrewersCancelButtonClicked)] autorelease];
	
	[self presentModalViewController:nc animated:YES];
	// Take the (left) Back button off the navbar
	[nc.navigationBar.topItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]] autorelease]];
	// Put a cancel button on the right
	[nc.navigationBar.topItem setRightBarButtonItem:cancelButton animated:NO];

	// Set onBeerSelected selector so we're called when the user selects a beer
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate setOnBeerSelectedAction:@selector(addBeerToMenu:) target:self];
}

-(void)browseBrewersCancelButtonClicked
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];

	// Clear onBeerSelected selector so we're not called when the user selects a beer
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate setOnBeerSelectedAction:nil target:nil];
}

-(void)addBeerToMenu:(NSString*)beerID
{
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate performAsyncOperationWithTarget:self selector:@selector(postBeerToMenu:) object:beerID withActivityHUD:YES andActivityHUDText:@""];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([appDelegate restoringNavigationStateAutomatically])
	{
		NSObject* navData=[appDelegate nextNavigationStateToRestore];
		if ([navData isKindOfClass:[NSString class]])
		{
			NSString* beerID=(NSString*)navData;
			if (beerID)
			{
				[appDelegate pushNavigationStateForTabBarItem:self.tabBarController.tabBarItem withData:beerID]; // Saves the new nav state
				
				BeerTableViewController* vc=[[[BeerTableViewController alloc] initWithBeerID:beerID] autorelease];
				[self.navigationController pushViewController:vc animated:NO];
			}
		}
	}
	else
	{
		[appDelegate popNavigationStateForTabBarItem:self.tabBarItem];
		
		// Retrieve an XML doc from server
		NSURL* url=nil;
		if (breweryID)
		{	// Get brewery doc, it includes the beer list
			NSArray* idparts=[breweryID componentsSeparatedByString:@":"];
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_BEERLIST, [idparts objectAtIndex:1]]];
			
		}
		else if (placeID)
		{	// Get the place menu doc
			NSArray* idparts=[placeID componentsSeparatedByString:@":"];
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_MENU_DOC, [idparts objectAtIndex:0], [idparts objectAtIndex:1]]];
		}
		else if (wishlistID)
		{	 // Get the wishlist doc
			NSArray* idparts=[wishlistID componentsSeparatedByString:@":"];
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_WISHLIST_DOC, [idparts objectAtIndex:1]]];
		}

		if (url)
		{
			[beerList removeAllObjects];
			BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			[delegate performAsyncOperationWithTarget:self selector:@selector(getBeerList:) object:url withActivityHUD:YES andActivityHUDText:@"Getting Beer List"];
		}
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
    return [beerList count];
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
	BeerObject* beer=[beerList objectAtIndex:indexPath.row];
	UILabel* beerNameLabel=(UILabel*)[cell.contentView viewWithTag:kTagBeerNameLabel];
	[beerNameLabel setText:[beer.data objectForKey:@"name"]];

	cell.imageView.image=[UIImage imageNamed:@"beer.png"];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	UILabel* breweryNameLabel=(UILabel*)[cell.contentView viewWithTag:kTagBreweryNameLabel];
	[breweryNameLabel setText:[appDelegate breweryNameFromBeerID:[beer.data objectForKey:@"id"]]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BeerObject* beer=[beerList objectAtIndex:indexPath.row];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([appDelegate onBeerSelected:[beer.data valueForKey:@"id"]]==NO)
	{
		[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:[beer.data valueForKey:@"id"]]; // Saves the new nav state
		
		BeerTableViewController* vc=[[[BeerTableViewController alloc] initWithBeerID:[beer.data valueForKey:@"id"]] autorelease];
		[self.navigationController pushViewController:vc animated:YES];
	}
}

#pragma mark Async operations

-(void)getBeerList:(NSURL*)url
{
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[appDelegate sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		self.beerList=[answer objectForKey:@"items"];
	}
	else {
		[self.beerList removeAllObjects];
	}

	[self.tableView reloadData];
	
	[appDelegate dismissActivityHUD];
}

-(void)postBeerToMenu:(NSString*)beerID
{
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_MENU_DOC];
	NSString* postdata=[[NSString alloc] initWithFormat:
						@"place_id=%@&"
						"add_item=%@",
						self.placeID,
						beerID];
	NSMutableDictionary* answer=nil;
	[delegate sendJSONRequest:url usingMethod:@"POST" withData:postdata returningJSON:&answer];
	if (answer)
	{
		self.beerList=[answer objectForKey:@"items"];
	}
	else 
	{
		[self.beerList removeAllObjects];
	}

	[postdata release];
	
	[delegate dismissActivityHUD];
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

@end


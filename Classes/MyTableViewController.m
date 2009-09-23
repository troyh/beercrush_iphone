//
//  MyTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyTableViewController.h"
#import "JSON.h"

@implementation MyTableViewController

@synthesize searchBar;
@synthesize resultsList;
@synthesize searchTypes;

-(void)autocomplete:(NSString*)qs 
{
	if (self.resultsList==nil)
		self.resultsList=[[NSMutableArray alloc] initWithCapacity:10];
	else
		[self.resultsList removeAllObjects];
	
	// Send the query off to the server
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];

	const char* dataset="";
	if (self.searchTypes == (BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
		dataset="beersandbreweries";
	else if (self.searchTypes == BeerCrushSearchTypeBreweries)
		dataset="breweries";
	else if (self.searchTypes == BeerCrushSearchTypeBeers)
		dataset="beers";
	else if (self.searchTypes == BeerCrushSearchTypePlaces)
		dataset="places";
	
	NSURL* url=[NSURL URLWithString:[[NSString stringWithFormat:BEERCRUSH_API_URL_AUTOCOMPLETE_QUERY, qs, dataset ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSData* answer;
	NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
	
	if ([response statusCode]==200)
	{
		char* p=(char*)[answer bytes];
		while (p)
		{	// Count the number of items
			char* tab=strchr(p,'\t');
			if (!tab)
				p=nil; // Quit
			else
			{
				*tab='\0';
				char* nl=strchr(tab+1, '\n');
				if (!nl)
					p=nil; // Quit
				else
				{
					*nl='\0';
					
					if (p && tab)
					{
						NSMutableDictionary* result=[NSMutableDictionary dictionaryWithCapacity:2];
						[result setObject:[NSString stringWithCString:p encoding:NSUTF8StringEncoding] forKey:@"name"];
						[result setObject:[NSString stringWithCString:tab+1 encoding:NSUTF8StringEncoding] forKey:@"id"];
						[self.resultsList addObject:result];
					}
					
					p=nl+1;
				}
			}
		}
		DLog(@"%d results",[self.resultsList count]);
		[self.tableView reloadData];
	}
	else
	{
//		[appDelegate alertUser:@"Search failed"];
	}
}

-(void)query:(NSString*)qs 
{
	// Send the query off to the server
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	const char* dataset="";
	if (self.searchTypes == (BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
		dataset="beersandbreweries";
	else if (self.searchTypes == BeerCrushSearchTypeBreweries)
		dataset="breweries";
	else if (self.searchTypes == BeerCrushSearchTypeBeers)
		dataset="beers";
	else if (self.searchTypes == BeerCrushSearchTypePlaces)
		dataset="places";
	
	NSURL* url=[NSURL URLWithString:[[NSString stringWithFormat:BEERCRUSH_API_URL_SEARCH_QUERY, qs, dataset ] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSData* answer;
	
	NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
	
	if ([response statusCode]==200)
	{
		NSString* s=[[[NSString alloc] initWithData:answer encoding:NSUTF8StringEncoding] autorelease];
		NSDictionary* results=[s JSONValue];
		self.resultsList=[[results objectForKey:@"response"] objectForKey:@"docs"];
		DLog(@"Results:%@",results);
	}
	else
	{
		//		[appDelegate alertUser:@"Search failed"];
	}
	[self.tableView reloadData];

}

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
//		self.title=@"Beer search";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.searchBar=[[UISearchBar alloc] initWithFrame:CGRectZero];

	if (self.searchTypes==(BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
		self.searchBar.placeholder=@"Beers, brewers, etc.";
	else if (self.searchTypes==BeerCrushSearchTypePlaces)
		self.searchBar.placeholder=@"Pubs, restaurants, bars, stores, etc.";
	
	self.searchBar.delegate=self;
	[self.searchBar sizeToFit];
	[self.navigationController.navigationBar addSubview:self.searchBar];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
	// Resize the tableview so that it isn't obscured by the keyboard
	CGRect bounds=[[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
	CGPoint center=[[[notification userInfo] objectForKey:UIKeyboardCenterEndUserInfoKey] CGPointValue];
	
	CGRect keyboardFrame=CGRectMake(round(center.x - bounds.size.width/2.0), round(center.y - bounds.size.height/2.0), bounds.size.width, bounds.size.height);
	CGRect tableViewFrame=[self.tableView.window convertRect:self.tableView.frame fromView:self.tableView.superview];
	
	CGRect intersectionFrame=CGRectIntersection(tableViewFrame, keyboardFrame);
	
	UIEdgeInsets insets=UIEdgeInsetsMake(0, 0, intersectionFrame.size.height, 0);
	
	[self.tableView setContentInset:insets];
	[self.tableView setScrollIndicatorInsets:insets];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
	// Resize the tableview back to normal
	[self.tableView setContentInset:UIEdgeInsetsZero];
	[self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([appDelegate restoringNavigationStateAutomatically])
	{
		searchBar.hidden=YES;
		
		NSObject* navData=[appDelegate nextNavigationStateToRestore];
		if ([navData isKindOfClass:[NSString class]])
		{
			// See what type it is
			NSString* idstr=(NSString*)navData;
			if (idstr)
			{
				if ([[idstr substringToIndex:8] isEqualToString:@"brewery:"])
				{
					BreweryTableViewController* btvc=[[[BreweryTableViewController alloc] initWithBreweryID:idstr] autorelease];
					[self.navigationController pushViewController: btvc animated:NO];
					
					[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
				}
				else if ([[idstr substringToIndex:5] isEqualToString:@"beer:"])
				{
					BeerTableViewController* btvc=[[[BeerTableViewController alloc] initWithBeerID:idstr] autorelease];
					[self.navigationController pushViewController:btvc animated:NO];
					
					[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
				}
				else if ([[idstr substringToIndex:6] isEqualToString:@"place:"])
				{
					PlaceTableViewController* btvc=[[[PlaceTableViewController alloc] initWithPlaceID:idstr] autorelease];
					[self.navigationController pushViewController: btvc animated:NO];
					
					[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
				}
			}
		}
	}
	else
	{
		searchBar.hidden=NO; // Put searchbar back
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
	// TODO: free any search results
}

//
// UISearchBarDelegate methods
//

- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText
{
	if (searchText.length)
	{
		[bar setShowsCancelButton:NO animated:YES];

		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(autocomplete:) object:searchText withActivityHUD:NO andActivityHUDText:nil];
	}
	else
	{
		[self.resultsList removeAllObjects];

		[bar setShowsCancelButton:YES animated:YES];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
	if (bar.text.length)
	{
		[bar endEditing:YES];
	
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(query:) object:bar.text withActivityHUD:YES andActivityHUDText:@"Searching"];
	}
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)bar
{
	if (bar.text.length)
		[bar setShowsCancelButton:NO animated:YES];
}

//-(BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
//{
//	return YES;
//}

- (void)searchBarCancelButtonClicked:(UISearchBar *)bar
{
	[bar endEditing:YES];
    bar.text = @"";
	
	[self.resultsList removeAllObjects];

	[bar setShowsCancelButton:NO animated:YES];
	[self.tableView reloadData];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell* cell=nil;
	
	if ([self.resultsList count]==0)
	{ // Show the Add a [Brewery|Place] row
		switch (indexPath.row) {
			case 0:
			{
				static NSString *CellIdentifier = @"ZeroResultsCell";
				
				cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
				}
				
				[cell.textLabel setText:@"0 matches"];
				if (self.searchTypes == (BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
					[cell.detailTextLabel setText:@"Are we missing a beer or brewery? Help us improve."];
				else if (self.searchTypes == BeerCrushSearchTypeBreweries)
					[cell.detailTextLabel setText:@"Are we missing a brewery? Help us improve."];
				else if (self.searchTypes == BeerCrushSearchTypeBeers)
					[cell.detailTextLabel setText:@"Are we missing a beer? Help us improve."];
				else if (self.searchTypes == BeerCrushSearchTypePlaces)
					[cell.detailTextLabel setText:@"Are we missing a place? Help us improve."];

				UIButton* addButton=[UIButton buttonWithType:UIButtonTypeContactAdd];
				addButton.frame=CGRectMake(0, 0, 30, 30);
				[addButton addTarget:self action:@selector(addBeerOrBreweryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
				
				cell.accessoryView=addButton;
				
				break;
			}
			case 1:
			{
				static NSString *CellIdentifier = @"AddOneCell";
				
				cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				}
				
				[cell.textLabel setText:@"Add a Brewery"];
				

				break;
			}
			default:
				break;
		}
	}
	else 
	{
		static NSString *CellIdentifier = @"Cell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
    
		// Set up the cell...

		[cell.textLabel setText:[[self.resultsList objectAtIndex:indexPath.row] objectForKey:@"name"]];
		NSString* idstr=[[self.resultsList objectAtIndex:indexPath.row] objectForKey:@"id"];
		if ([[idstr substringToIndex:5] isEqualToString:@"beer:"])
		{ // Beer
			[cell.imageView initWithImage:[UIImage imageNamed:@"beer.png"]];
		}
		else if ([[idstr substringToIndex:6] isEqualToString:@"place:"])
		{ // Place
			[cell.imageView initWithImage:[UIImage imageNamed:@"restaurant.png"]];
		}
		else if ([[idstr substringToIndex:8] isEqualToString:@"brewery:"])
		{ // Brewery
			[cell.imageView initWithImage:[UIImage imageNamed:@"brewery.png"]];
		}
		
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

//	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
//	appDelegate.mySearchBar.hidden=YES;
//	appDelegate.nav.navigationBarHidden=NO;

	self.searchBar.hidden=YES;
	[searchBar endEditing:YES];

	NSString* idstr=[[self.resultsList objectAtIndex:indexPath.row] objectForKey:@"id"];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		
	if ([[idstr substringToIndex:8] isEqualToString:@"brewery:"])
	{
		BreweryTableViewController* btvc=[[[BreweryTableViewController alloc] initWithBreweryID:idstr] autorelease];
		[self.navigationController pushViewController: btvc animated:YES];
		
		[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
	}
	else if ([[idstr substringToIndex:5] isEqualToString:@"beer:"])
	{
		BeerTableViewController* btvc=[[[BeerTableViewController alloc] initWithBeerID:idstr] autorelease];
		[self.navigationController pushViewController:btvc animated:YES];

		[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
	}
	else if ([[idstr substringToIndex:6] isEqualToString:@"place:"])
	{
		PlaceTableViewController* btvc=[[[PlaceTableViewController alloc] initWithPlaceID:idstr] autorelease];
		[self.navigationController pushViewController: btvc animated:YES];

		[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
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
	[searchBar release];
	[self.resultsList release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

#pragma mark Events

-(void)addBeerOrBreweryButtonClicked:(id)sender
{
	UIViewController* vc=[[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	
	if (self.searchTypes & BeerCrushSearchTypeBreweries)
	{
		BreweryTableViewController* btvc=[[[BreweryTableViewController alloc] initWithBreweryID:nil] autorelease];
		btvc.delegate=self;
		[btvc setEditing:YES animated:NO];
		[nc pushViewController:btvc animated:NO];
	}
	else if (self.searchTypes == BeerCrushSearchTypePlaces)
	{
		PlaceTableViewController* ptvc=[[[PlaceTableViewController alloc] initWithPlaceID:nil] autorelease];
		ptvc.delegate=self;
		[ptvc setEditing:YES animated:NO];
		[nc pushViewController:ptvc animated:NO];
	}
	
	[self.navigationController presentModalViewController:nc animated:YES];
}

//#pragma mark UIActionSheetDelegate methods
//
//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//	if (actionSheet.cancelButtonIndex==buttonIndex)
//		return;
//	
//	UIViewController* vc=[[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
//	
//	switch (buttonIndex) 
//	{
//		case 0: // Add a brewery
//		{
//			BreweryTableViewController* btvc=[[[BreweryTableViewController alloc] initWithBreweryID:nil] autorelease];
//			btvc.delegate=self;
//			[btvc setEditing:YES animated:NO];
//			[nc pushViewController:btvc animated:NO];
//			break;
//		}
//		case 1: // Add a beer
//		{
//			BeerTableViewController* btvc=[[[BeerTableViewController alloc] initWithBeerID:nil] autorelease];
//			btvc.delegate=self;
//			[btvc setEditing:YES animated:NO];
//			[nc pushViewController:btvc animated:NO];
//			break;
//		}
//		default:
//			break;
//	}
//	
//	[self.navigationController presentModalViewController:nc animated:YES];
//}

#pragma mark BreweryVCDelegate methods

-(void)breweryVCDidFinishEditing:(BreweryTableViewController*)btvc
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)breweryVCDidCancelEditing:(BreweryTableViewController*)btvc
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark PlaceVCDelegate methods

-(void)placeVCDidFinishEditing:(PlaceTableViewController*)placeVC
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)placeVCDidCancelEditing:(PlaceTableViewController*)placeVC
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

@end


//
//  SearchVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 10/1/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import "SearchVC.h"
#import "BeerCrushAppDelegate.h"
#import "JSON.h"
#import "MyTableViewController.h"

@implementation SearchVC

@synthesize logoView;
@synthesize autoCompleteTVC;
@synthesize searchTypes;
@synthesize resultsList;
@synthesize searchBar;
@synthesize performedSearchQuery;
@synthesize insets;

-(id)init
{
    if (self = [super initWithNibName:nil bundle:nil])
	{
		self.logoView=[[[LogoVC alloc] initWithNibName:@"LogoVC" bundle:nil] autorelease];
		self.searchBar=[[UISearchBar alloc] initWithFrame:CGRectZero];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
	}
	return self;
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	if ([self isViewLoaded]==NO)
	{
		self.navigationItem.hidesBackButton=YES;
		
		// Put Logo View up
		self.logoView.myNC=self.navigationController;
		self.view=logoView.view;
		//	[self.navigationController pushViewController:logoView animated:NO];
		
		if (self.searchTypes==(BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
			self.searchBar.placeholder=@"Beers, brewers, etc.";
		else if (self.searchTypes==BeerCrushSearchTypePlaces)
			self.searchBar.placeholder=@"Pubs, restaurants, bars, stores, etc.";
		
		self.searchBar.autocorrectionType=UITextAutocorrectionTypeNo;
		
		self.searchBar.delegate=self;
		[self.searchBar sizeToFit];
		[self.navigationController.navigationBar addSubview:self.searchBar];
	}
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	searchBar.hidden=NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self.logoView release];
	[self.searchBar release];
    [super dealloc];
}


-(void)autocomplete:(NSString*)qs 
{
	self.performedSearchQuery=NO;
	
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
		[self performSelectorOnMainThread:@selector(myReloadData) withObject:nil waitUntilDone:NO];
	}
	else
	{
		//		[appDelegate alertUser:@"Search failed"];
	}
}

-(void)myReloadData
{
	UITableView* tv;
	if ([self.view isKindOfClass:[UITableView class]])
		tv=(UITableView*)self.view;
	else
	{
		tv=[[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
		tv.delegate=self;
		tv.dataSource=self;
		self.view=tv;
	}
	
	[tv reloadData];

//	if (self.autoCompleteTVC==nil)
//	{
//		self.autoCompleteTVC=[[[AutoCompleteTVC alloc] init] autorelease];
//	}
//	
//	if (self.navigationController.topViewController!=self.autoCompleteTVC)
//	{
//		// Put up a TableViewController to display results
//		[self.navigationController pushViewController:self.autoCompleteTVC animated:NO];
//	}

//	self.autoCompleteTVC.resultsList=self.resultsList;
//	[self.autoCompleteTVC.tableView setContentInset:self.insets];
//	[self.autoCompleteTVC.tableView setScrollIndicatorInsets:self.insets];
//	[self.autoCompleteTVC.tableView reloadData];

}


-(void)query:(NSString*)qs 
{
	self.performedSearchQuery=YES;
	
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
	
	[self.resultsList removeAllObjects];
	
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
	[self performSelectorOnMainThread:@selector(myReloadData) withObject:nil waitUntilDone:NO];
	
	[appDelegate dismissActivityHUD];
	
}

-(void)keyboardWillShow:(NSNotification*)notification
{
//	// Resize the tableview so that it isn't obscured by the keyboard
//	CGRect bounds=[[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
//	CGPoint center=[[[notification userInfo] objectForKey:UIKeyboardCenterEndUserInfoKey] CGPointValue];
//	
//	CGRect keyboardFrame=CGRectMake(round(center.x - bounds.size.width/2.0), round(center.y - bounds.size.height/2.0), bounds.size.width, bounds.size.height);
//	CGRect tableViewFrame=[self.view.window convertRect:self.view.frame fromView:self.view.superview];
//	DLog(@"self.view=%p",self.view);
//	DLog(@"self.view.window=%p",self.view.window);
//	DLog(@"self.view.frame=%@",self.view.frame);
//	DLog(@"self.view.superview=%@",self.view.superview);
//	CGRect tableViewFrame=[self.view convertRect:self.view.frame fromView:self.view.superview];
//	DLog(@"tableViewFrame=%@",tableViewFrame);
	
//	CGRect intersectionFrame=CGRectIntersection(tableViewFrame, keyboardFrame);
	
//	self.insets=UIEdgeInsetsMake(0, 0, intersectionFrame.size.height, 0);
		
//		[self.autoCompleteTVC.tableView setContentInset:insets];
//		[self.autoCompleteTVC.tableView setScrollIndicatorInsets:insets];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
	if (self.autoCompleteTVC)
	{
		// Resize the tableview back to normal
		[self.autoCompleteTVC.tableView setContentInset:UIEdgeInsetsZero];
		[self.autoCompleteTVC.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
	}
}

#pragma mark UISearchBarDelegate methods

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
		//		self.view.hidden=YES;
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
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(query:) object:bar.text withActivityHUD:YES andActivityHUDText:NSLocalizedString(@"HUD:Searching",@"Searching")];
	}
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)bar
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)bar
{
//	UIView* tmp=[[[UIView alloc] initWithFrame:CGRectZero] autorelease];
//	tmp.backgroundColor=[UIColor redColor];
//	self.view=tmp;
	self.view=logoView.view;

	[bar endEditing:YES];
    bar.text = @"";
	
	[self.resultsList removeAllObjects];
	
	[bar setShowsCancelButton:NO animated:YES];
//	if (self.autoCompleteTVC)
//		[self.autoCompleteTVC.tableView reloadData];
//	if (self.navigationController.topViewController==self.autoCompleteTVC)
//		[self.navigationController popViewControllerAnimated:NO];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.performedSearchQuery)  // It's a real query
	{
		DLog(@"numberOfRowsInSection=%d",[self.resultsList count]+1);
		return [self.resultsList count]+1;
	}
	else
	{
		DLog(@"numberOfRowsInSection=%d",[self.resultsList count]);
		return [self.resultsList count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	/* 
	 Because the requests to the server are done asynchronously, we could return a different value
	 from numberOfRowsInSection than we now have in self.resultsList. We may not have a row to return if the resultsList is 
	 smaller than what the iPhone thinks it should be. So we *always* return a cell, even if it's empty.
	 */
	
	if ((indexPath.row >= [self.resultsList count]))
	{ // Show the Add a [Brewery|Place] row
		if (self.performedSearchQuery)
		{
			static NSString *CellIdentifier = @"AddNewItemCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			}
			
			//			if (self.searchTypes == BeerCrushSearchTypePlaces)
			if (NO)
				[cell.textLabel setText:NSLocalizedString(@"Missing Place?",@"Missing place? Add it.")];
			else
			{
				[cell.textLabel setText:NSLocalizedString(@"Missing Brewery?",@"Missing brewery? Add it.")];
				[cell.detailTextLabel setText:NSLocalizedString(@"Missing Brewery? Subtitle",@"(add beers on the brewery's beer list page)")];
			}
			
			UIButton* addButton=[UIButton buttonWithType:UIButtonTypeContactAdd];
			addButton.frame=CGRectMake(0, 0, 30, 30);
			[addButton addTarget:self action:@selector(addBeerOrBreweryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
			
			cell.accessoryView=addButton;
		}
	}
	else 
	{
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewController* tvc=nil;
	NSString* idstr=[[self.resultsList objectAtIndex:indexPath.row] objectForKey:@"id"];
	if ([[idstr substringToIndex:5] isEqualToString:@"beer:"])
	{ // Beer
		tvc=[[[BeerTableViewController alloc] initWithBeerID:idstr] autorelease];
	}
	else if ([[idstr substringToIndex:6] isEqualToString:@"place:"])
	{ // Place
		tvc=[[[PlaceTableViewController alloc] initWithPlaceID:idstr] autorelease];
	}
	else if ([[idstr substringToIndex:8] isEqualToString:@"brewery:"])
	{ // Brewery
		tvc=[[[BreweryTableViewController alloc] initWithBreweryID:idstr] autorelease];
	}

	if (tvc)
	{
		searchBar.hidden=YES;
		[self.navigationController pushViewController:tvc animated:YES];
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


@end

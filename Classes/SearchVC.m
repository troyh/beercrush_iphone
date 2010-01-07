//
//  SearchVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 10/1/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import "SearchVC.h"
#import "BeerCrushAppDelegate.h"
#import "BeerTableViewController.h"
#import "JSON.h"

@implementation SearchVC

@synthesize logoView;
@synthesize searchTypes;
@synthesize searchText;
@synthesize autocompleteZeroResults;
@synthesize delegate;
@synthesize searchResultsList;
@synthesize autocompleteResultsList;
@synthesize totalResultCount;
@synthesize searchBar;
@synthesize performedSearchQuery;
@synthesize isPerformingAsyncQuery;
@synthesize insets;

enum {
	kTagBreweryNameLabel=1,
	kTagAddressLabel,
	kTagTitleLabel
};

-(id)init
{
    if (self = [super initWithNibName:nil bundle:nil])
	{
		self.logoView=[[[LogoVC alloc] initWithNibName:@"LogoVC" bundle:nil] autorelease];
		self.searchBar=[[UISearchBar alloc] initWithFrame:CGRectZero];
		self.searchBar.showsCancelButton=NO;
		self.searchBar.tintColor=[UIColor beercrushTanColor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
	}
	return self;
}

-(NSObject*)navigationRestorationData
{
	return [NSNumber numberWithInt:self.searchTypes];
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
		
		if (self.searchTypes==(BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
			self.searchBar.placeholder=@"Beers and Breweries";
		else if (self.searchTypes==BeerCrushSearchTypePlaces)
			self.searchBar.placeholder=@"Bars, Brewpubs, Restaurants, Stores, etc.";
		
		self.searchBar.autocorrectionType=UITextAutocorrectionTypeNo;
		
		self.searchBar.hidden=YES;
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
	self.searchBar.hidden=NO;
}
/*
-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.searchBar.hidden=NO;
}
*/
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.searchBar.hidden=YES;
}
/*
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	self.searchBar.hidden=YES;
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


- (void)dealloc {
	[self.logoView release];
	[self.searchBar release];
	[self.searchResultsList release];
	[self.autocompleteResultsList release];
    [super dealloc];
}


-(void)autocomplete:(NSString*)qs 
{
	self.performedSearchQuery=NO;
	
	// If this is just a longer version a query that generated zero results, don't bother doing another query (ticket #64)
	if  (self.autocompleteZeroResults==nil || [qs hasPrefix:self.autocompleteZeroResults]==NO)
	{
		if (self.autocompleteResultsList==nil)
			self.autocompleteResultsList=[[NSMutableArray alloc] initWithCapacity:10];
		else
			[self.autocompleteResultsList removeAllObjects];
		
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
			// [answer bytes] is not null-terminated, so we have to make sure we don't go beyond the length of the data
			char* p=(char*)[answer bytes];
			NSUInteger plen=[answer length];
			DLog(@"answer length=%d",plen);
			char* pend=p+plen;

			while (p && *p && (p < pend))
			{
				char* nl=memchr(p, '\n', pend-p);
				if (nl)
				{
					*nl='\0'; // null-terminate it (I hope it's okay to modify an NSData's data!)
					[self.autocompleteResultsList addObject:[NSString stringWithCString:p encoding:NSUTF8StringEncoding]];
					p=nl+1;
				}
				else
					p=nil;
			}
			DLog(@"%d results",[self.autocompleteResultsList count]);
			
			if ([self.autocompleteResultsList count]==0)
			{
				// Remember the text that generated zero results
				self.autocompleteZeroResults=qs;
			}
			else
				self.autocompleteZeroResults=nil;
			
			[self performSelectorOnMainThread:@selector(myReloadData) withObject:nil waitUntilDone:NO];
		}
		else
		{
			//		[appDelegate alertUser:@"Search failed"];
		}
	}
	
	self.isPerformingAsyncQuery=NO;
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
}


-(void)query
{
	self.performedSearchQuery=YES;
	
	// Send the query off to the server
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	const char* dataset="";
	if (self.searchTypes == (BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
		dataset="beer brewery";
	else if (self.searchTypes == BeerCrushSearchTypeBreweries)
		dataset="brewery";
	else if (self.searchTypes == BeerCrushSearchTypeBeers)
		dataset="beer";
	else if (self.searchTypes == BeerCrushSearchTypePlaces)
		dataset="place";

	NSURL* url=[NSURL URLWithString:[[NSString stringWithFormat:BEERCRUSH_API_URL_SEARCH_QUERY, self.searchText, dataset, [self.searchResultsList count]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSData* answer=nil;
	NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
	
	if ([response statusCode]==200)
	{
		NSString* s=[[[NSString alloc] initWithData:answer encoding:NSUTF8StringEncoding] autorelease];
		NSDictionary* results=[s JSONValue];
		if (self.searchResultsList==nil)
			self.searchResultsList=[[NSMutableArray alloc] initWithCapacity:100];
		[self.searchResultsList addObjectsFromArray:[[results objectForKey:@"response"] objectForKey:@"docs"]];
		self.totalResultCount=[[[results objectForKey:@"response"] objectForKey:@"numFound"] unsignedIntValue];
		DLog(@"%d Results:%@",self.totalResultCount,results);
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
	[self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
	[self.searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)text
{
	if (text.length)
	{
		// TODO: set a timer so we don't do this too quickly in succession as the user types fast
		
		@synchronized(self)
		{
			if (self.isPerformingAsyncQuery==NO)
			{
				BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
				[appDelegate performAsyncOperationWithTarget:self selector:@selector(autocomplete:) object:text requiresUserCredentials:NO activityHUDText:nil];
				self.isPerformingAsyncQuery=YES;
			}
		}
	}
	else
	{
		[self.autocompleteResultsList removeAllObjects];
		[self.searchResultsList removeAllObjects];
		self.totalResultCount=0;
		self.searchText=nil;
		[self myReloadData];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
	self.searchText=nil;
	[self.autocompleteResultsList removeAllObjects];
	[self.searchResultsList removeAllObjects];
	self.totalResultCount=0;
	
	if (bar.text.length)
	{
		[bar endEditing:YES];
		[bar resignFirstResponder];
		
		self.searchText=bar.text;
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(query) object:nil requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"HUD:Searching",@"Searching")];
	}
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)bar
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)bar
{
	self.view=logoView.view;

	[bar endEditing:YES];
    bar.text = @"";
	
	self.searchText=nil;
	[self.searchResultsList removeAllObjects];
	self.totalResultCount=0;
}

#pragma mark Events

-(void)addBeerOrBreweryButtonClicked:(id)sender
{
	UIViewController* vc=nil;
	
	if (self.searchTypes & (BeerCrushSearchTypeBeers | BeerCrushSearchTypeBreweries))
	{
		BreweryTableViewController* btvc=[[[BreweryTableViewController alloc] initWithBreweryID:nil] autorelease];
		btvc.delegate=self;
		[btvc setEditing:YES animated:NO];
		vc=btvc;
	}
	else if (self.searchTypes == BeerCrushSearchTypePlaces)
	{
		PlaceTableViewController* ptvc=[[[PlaceTableViewController alloc] initWithPlaceID:nil] autorelease];
		ptvc.delegate=self;
		[ptvc setEditing:YES animated:NO];
		vc=ptvc;
	}
	else {
		return; // Can't continue and present a view controller
	}
	
	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	nc.navigationBar.tintColor=[UIColor beercrushTanColor];
	[self.navigationController presentModalViewController:nc animated:YES];
}

-(void)newBreweryPanelClose
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark BreweryVCDelegate methods

-(void)breweryVCDidFinishEditing:(BreweryTableViewController*)btvc
{
	if (self.navigationController.modalViewController) // If modal, give the user a Close button
		[btvc.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close",@"New Brewery Page: Close button title") style:UIBarButtonItemStyleDone target:self action:@selector(newBreweryPanelClose)] autorelease]];
	else // Not modal, dismiss it automatically
		[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)breweryVCDidCancelEditing:(BreweryTableViewController*)btvc
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark PlaceVCDelegate methods

-(void)placeVCDidFinishEditing:(PlaceTableViewController*)placeVC
{
	placeVC.editing=NO;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)placeVCDidCancelEditing:(PlaceTableViewController*)placeVC
{
	placeVC.editing=NO;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.performedSearchQuery)
		return tableView.rowHeight;
	return 30; // Autocomplete row height
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.performedSearchQuery)  // It's a real query
	{
		DLog(@"numberOfRowsInSection=%d",[self.searchResultsList count]+1);
		return [self.searchResultsList count]+([self.searchResultsList count]<self.totalResultCount?1:0)+([self.searchText length]?1:0);
	}
	else
	{
		DLog(@"numberOfRowsInSection=%d",[self.autocompleteResultsList count]);
		return [self.autocompleteResultsList count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	/* 
	 Because the requests to the server are done asynchronously, we could return a different value
	 from numberOfRowsInSection than we now have in self.resultsList. We may not have a row to return if the resultsList is 
	 smaller than what the iPhone thinks it should be. So we *always* return a cell, even if it's empty.
	 */
	
	UITableViewCell* cell=nil;
	
	if (self.performedSearchQuery)
	{
		if ((indexPath.row >= [self.searchResultsList count]))
		{ 
			if (indexPath.row == [self.searchResultsList count] && [self.searchResultsList count] < self.totalResultCount)
			{ // Make the "Get more results..." cell
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
				[cell.textLabel setText:NSLocalizedString(@"More Results...",@"Search: Get More Results")];
			}
			else
			{
				// Show the Add a [Brewery|Place] row
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
		}
		else 
		{
			static NSString *CellIdentifier = @"Cell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

				UILabel* breweryNameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(45, 1, 260, 8)] autorelease];
				breweryNameLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
				breweryNameLabel.textColor=[UIColor grayColor];
				breweryNameLabel.tag=kTagBreweryNameLabel;
				[cell.contentView addSubview:breweryNameLabel];

				UILabel* titleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(45, 9, 260, 20)] autorelease];
				[titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
				titleLabel.tag=kTagTitleLabel;
				[cell.contentView addSubview:titleLabel];
				
				UILabel* addressLabel=[[[UILabel alloc] initWithFrame:CGRectMake(45, 30, 260, 14)] autorelease];
				addressLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
				addressLabel.textColor=[UIColor grayColor];
				addressLabel.tag=kTagAddressLabel;
				[cell.contentView addSubview:addressLabel];
			}

			UILabel* breweryNameLabel=(UILabel*)[cell.contentView viewWithTag:kTagBreweryNameLabel];

			NSDictionary* beer=[self.searchResultsList objectAtIndex:indexPath.row];
			UILabel* titleLabel=(UILabel*)[cell.contentView viewWithTag:kTagTitleLabel];
			[titleLabel setText:[beer objectForKey:@"name"]];
			
			NSString* idstr=[beer objectForKey:@"id"];
			if ([[idstr substringToIndex:5] isEqualToString:@"beer:"])
			{ // Beer
				[breweryNameLabel setText:[[beer objectForKey:@"brewery"] objectForKey:@"name"]];
				cell.imageView.image=[UIImage imageNamed:@"beer.png"];
			}
			else if ([[idstr substringToIndex:6] isEqualToString:@"place:"])
			{ // Place
				UILabel* addressLabel=(UILabel*)[cell.contentView viewWithTag:kTagAddressLabel];

				if ([beer objectForKey:@"address_city"] && [beer objectForKey:@"address_state"])
				{
					[addressLabel setText:[NSString stringWithFormat:@"%@, %@",
											   [beer objectForKey:@"address_city"],
											   [beer objectForKey:@"address_state"]
											   ]];
				}
				else if ([beer objectForKey:@"address_state"])
				{
					[addressLabel setText:[beer objectForKey:@"address_state"]];
				}
				else if ([beer objectForKey:@"address_city"])
				{
					[addressLabel setText:[beer objectForKey:@"address_city"]];
				}
				else
					[addressLabel setText:@""];

				if ([[beer objectForKey:@"placetype"] isEqualToString:@"Store"])
					cell.imageView.image=[UIImage imageNamed:@"store.png"];
				else if ([[beer objectForKey:@"placetype"] isEqualToString:@"Bar"])
					cell.imageView.image=[UIImage imageNamed:@"bar.png"];
				else if ([[beer objectForKey:@"placetype"] isEqualToString:@"Brewpub"])
					cell.imageView.image=[UIImage imageNamed:@"brewpub.png"];
				else
					cell.imageView.image=[UIImage imageNamed:@"restaurant.png"];
			}
			else if ([[idstr substringToIndex:8] isEqualToString:@"brewery:"])
			{ // Brewery
				[breweryNameLabel setText:@""];
				cell.imageView.image=[UIImage imageNamed:@"brewery.png"];
			}
			
			cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else // Autocomplete result cell
	{
		static NSString *CellIdentifier = @"AutoCompleteCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		if (indexPath.row < [self.autocompleteResultsList count])
		{
			NSString* result=[self.autocompleteResultsList objectAtIndex:indexPath.row];
			[cell.textLabel setText:result];
		}
		
		[cell.textLabel setFont:[UIFont systemFontOfSize:16]];
		[cell.textLabel setTextColor:[UIColor beercrushBlueColor]];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (self.performedSearchQuery)
	{
		if (indexPath.row < [self.searchResultsList count])
		{
			NSString* idstr=[[self.searchResultsList objectAtIndex:indexPath.row] objectForKey:@"id"];
			[self navigateBasedOnDocumentID:idstr];
		}
		else if (indexPath.row == [self.searchResultsList count] && [self.searchResultsList count] < self.totalResultCount)
		{
			BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			[appDelegate performAsyncOperationWithTarget:self selector:@selector(query) object:nil requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"HUD:Searching",@"Searching")];
		}
		else 
		{
			[self addBeerOrBreweryButtonClicked:nil];
		}
	}
	else // Autocomplete result cell, do a search on the text in the cell
	{
		NSString* result=[self.autocompleteResultsList objectAtIndex:indexPath.row];
		self.searchBar.text=result;
		self.searchText=result;
		
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(query) object:nil requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"HUD:Searching",@"Searching")];
	}
}

-(BOOL)navigateBasedOnDocumentID:(NSString*)idstr
{
	UIViewController* vc=nil;
	if ([[idstr substringToIndex:5] isEqualToString:@"beer:"])
	{ // Beer
		vc=[[[BeerTableViewController alloc] initWithBeerID:idstr] autorelease];
	}
	else if ([[idstr substringToIndex:6] isEqualToString:@"place:"])
	{ // Place
		PlaceTableViewController* ptvc=[[[PlaceTableViewController alloc] initWithPlaceID:idstr] autorelease];
		ptvc.delegate=self;
		vc=ptvc;
	}
	else if ([[idstr substringToIndex:8] isEqualToString:@"brewery:"])
	{ // Brewery
		vc=[[[BreweryTableViewController alloc] initWithBreweryID:idstr] autorelease];
	}
	
	if (vc==nil)
		return NO;
	
	if (self.delegate==nil || [self.delegate searchVC:self didSelectSearchResult:idstr]==YES)
	{
		[self.navigationController pushViewController:vc animated:YES];
	}
	
	return YES;
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

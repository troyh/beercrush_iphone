//
//  MyTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyTableViewController.h"
#import "BreweryTableViewController.h"
#import "BeerTableViewController.h"
#import "PlaceTableViewController.h"


//@interface SearchResultObject : NSObject
//{
//	NSString* title;
//	NSString* desc;
//	ResultType type;
//	NSString* uri;
//}
//
//@property (nonatomic, retain) NSString* title;
//@property (nonatomic, retain) NSString* desc;
//@property (nonatomic) ResultType type;
//@property (nonatomic, retain) NSString* uri;
//
//-(id)initWithTitle:(NSString*)title desc:(NSString*)desc type:(ResultType)t uri:(NSString*)uri;
//
//@end
//
//@implementation SearchResultObject
//
//@synthesize title;
//@synthesize desc;
//@synthesize type;
//@synthesize uri;
//
//-(id)initWithTitle:(NSString*)t desc:(NSString*)d type:(ResultType)n uri:(NSString*)u
//{
//	self.title=t;
//	self.desc=d;
//	self.type=n;
//	self.uri=u;
//	return self;
//}
//
//-(BOOL)isEqualToString:(NSString*)s
//{
//	return NO;
//}
//
//-(id)copyWithZone
//{
//	return self;
//}
//
//@end

@implementation MyTableViewController

@synthesize searchBar;
@synthesize autoCompleteResultsData;
@synthesize autoCompleteResultsCount;

-(void)query:(NSString*)qs 
{
	self.autoCompleteResultsCount=0;
	self.autoCompleteResultsData=nil;
	
	// Send the query off to the server
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_AUTOCOMPLETE_QUERY, qs ]];
	self.autoCompleteResultsData=[[NSData dataWithContentsOfURL:url] retain];

	char* p=(char*)[autoCompleteResultsData bytes];
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
				p=nl+1;
				++self.autoCompleteResultsCount;
			}
		}
	}
	DLog(@"%d results",self.autoCompleteResultsCount);
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
	self.searchBar.placeholder=@"Beers, brewers, etc.";
	self.searchBar.delegate=self;
	[self.searchBar sizeToFit];
	[self.navigationController.navigationBar addSubview:self.searchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	searchBar.hidden=NO; // Put searchbar back
//	[searchBar becomeFirstResponder];
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
		[self query:searchText];
	}
	else
	{
		self.autoCompleteResultsData=nil;
		self.autoCompleteResultsCount=0;
	}
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
	if (bar.text.length)
	{
		[bar resignFirstResponder];
		
		[self query:bar.text];
		[self.tableView reloadData];
	}
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)bar
{
}

//-(BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
//{
//	return YES;
//}

- (void)searchBarCancelButtonClicked:(UISearchBar *)bar
{
    [bar resignFirstResponder];
    bar.text = @"";
	self.autoCompleteResultsData=nil;
	self.autoCompleteResultsCount=0;
	[self.tableView reloadData];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return autoCompleteResultsCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	const char* p=(char*)[autoCompleteResultsData bytes];
	NSUInteger n=0;
	while (p && n<indexPath.row && n<autoCompleteResultsCount)
	{	// Count the number of items
		char* tab=strchr(p,'\0');
		if (!tab)
			p=nil; // Quit
		else
		{
			const char* nl=strchr(tab+1, '\0');
			if (!nl)
				p=nil; // Quit
			else
			{
				p=nl+1;
				++n;
			}
		}
	}
	if (p)
	{
		[cell.textLabel setText:[NSString stringWithCString:p encoding:NSASCIIStringEncoding]];
		if (!strncmp(p+strlen(p)+1,"beer:",5))
		{ // Beer
			[cell.imageView initWithImage:[UIImage imageNamed:@"beer.png"]];
		}
		else if (!strncmp(p+strlen(p)+1,"place:",6))
		{ // Place
			[cell.imageView initWithImage:[UIImage imageNamed:@"restaurant.png"]];
		}
		else if (!strncmp(p+strlen(p)+1,"brewery:",8))
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
	[searchBar resignFirstResponder];
	
	const char* p=(char*)[autoCompleteResultsData bytes];
	NSUInteger n=0;
	while (p && n<indexPath.row && n<autoCompleteResultsCount)
	{	// Count the number of items
		char* tab=strchr(p,'\0');
		if (!tab)
			p=nil; // Quit
		else
		{
			const char* nl=strchr(tab+1, '\0');
			if (!nl)
				p=nil; // Quit
			else
			{
				p=nl+1;
				++n;
			}
		}
	}
	if (p)
	{
		ResultType t=Brewer;
		const char* idp=p+strlen(p)+1;
		if (!strncmp(idp,"beer:",5))
			t=Beer;
		else if (!strncmp(idp,"brewery:",8))
			t=Brewer;
		else if (!strncmp(idp, "place:", 6))
			t=Place;
		
		if (t == Brewer)
		{
			BreweryTableViewController* btvc=[[BreweryTableViewController alloc] initWithBreweryID:[NSString stringWithCString:idp]];
			[self.navigationController pushViewController: btvc animated:YES];
			[btvc release];
		}
		else if (t == Beer)
		{
			BeerTableViewController* btvc=[[BeerTableViewController alloc] initWithBeerID: [NSString stringWithCString:idp]];
			[self.navigationController pushViewController:btvc animated:YES];
			[btvc release];
		}
		else if (t == Place)
		{
			PlaceTableViewController* btvc=[[PlaceTableViewController alloc] initWithPlaceID: [NSString stringWithCString:idp]];
			[self.navigationController pushViewController: btvc animated:YES];
			[btvc release];
		}
	}
		
//	ResultType t=[[searchResultsList_type objectAtIndex:indexPath.row] intValue];
	
	
//	UIViewController *anotherViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
//
//	// Make the background view
//	UIView* backgroundView=[[UIView alloc] initWithFrame: app.keyWindow.frame];
//	backgroundView.backgroundColor=[UIColor groupTableViewBackgroundColor];
//	anotherViewController.title=@"Beer";
//	[anotherViewController.view addSubview:backgroundView];
//
//	
//	[appdel.nav pushViewController:anotherViewController animated:YES];
//	[anotherViewController release];

//	CGRect f;
//	// Make the title
//	f=CGRectZero;
//	f.origin.y=0;
//	f.origin.x=100;
//	f.size.width=app.keyWindow.frame.size.width-100-10;
//	f.size.height=80;
//	UILabel* title=[[UILabel alloc] initWithFrame:f];
////	title.adjustsFontSizeToFitWidth=YES;
//	title.font=[UIFont boldSystemFontOfSize:20];
//	title.minimumFontSize=2.0;
//	title.numberOfLines=3;
//	title.text=[searchResultsList_title objectAtIndex:indexPath.row];
//
//	// Make the Description label view
//	f=CGRectZero;
//	f.origin.y=100;
//	f.origin.x=10;
//	f.size.width=app.keyWindow.frame.size.width-10-10;
//	f.size.height=200;
//	UILabel* desc=[[UILabel alloc] initWithFrame:f];
//	desc.numberOfLines=10;
//	desc.text=[searchResultsList_desc objectAtIndex: indexPath.row];
//
//
//	[anotherViewController.view addSubview:title];
//	[anotherViewController.view addSubview:desc];
	
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
	[autoCompleteResultsData release];
    [super dealloc];
}


@end


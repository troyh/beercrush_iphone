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

@synthesize app;
@synthesize appdel;
@synthesize currentElemValue;
@synthesize bInResultElement;
@synthesize autoCompleteResultsData;
@synthesize autoCompleteResultsCount;

-(void)query:(NSString*)qs 
{
	self.title=@"Search";

//	if (searchResultsList_title)
//		[searchResultsList_title release];
//	if (searchResultsList_desc)
//		[searchResultsList_desc release];
//	if (searchResultsList_type)
//		[searchResultsList_type release];
//	if (searchResultsList_id)
//		[searchResultsList_id release];
//	
//	searchResultsList_title=[[NSMutableArray alloc] initWithCapacity:10];
//	searchResultsList_desc=[[NSMutableArray alloc] initWithCapacity:10];
//	searchResultsList_type=[[NSMutableArray alloc] initWithCapacity:10];
//	searchResultsList_id=[[NSMutableArray alloc] initWithCapacity:10];
	
	self.autoCompleteResultsCount=0;
	[self.autoCompleteResultsData release];
	
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
	
//	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
//	[parser setDelegate:self];
//	BOOL parse_ok=[parser parse];
//	if (parse_ok==NO)
//	{
//		NSError* err=[parser parserError];
//		UIAlertView* vw=[[UIAlertView alloc] initWithTitle:@"Oops" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//		[vw show];
//		[vw release];
//	}
//	[parser release];
	
	// Get results back
	
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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	// TODO: free any search results
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
			[cell.imageView initWithImage:[UIImage imageNamed:@"star_filled.png"]];
		}
		else if (!strncmp(p+strlen(p)+1,"place:",6))
		{ // Place
			[cell.imageView initWithImage:[UIImage imageNamed:@"dot.png"]];
		}
		else if (!strncmp(p+strlen(p)+1,"brewery:",8))
		{ // Brewery
			[cell.imageView initWithImage:[UIImage imageNamed:@"dot.png"]];
		}
		
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

	appdel.mySearchBar.hidden=YES;
	appdel.nav.view.frame=app.keyWindow.frame;
	appdel.nav.navigationBarHidden=NO;

	
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
			BreweryTableViewController* btvc=[[BreweryTableViewController alloc] initWithBreweryID:[NSString stringWithCString:idp] app:app appDelegate: appdel];
			[appdel.nav pushViewController: btvc animated:YES];
			[btvc release];
		}
		else if (t == Beer)
		{
			BeerTableViewController* btvc=[[BeerTableViewController alloc] initWithBeerID: [NSString stringWithCString:idp] app:app appDelegate: appdel];
			[appdel.nav pushViewController: btvc animated:YES];
			[btvc release];
		}
		else if (t == Place)
		{
			PlaceTableViewController* btvc=[[PlaceTableViewController alloc] initWithPlaceID: [NSString stringWithCString:idp] app:app appDelegate: appdel];
			[appdel.nav pushViewController: btvc animated:YES];
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
//	[searchResultsList_title release];
//	[searchResultsList_desc release];
//	[searchResultsList_type release];
//	[searchResultsList_id release];
	[autoCompleteResultsData release];
    [super dealloc];
}

// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	self.currentElemValue=nil;
	bInResultElement=NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"result"])
	{
		bInResultElement=YES;
	}
	else if (bInResultElement && ([elementName isEqualToString:@"text"] || [elementName isEqualToString:@"id"]))
	{
		self.currentElemValue=[NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//	if (self.currentElemValue)
//	{
//		if ([elementName isEqualToString:@"result"])
//		{
//			bInResultElement=NO;
//		}
//		else if (bInResultElement)
//		{
//			if ([elementName isEqualToString:@"text"])
//				[searchResultsList_title addObject:currentElemValue];
//			else if ([elementName isEqualToString:@"id"])
//				[searchResultsList_id addObject:currentElemValue];
//		}
//		
//		self.currentElemValue=nil;
//	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.currentElemValue)
	{
		[self.currentElemValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}


@end


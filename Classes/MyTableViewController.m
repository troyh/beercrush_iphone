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

-(void)query:(NSString*)qs 
{
	self.title=@"Places";

	if (searchResultsList_title)
		[searchResultsList_title release];
	if (searchResultsList_desc)
		[searchResultsList_desc release];
	if (searchResultsList_type)
		[searchResultsList_type release];
	if (searchResultsList_id)
		[searchResultsList_id release];
	
	searchResultsList_title=[[NSMutableArray alloc] initWithCapacity:10];
	searchResultsList_desc=[[NSMutableArray alloc] initWithCapacity:10];
	searchResultsList_type=[[NSMutableArray alloc] initWithCapacity:10];
	searchResultsList_id=[[NSMutableArray alloc] initWithCapacity:10];
	
	// TODO: Send the query off to the server
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_AUTOCOMPLETE_QUERY, qs ]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	
	// Get results back

	
//	[searchResultsList_title addObject:@"Dogfish Head"];
//	[searchResultsList_desc  addObject:@"A brewer in Delaware"];
//	[searchResultsList_type  addObject:[NSNumber numberWithInt:Brewer]];
//	[searchResultsList_id   addObject:@"Dogfish-Head-Craft-Brewery-Milton"];
//
//	[searchResultsList_title addObject:@"North Coast Brewing Co."];
//	[searchResultsList_desc  addObject:@"A brewer in Northern California"];
//	[searchResultsList_type  addObject:[NSNumber numberWithInt:Brewer]];
//	[searchResultsList_id   addObject:@"North-Coast-Brewing-Co"];
//
//	[searchResultsList_title addObject:@"Russian River"];
//	[searchResultsList_desc  addObject:@"A brewery in California"];
//	[searchResultsList_type  addObject:[NSNumber numberWithInt:Brewer]];
//	[searchResultsList_id   addObject:@"Russian-River-Brewing-Co"];

//	[searchResultsList_title addObject:@"Old Rasputin Russian Imperial Stout"];
//	[searchResultsList_desc  addObject:@"An Imperial Stout"];
//	[searchResultsList_type  addObject:[NSNumber numberWithInt:Beer]];
//	[searchResultsList_id   addObject:@"Old-Rasputin"];
	
//	SearchResultObject* obj=[[SearchResultObject alloc] initWithTitle:@"Dogfish Head" desc:@"A brewer in Delaware" type:Brewer uri:@"/xml/brewery/Dogfish-Head" ];
	
//	[searchResultsList addObject: obj ];
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
    return searchResultsList_title.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.text=[searchResultsList_title objectAtIndex:indexPath.row];
	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.

	appdel.mySearchBar.hidden=YES;
	appdel.nav.view.frame=app.keyWindow.frame;
	appdel.nav.navigationBarHidden=NO;
	
//	ResultType t=[[searchResultsList_type objectAtIndex:indexPath.row] intValue];
	ResultType t=Brewer;
	if (t == Brewer)
	{
		BreweryTableViewController* btvc=[[BreweryTableViewController alloc] initWithBreweryID:[searchResultsList_id objectAtIndex:indexPath.row] app:app appDelegate: appdel];
		[appdel.nav pushViewController: btvc animated:YES];
		[btvc release];
	}
	else if (t == Beer)
	{
		BeerTableViewController* btvc=[[BeerTableViewController alloc] initWithBeerID: [searchResultsList_id objectAtIndex:indexPath.row] app:app appDelegate: appdel];
		[appdel.nav pushViewController: btvc animated:YES];
		[btvc release];
	}
	else if (t == Place)
	{
		PlaceTableViewController* btvc=[[PlaceTableViewController alloc] initWithPlaceID: [searchResultsList_id objectAtIndex:indexPath.row] app:app appDelegate: appdel];
		[appdel.nav pushViewController: btvc animated:YES];
		[btvc release];
	}
	
	
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
	[searchResultsList_title release];
	[searchResultsList_desc release];
	[searchResultsList_type release];
	[searchResultsList_id release];
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
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"result"])
		{
			bInResultElement=NO;
		}
		else if (bInResultElement)
		{
			if ([elementName isEqualToString:@"text"])
				[searchResultsList_title addObject:currentElemValue];
			else if ([elementName isEqualToString:@"id"])
				[searchResultsList_id addObject:currentElemValue];
		}
		
		self.currentElemValue=nil;
	}
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


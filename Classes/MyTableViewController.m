//
//  MyTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyTableViewController.h"

typedef enum resultType
	{
		Beer=1,
		Brewer=2
	} ResultType;


@interface SearchResultObject : NSObject
{
	NSString* title;
	NSString* desc;
	ResultType type;
	NSString* uri;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* desc;
@property (nonatomic) ResultType type;
@property (nonatomic, retain) NSString* uri;

-(id)initWithTitle:(NSString*)title desc:(NSString*)desc type:(ResultType)t uri:(NSString*)uri;

@end

@implementation SearchResultObject

@synthesize title;
@synthesize desc;
@synthesize type;
@synthesize uri;

-(id)initWithTitle:(NSString*)t desc:(NSString*)d type:(ResultType)n uri:(NSString*)u
{
	self.title=t;
	self.desc=d;
	self.type=n;
	self.uri=u;
	return self;
}

-(BOOL)isEqualToString:(NSString*)s
{
	return NO;
}

-(id)copyWithZone
{
	return self;
}

@end

@implementation MyTableViewController

@synthesize app;
@synthesize appdel;


-(void)query:(NSString*)qs 
{
	// TODO: Send the query off to the server

	// Get results back
	if (searchResultsList_title)
		[searchResultsList_title release];
	if (searchResultsList_desc)
		[searchResultsList_desc release];
	if (searchResultsList_type)
		[searchResultsList_type release];
	if (searchResultsList_uri)
		[searchResultsList_uri release];

	searchResultsList_title=[[NSMutableArray alloc] initWithCapacity:10];
	searchResultsList_desc=[[NSMutableArray alloc] initWithCapacity:10];
	searchResultsList_type=[[NSMutableArray alloc] initWithCapacity:10];
	searchResultsList_uri=[[NSMutableArray alloc] initWithCapacity:10];
	
	[searchResultsList_title addObject:@"Dogfish Head"];
	[searchResultsList_desc  addObject:@"A brewer in Delaware"];
	[searchResultsList_type  addObject:[NSNumber numberWithInt:Brewer]];
	[searchResultsList_uri   addObject:@"/xml/brewery/Dogfish-Head"];

	[searchResultsList_title addObject:@"North Coast Brewing Co."];
	[searchResultsList_desc  addObject:@"A brewer in Northern California"];
	[searchResultsList_type  addObject:[NSNumber numberWithInt:Brewer]];
	[searchResultsList_uri   addObject:@"/xml/brewery/North-Coast"];

	[searchResultsList_title addObject:@"Pliny the Elder"];
	[searchResultsList_desc  addObject:@"An Imperial IPA"];
	[searchResultsList_type  addObject:[NSNumber numberWithInt:Beer]];
	[searchResultsList_uri   addObject:@"/xml/beer/Pliny-the-Elder"];

	[searchResultsList_title addObject:@"Old Rasputin Russian Imperial Stout"];
	[searchResultsList_desc  addObject:@"An Imperial Stout"];
	[searchResultsList_type  addObject:[NSNumber numberWithInt:Beer]];
	[searchResultsList_uri   addObject:@"/xml/beer/Old-Rasputin"];
	
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
	
	UIViewController *anotherViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];

	// Make the background view
	UIView* backgroundView=[[UIView alloc] initWithFrame: app.keyWindow.frame];
	backgroundView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	anotherViewController.title=@"Beer";
	[anotherViewController.view addSubview:backgroundView];

	appdel.mySearchBar.hidden=YES;
	appdel.nav.view.frame=app.keyWindow.frame;
	appdel.nav.navigationBarHidden=NO;
	
	[appdel.nav pushViewController:anotherViewController animated:YES];
	[anotherViewController release];

	// TODO: get info from server

	CGRect f;
	// Make the title
	f=CGRectZero;
	f.origin.y=0;
	f.origin.x=100;
	f.size.width=app.keyWindow.frame.size.width-100-10;
	f.size.height=80;
	UILabel* title=[[UILabel alloc] initWithFrame:f];
//	title.adjustsFontSizeToFitWidth=YES;
	title.font=[UIFont boldSystemFontOfSize:20];
	title.minimumFontSize=2.0;
	title.numberOfLines=3;
	title.text=[searchResultsList_title objectAtIndex:indexPath.row];

	// Make the Description label view
	f=CGRectZero;
	f.origin.y=100;
	f.origin.x=10;
	f.size.width=app.keyWindow.frame.size.width-10-10;
	f.size.height=200;
	UILabel* desc=[[UILabel alloc] initWithFrame:f];
	desc.numberOfLines=10;
	desc.text=[searchResultsList_desc objectAtIndex: indexPath.row];


	[anotherViewController.view addSubview:title];
	[anotherViewController.view addSubview:desc];
	
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
	[searchResultsList_uri release];
    [super dealloc];
}


@end


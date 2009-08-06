//
//  BeerListTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "BeerListTableViewController.h"


@implementation BeerListTableViewController

@synthesize breweryID;
@synthesize currentElemValue;
@synthesize	currentElemAttribs;
@synthesize beerList;
@synthesize app;
@synthesize btvc;

-(id)initWithBreweryID:(NSString*)brewery_id andApp:(UIApplication*)a
{
	[super initWithStyle:UITableViewStylePlain];
	
	self.breweryID=brewery_id;
	self.app=a;
	self.currentElemAttribs=nil;
	self.currentElemValue=nil;
	self.beerList=nil;
	
	self.title=@"Beer List";
	
	beerList=[[NSMutableArray alloc] initWithCapacity:10];
	
	return self;
}

- (void)dealloc {
//	NSLog(@"currentElemValue retainCount=%d",[self.currentElemValue retainCount]);
//	NSLog(@"currentElemAttribs retainCount=%d",[self.currentElemAttribs retainCount]);
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

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd	target:self action:@selector(newBeerPanel)] autorelease];
}

-(void)newBeerPanel
{
//	UIActionSheet* sheet=[[[UIActionSheet alloc] initWithTitle:@"New Beer" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
//	[sheet showInView:self.tableView];

	UIViewController* vc=[[UIViewController alloc] init];
	UINavigationController* nc=[[UINavigationController alloc] initWithRootViewController:vc];
	
	self.btvc=[[BeerTableViewController alloc] initWithBeerID:nil app:self.app appDelegate:(BeerCrushAppDelegate*)self.app.delegate];
	self.btvc.breweryID=self.breweryID;
	[nc pushViewController:btvc	animated:NO];
	
	// Add cancel and save buttons
	UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(newBeerCancelButtonClicked)] autorelease];
	UIBarButtonItem* saveButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(newBeerSaveButtonClicked)] autorelease];
	[nc.navigationBar.topItem setLeftBarButtonItem:cancelButton animated:NO];
	[nc.navigationBar.topItem setRightBarButtonItem:saveButton animated:NO];
	
	[btvc setEditing:YES animated:NO];
	
	[self presentModalViewController:nc animated:YES];
	
}

-(void)newBeerSaveButtonClicked
{
	[self.btvc setEditing:NO animated:YES];
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)newBeerCancelButtonClicked
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	// Retrieve XML doc from server
	NSArray* idparts=[breweryID componentsSeparatedByString:@":"];
	if ([idparts count]==2) // What we expect
	{
		NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_META_DOC, [idparts objectAtIndex:1]]];
		if (url)
		{
			NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
			[parser setDelegate:self];
			[parser parse];
			[parser release];
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	BeerObject* beer=[beerList objectAtIndex:indexPath.row];
	[cell.textLabel setText:[NSString stringWithFormat:@"%@", [beer.data objectForKey:@"name"] ]];
	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BeerObject* beer=[beerList objectAtIndex:indexPath.row];
	BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)self.app.delegate;
	BeerTableViewController* vc=[[[BeerTableViewController alloc] initWithBeerID:[beer.data valueForKey:@"id"]  app:self.app appDelegate:del] autorelease];

	[del.nav pushViewController:vc animated:YES];
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



// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.currentElemValue release];
	self.currentElemValue=nil;
	
	[self.currentElemAttribs release];
	self.currentElemAttribs=nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"brewery"])
	{
	}
	else if ([elementName isEqualToString:@"beerlist"])
	{
	}
	else if ([elementName isEqualToString:@"item"])
	{
		[self.currentElemValue release];
		self.currentElemValue=nil;
		self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];

		[self.currentElemAttribs release];
		self.currentElemAttribs=[[NSMutableDictionary alloc] initWithCapacity:10];
		[self.currentElemAttribs addEntriesFromDictionary:attributeDict];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"name"])
		{
			BeerObject* beer=[[BeerObject alloc] init];
			[beer.data setObject:self.currentElemValue forKey:@"name"];
			[beer.data setObject:[[[currentElemAttribs objectForKey:@"id"] copy] autorelease] forKey:@"id"];
			
			[beerList addObject:beer];
			[beer release];
		}
		
		[self.currentElemValue release];
		self.currentElemValue=nil;
	}

	[self.currentElemAttribs release];
	self.currentElemAttribs=nil;
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


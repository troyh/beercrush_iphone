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
@synthesize breweryName;
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
		self.breweryName=@"Name of Brewery";
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

	UIViewController* vc=[[UIViewController alloc] init];
	UINavigationController* nc=[[UINavigationController alloc] initWithRootViewController:vc];
	
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
	
	UIViewController* vc=[[UIViewController alloc] init];
	UINavigationController* nc=[[UINavigationController alloc] initWithRootViewController:vc];
	
	BrowseBrewersTVC* bbtvc=[[BrowseBrewersTVC alloc] init];
	[nc pushViewController:bbtvc animated:NO];
	
	// Add cancel buttons
	UIBarButtonItem* cancelButton=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(browseBrewersCancelButtonClicked)] autorelease];
	
	[self presentModalViewController:nc animated:YES];
	// Take the (left) Back button off the navbar
	[nc.navigationBar.topItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectZero]] autorelease] animated:NO];
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
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_MENU_DOC];
	NSString* postdata=[[NSString alloc] initWithFormat:
			 @"place_id=%@&"
			 "add_item=%@",
			 self.placeID,
			 beerID];
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSData* answer=nil;
	[delegate sendRequest:url usingMethod:@"POST" withData:postdata returningData:&answer];

	if (answer)
	{  // Parse the XML doc
		NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
		[parser setDelegate:self];
		[parser parse];
		
		[answer release];
	}
	
	[postdata release];
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
			url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_DOC, [idparts objectAtIndex:1]]];
			
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
			NSData* answer;
			NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
			if ([response statusCode]==200)
			{
				NSXMLParser* parser=[[NSXMLParser alloc] initWithData:answer];
				[parser setDelegate:self];
				[parser parse];
				[parser release];
			}
			[self.tableView reloadData];
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
	
	UILabel* breweryNameLabel=(UILabel*)[cell.contentView viewWithTag:kTagBreweryNameLabel];
	[breweryNameLabel setText:self.breweryName];

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

// Sample brewery doc:
//<?xml version="1.0"?>
//<brewery id="brewery:Dogfish-Head-Craft-Brewery-Milton">
//	<_id>brewery:Dogfish-Head-Craft-Brewery-Milton</_id>
//	<_rev>575642880</_rev>
//	<type>brewery</type>
//	<timestamp>1249416198</timestamp>
//	<name>Dogfish Head Craft Brewery</name>
//	<address>
//		<street>6 Cannery Village Center</street>
//		<city>Milton</city>
//		<state>DE</state>
//		<zip>19968-1328</zip>
//		<latitude>38.771568</latitude>
//		<longitude>-75.311975</longitude>
//		<country>US</country>
//	</address>
//	<phone>(302) 684-1000</phone>
//	<meta>
//		<_id>meta:brewery:Dogfish-Head-Craft-Brewery-Milton</_id>
//		<_rev>1269004365</_rev>
//		<beerlist>
//			<item id="beer:Dogfish-Head-Craft-Brewery-Milton:120-Minute-IPA">
//				<name>120 Minute IPA</name>
//				<description>Too extreme to be called beer? Brewed to a colossal 45-degree plato, boiled for a full 2 hours while being continuously hopped with high-alpha American hops, then dry-hopped daily in the fermenter for a month &amp; aged for another month on whole-leaf hops!!! Our 120 Minute I.P.A. is by far the biggest I.P.A. ever brewed! At 20% abv and 120 ibus you can see why we call this beer THE HOLY GRAIL for hopheads!</description>
//			</item>
//			<item id="beer:Dogfish-Head-Craft-Brewery-Milton:60-Minute-IPA">
//				<name>60 Minute IPA</name>
//				<description>Our flagship beer. A session India Pale Ale brewed with Warrior, Amarillo &amp; 'Mystery Hop X.' A lot of citrusy hop character. THE session beer for beer geeks like us!</description>
//			</item>
//			<item id="beer:Dogfish-Head-Craft-Brewery-Milton:90-Minute-IPA">
//				<name>90 Minute IPA</name>
//				<description>Esquire Magazine calls our 90 Minute .I..PA., "perhaps the best I.P.A. in America."" An Imperial I.P.A. brewed to be savored from a snifter. A big beer with a great malt backbone that stands up to the extreme hopping rate. This beer is an excellent candidate for use with Randall The Enamel Animal!</description>
//			</item>
//		</beerlist>
//		<type>brewery_meta</type>
//	</meta>
//</brewery>

//
// Sample menu doc:
//
//<?xml version="1.0"?>
//<menu>
//	<type>menu</type>
//	<meta>
//		<timestamp>1250019784</timestamp>
//		<mtime>1250022007</mtime>
//	</meta>
//	<items>
//		<item type="beer" id="beer:Dogfish-Head-Craft-Brewery-Milton:90-Minute-IPA" ontap="yes" inbottle="no" oncask="no" price="0">
//			<name>90 Minute IPA</name>
//		</item>
//		<item type="beer" id="beer:Dogfish-Head-Craft-Brewery-Milton:Aprilhop" ontap="yes" inbottle="no" oncask="no" price="0">
//			<name>Aprilhop</name>
//		</item>
//		<item type="beer" id="beer:Dogfish-Head-Craft-Brewery-Milton:Black-Blue" ontap="yes" inbottle="no" oncask="no" price="0">
//			<name>Black &amp; Blue</name>
//		</item>
//		<item type="beer" id="beer:Dogfish-Head-Craft-Brewery-Milton:Chicory-Stout" ontap="yes" inbottle="no" oncask="no" price="0">
//			<name>Chicory Stout</name>
//		</item>
//		<item type="beer" id="beer:Dogfish-Head-Craft-Brewery-Milton:Chateau-Jiahu" ontap="yes" inbottle="no" oncask="no" price="0">
//			<name>Chateau Jiahu</name>
//		</item>
//	</items>
//</menu>
//
// Sample wishlist doc:
//
//<wishlist id="wishlist:troyh" rev="824165725">
//	<type>wishlist</type>
//	<meta>
//		<timestamp>1250120366</timestamp>
//		<mtime>1250123226</mtime>
//	</meta>
//	<items>
//		<item>
//			<type>item</type>
//			<meta>
//				<timestamp>1250122973</timestamp>
//				<mtime>1250123226</mtime>
//			</meta>
//			<item_id>beer:Dogfish-Head-Craft-Brewery-Milton:120-Minute-IPA</item_id>
//			<name>120 Minute IPA</name>
//		</item>
//	</items>
//</wishlist>



- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.currentElemValue release];
	self.currentElemValue=nil;
	
	[self.currentElemAttribs release];
	self.currentElemAttribs=nil;
	
	xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5]; // This also releases a previous xmlParserPath
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.currentElemValue release];
	self.currentElemValue=nil;
	
	[self.currentElemAttribs release];
	self.currentElemAttribs=nil;
	
	xmlParserPath=nil; // This also releases a previous xmlParserPath
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
		// Is it the /brewery/meta/beerlist/item element?
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"brewery",@"meta",@"beerlist",nil]])
		{
			[self.currentElemValue release];
			self.currentElemValue=nil;
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];

			[self.currentElemAttribs release];
			self.currentElemAttribs=[[NSMutableDictionary alloc] initWithCapacity:10];
			[self.currentElemAttribs addEntriesFromDictionary:attributeDict];
		}
		else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"menu",@"items",nil]]) // Is it the /menu/items/item element?
		{
			[self.currentElemAttribs release];
			self.currentElemAttribs=[[NSMutableDictionary alloc] initWithCapacity:10];
			[self.currentElemAttribs addEntriesFromDictionary:attributeDict];
		}
		else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"wishlist",@"items",nil]]) // Is it the /wishlist/items/item element?
		{
			// Create a new BeerObject in the beerList
			BeerObject* beer=[[BeerObject alloc] init];
			[beerList addObject:beer];
			[beer release];
		}
	}
	else if ([elementName isEqualToString:@"name"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"menu",@"items",@"item",nil]]) // Is it the /menu/items/item/name element?
		{
			[self.currentElemValue release];
			self.currentElemValue=nil;
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
		}
		else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"wishlist",@"items",@"item",nil]]) // Is it the /wishlist/items/item/name element?
		{
			[self.currentElemValue release];
			self.currentElemValue=nil;
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
		}
	}
	else if ([elementName isEqualToString:@"item_id"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"wishlist",@"items",@"item",nil]]) // Is it the /wishlist/items/item/name element?
		{
			[self.currentElemValue release];
			self.currentElemValue=nil;
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:256];
		}
	}
	
	[xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[xmlParserPath removeLastObject];

	if (self.currentElemValue || currentElemAttribs)
	{
		if ([elementName isEqualToString:@"name"])
		{
			// Is it the /brewery/meta/beerlist/item/name element?
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"brewery",@"meta",@"beerlist",@"item",nil]])
			{
				BeerObject* beer=[[BeerObject alloc] init];
				[beer.data setObject:self.currentElemValue forKey:@"name"];
				[beer.data setObject:[[[currentElemAttribs objectForKey:@"id"] copy] autorelease] forKey:@"id"];
				
				[beerList addObject:beer];
				[beer release];
			}
			else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"menu",@"items",@"item",nil]]) // Is it the /menu/items/item/name element?
			{
				BeerObject* beer=[[BeerObject alloc] init];
				[beer.data setObject:currentElemValue forKey:@"name"];
				[beer.data setObject:[[[currentElemAttribs objectForKey:@"id"] copy] autorelease] forKey:@"id"];
				
				[beerList addObject:beer];
				[beer release];
			}
			// Is it the /wishlist/items/item/name element?
			else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"wishlist",@"items",@"item",nil]])
			{
				// Get the last BeerObject in beerList, that's our current beer
				BeerObject* beer=[beerList lastObject];
				[beer.data setObject:currentElemValue forKey:@"name"];
			}
		}
		else if ([elementName isEqualToString:@"item_id"])
		{
			// Is it the /wishlist/items/item/item_id element?
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"wishlist",@"items",@"item",nil]])
			{
				// Get the last BeerObject in beerList, that's our current beer
				BeerObject* beer=[beerList lastObject];
				[beer.data setObject:currentElemValue forKey:@"id"];
			}
		}
		
		[self.currentElemValue release];
		self.currentElemValue=nil;
		[self.currentElemAttribs release];
		self.currentElemAttribs=nil;
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


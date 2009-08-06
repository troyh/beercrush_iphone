//
//  NearbyTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>

#import "NearbyTableViewController.h"
#import "MyTableViewController.h"
#import "BreweryTableViewController.h"
#import "PlaceTableViewController.h"
#import "BeerTableViewController.h"

@implementation PlaceObject

@synthesize place_id;
@synthesize data;
@synthesize editeddata;
@synthesize distanceAway;
//@synthesize name;
//@synthesize loc;
//@synthesize street;
//@synthesize city;
//@synthesize state;
//@synthesize zip;
//@synthesize phone;
//@synthesize uri;

-(id)init
{
	self.data=[[NSMutableDictionary alloc] initWithCapacity:10];
	self.editeddata=nil;
	if (self.data)
	{
		[self.data setObject:@"" forKey:@"name"];
		[self.data setObject:@"" forKey:@"uri"];
		[self.data setObject:@"" forKey:@"phone"];
		[self.data setObject:[[NSMutableDictionary alloc] initWithCapacity:4] forKey:@"address"];
	}
	
	return self;
}

-(NSInteger)compareLocation:(id)other
{
	PlaceObject* otherplace=(PlaceObject*)other;
	if (self.distanceAway < otherplace.distanceAway)
		return NSOrderedAscending;
	else if (self.distanceAway > otherplace.distanceAway)
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}

@end


@implementation NearbyTableViewController

@synthesize app;
@synthesize appdel;
@synthesize myLocation;
@synthesize currentElemValue;
@synthesize placeObject;
@synthesize places;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	self.title=@"Nearby";
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	if (myLocation==nil || [myLocation.timestamp timeIntervalSinceNow] > 60)
	{
		// Get location
	//	CLLocationManager* locman=[[[CLLocationManager alloc] init] autorelease];
		CLLocationManager* locman=[[CLLocationManager alloc] init];
		locman.delegate=self;
		locman.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
		[locman startUpdatingLocation];
	}
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [places count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NearbyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	PlaceObject* p=[places objectAtIndex:indexPath.row];
//	cell.font=[UIFont boldSystemFontOfSize:14.0];
	cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

	UILabel* nametext=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 300.0, 20.0)];
	nametext.text=[p.data valueForKey:@"name"];
	nametext.font=[UIFont boldSystemFontOfSize:16.0];
//	nametext.textColor=[UIColor grayColor];
	[cell.contentView addSubview:nametext];
	
	UILabel* disttext=[[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 300.0, 10.0)];
	disttext.text=[NSString stringWithFormat:@"%0.1f miles",(p.distanceAway/1000*0.62137119)]; // Convert meters to miles
	disttext.font=[UIFont systemFontOfSize: [UIFont smallSystemFontSize]];
	disttext.textColor=[UIColor grayColor];
	[cell.contentView addSubview:disttext];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	ResultType t=Place;
//	if (t == Brewer)
//	{
//		BreweryTableViewController* btvc=[[BreweryTableViewController alloc] initWithBreweryID:[searchResultsList_id objectAtIndex:indexPath.row] app:app appDelegate: appdel];
//		[appdel.nav pushViewController: btvc animated:YES];
//		[btvc release];
//	}
//	else if (t == Beer)
//	{
//		BeerTableViewController* btvc=[[BeerTableViewController alloc] initWithBeerID: [searchResultsList_id objectAtIndex:indexPath.row] app:app appDelegate: appdel];
//		[appdel.nav pushViewController: btvc animated:YES];
//		[btvc release];
//	}
	if (t == Place)
	{
		PlaceObject* po=[places objectAtIndex:indexPath.row];
		PlaceTableViewController* btvc=[[PlaceTableViewController alloc] initWithPlaceID:po.place_id  app:app appDelegate: appdel];
		UINavigationController* nav=(UINavigationController*)self.parentViewController;
		[nav pushViewController: btvc animated:YES];
		[btvc release];
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
    [super dealloc];
}


// CLLocation delegate methods

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// TODO: check timestamp of newLocation and if it's within a few seconds, stop updating location.
	
	NSLog(@"newLocation timestamp=%@ timeIntervalSinceNow=%d",newLocation.timestamp.description,[newLocation.timestamp timeIntervalSinceNow]);
	if ([newLocation.timestamp timeIntervalSinceNow] > -3)
	{
		NSLog(@"Stopping updating Location");
		[manager stopUpdatingLocation];
	}
	
	if (myLocation)
		[myLocation release];
	myLocation=newLocation;
	[myLocation retain];
	
	// Ask server for nearby places
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_NEARBY_QUERY, myLocation.coordinate.latitude, myLocation.coordinate.longitude]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	
}
		  
// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}
	

// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
//	if (self.currentElemValue)
//		[self.currentElemValue release];
	self.currentElemValue=nil;
//	if (self.places)
//		[self.places release];
	self.places=nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	// Sort the places
	[self.places sortUsingSelector:@selector(compareLocation:)];
	[self.tableView reloadData];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"places"])
	{
		self.places=[NSMutableArray arrayWithCapacity: [[attributeDict valueForKey:@"count"] intValue]];
	}
	else if ([elementName isEqualToString:@"place"])
	{
		placeObject=[[PlaceObject alloc] init];
		CLLocation* loc=[[CLLocation alloc] initWithLatitude:[[attributeDict valueForKey:@"latitude"] doubleValue] longitude:[[attributeDict valueForKey:@"longitude"] doubleValue]];
		[placeObject.data setObject:loc forKey:@"loc"];
		placeObject.place_id=[attributeDict valueForKey:@"id"];
	}
	else if ([elementName isEqualToString:@"name"])
	{
		self.currentElemValue=[NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"place"])
	{
		// TODO: store object
		//	NSLog(@"MyLocation Lat:%f Lon:%f",myLocation.coordinate.latitude,myLocation.coordinate.longitude);
		CLLocation* pl=[placeObject.data valueForKey:@"loc"];
		//	NSLog(@"PlaceLoctn Lat:%f Lon:%f",pl.coordinate.latitude,pl.coordinate.longitude);
		placeObject.distanceAway=[pl getDistanceFrom:myLocation];
		
		[places addObject:placeObject];
	}
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"name"])
			[placeObject.data setObject:currentElemValue forKey:@"name"];

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


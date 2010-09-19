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
#import "BreweryTableViewController.h"
#import "PlaceTableViewController.h"
#import "BeerTableViewController.h"

NSInteger compareLocation(id a, id b, void* context)
{
	NSDictionary* aDict=(NSDictionary*)a;
	NSDictionary* bDict=(NSDictionary*)b;

	NSNumber* aDistance=[aDict objectForKey:@"distanceAway"];
	NSNumber* bDistance=[bDict objectForKey:@"distanceAway"];
	
	return [aDistance compare:bDistance];
}

void orderByDistance(CLLocation* myLocation, NSMutableArray* placesArray)
{
	for (NSMutableDictionary* place in placesArray)
	{
		CLLocation* loc=[[[CLLocation alloc] initWithLatitude:[[place valueForKey:@"lat"] doubleValue] longitude:[[place valueForKey:@"lon"] doubleValue]] autorelease];
		[place setObject:[NSNumber numberWithDouble:[loc distanceFromLocation:myLocation]] forKey:@"distanceAway"];
	}
	
	[placesArray sortUsingFunction:compareLocation context:nil];
}


@implementation NearbyTableViewController

@synthesize myLocation;
@synthesize places;
@synthesize locationManager;
@synthesize beerID;

const NSInteger kViewTagName=1;
const NSInteger kViewTagDistance=2;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (id)initWithBeerID:(NSString*)beer_id {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.beerID=beer_id;
    }
    return self;
}

-(void)getPlaceList:(NSString*)beer_id
{
	// TODO: get the actual location
//	CLLocation* myLocation=[[[CLLocation alloc] initWithLatitude:37.331689 longitude:-122.030731] autorelease];
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.places=[appDelegate getPlacesWithBeer:beer_id nearLocation:self.myLocation withinDistance:10];

	orderByDistance(self.myLocation, [self.places objectForKey:@"places"]);

	[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[appDelegate dismissActivityHUD];
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

-(NSObject*)navigationRestorationData
{
	return nil;
}

- (void)viewWillAppear:(BOOL)animated {
	if (myLocation==nil || [myLocation.timestamp timeIntervalSinceNow] > 60)
	{
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate presentActivityHUD:@"Updating Location"];
		
		// Get location
		//	CLLocationManager* locman=[[[CLLocationManager alloc] init] autorelease];
		self.locationManager=[[CLLocationManager alloc] init];
		self.locationManager.delegate=self;
		self.locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;
		[self.locationManager startUpdatingLocation];
		
		UISegmentedControl* segmentedControl=[[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All",@"Food",@"Bars",@"Stores",nil]] autorelease];
		segmentedControl.segmentedControlStyle=UISegmentedControlStyleBar;
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
		self.navigationItem.titleView=segmentedControl;
		
		self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshNearby:)] autorelease];
	}
	
	self.title=@"Nearby";

    [super viewWillAppear:animated];
}

-(void)refreshNearby:(id)sender
{
	[self.places removeAllObjects];
	[self.tableView reloadData];
	[self.locationManager startUpdatingLocation];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	DLog(@"Stopping updating Location");
	[locationManager stopUpdatingLocation];
}

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
    return [[self.places objectForKey:@"places"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NearbyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

		UILabel* namelabel=[[[UILabel alloc] initWithFrame:CGRectMake(40, 2, 250, 30)] autorelease];
		namelabel.tag=kViewTagName;
		namelabel.font=[UIFont boldSystemFontOfSize:16.0];
		[cell.contentView addSubview:namelabel];
		
		UILabel* distanceLabel=[[[UILabel alloc] initWithFrame:CGRectMake(255, 17, 40, 10)] autorelease];
		distanceLabel.tag=kViewTagDistance;
		distanceLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		distanceLabel.textColor=[UIColor grayColor];
		[cell.contentView addSubview:distanceLabel];
    }
    
    // Set up the cell...
	NSDictionary* p=[[self.places objectForKey:@"places"] objectAtIndex:indexPath.row];

	UILabel* namelabel=(UILabel*)[cell.contentView viewWithTag:kViewTagName];
	[namelabel setText:([p objectForKey:@"name"]?[p objectForKey:@"name"]:@"")];
	
	UILabel* distlabel=(UILabel*)[cell.contentView viewWithTag:kViewTagDistance];
	[distlabel setText:[NSString stringWithFormat:@"%0.1f mi",([[p objectForKey:@"distanceAway"] doubleValue]/1000*0.62137119)]]; // Convert meters to miles

	if ([[p objectForKey:@"place_id"] hasPrefix:@"brewery:"])
		cell.imageView.image=[UIImage imageNamed:@"brewery.png"];
	else
		cell.imageView.image=[UIImage imageNamed:@"restaurant.png"];
	
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
		NSDictionary* po=[[self.places objectForKey:@"places"] objectAtIndex:indexPath.row];
		PlaceTableViewController* btvc=[[PlaceTableViewController alloc] initWithPlaceID:[po objectForKey:@"place_id"]];
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
	[myLocation release];
	[places release];
	[locationManager release];
    [super dealloc];
}


// CLLocation delegate methods

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// TODO: check timestamp of newLocation and if it's within a few seconds, stop updating location.
	
	DLog(@"newLocation timestamp=%@ timeIntervalSinceNow=%d",newLocation.timestamp.description,[newLocation.timestamp timeIntervalSinceNow]);
//	if ([newLocation.timestamp timeIntervalSinceNow] > -3)
//	{
//		DLog(@"Stopping updating Location");
//		[manager stopUpdatingLocation];
//	}
	[manager stopUpdatingLocation]; // Just do it once, the user can ask to do it again
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate dismissActivityHUD];
	
	if (myLocation)
		[myLocation release];
	myLocation=newLocation;
	[myLocation retain];
	
	if (self.beerID)
	{
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(getPlaceList:) object:self.beerID requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"Getting Places",@"HUD: Getting Places that have this beer")];
	}
	else 
	{
		// Ask server for nearby places
		NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_NEARBY_QUERY, myLocation.coordinate.latitude, myLocation.coordinate.longitude, 10]];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(getNearbyResults:) object:url requiresUserCredentials:NO activityHUDText:NSLocalizedString(@"HUD:Updating",@"Updating")];
	}
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	DLog(@"Stopping updating Location because of an error");
	[manager stopUpdatingLocation];
}
	
#pragma mark Async operations

-(void)getNearbyResults:(NSURL*)url
{
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* data;
	NSHTTPURLResponse* response=[delegate sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&data];
	if ([response statusCode]==200)
	{
		self.places=data;
		orderByDistance(self.myLocation, [self.places objectForKey:@"places"]);

		[self.tableView reloadData];
	}
	else {
		[self performSelectorOnMainThread:@selector(getNearbyResultsFailed) withObject:nil waitUntilDone:NO];
	}

	
	[delegate dismissActivityHUD];
}

-(void)getNearbyResultsFailed
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nearby",@"GetNearbyResultsFailed: failure alert title")
												  message:NSLocalizedString(@"Failed to get nearby list",@"GetNearbyResultsFailed: failure alert message")
												 delegate:nil
										cancelButtonTitle:NSLocalizedString(@"OK",@"GetNearbyResultsFailed: failure alert cancel button title")
										otherButtonTitles:nil];
	[alert show];
	[alert release];
}


@end


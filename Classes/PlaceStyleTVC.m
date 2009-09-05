//
//  PlaceStyleTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlaceStyleTVC.h"
#import "BeerCrushAppDelegate.h"
#import "JSON.h"

@implementation PlaceStyleTVC

@synthesize delegate;
@synthesize currentlySelectedStyle;
@synthesize stylesDict;

-(id)init
{
	if (self=[super initWithStyle:UITableViewStylePlain])
	{
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URI_GET_PLACE_STYLES];
		NSData* answer;
		NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSString* s=[[[NSString alloc] initWithData:answer encoding:NSUTF8StringEncoding] autorelease];
			self.stylesDict=[s JSONValue];
		}
		self.title=@"Place Type";
	}
	return self;
}

-(id)initWithCategoryDictionary:(NSDictionary*)dict
{
	if (self=[super initWithStyle:UITableViewStylePlain])
	{
		self.stylesDict=dict;
		self.title=@"Place Type";
	}
	return self;
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
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.stylesDict objectForKey:@"categories"] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSString* s=[[[self.stylesDict objectForKey:@"categories"] objectAtIndex:indexPath.row] objectForKey:@"name"];
	[cell.textLabel setText:s];
	if ([self.currentlySelectedStyle isEqualToString:s])
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// If there are more subcategories to navigate to, do that
	if ([[[self.stylesDict objectForKey:@"categories"] objectAtIndex:indexPath.row] objectForKey:@"categories"]==nil)
	{
		[self.delegate placeStyleTVC:self didSelectStyle:[[self.stylesDict objectForKey:@"categories"] objectAtIndex:indexPath.row]];
	}
	else // Otherwise, end it and inform the delegate that a category was selected.
	{
		PlaceStyleTVC* pstvc=[[[PlaceStyleTVC alloc] initWithCategoryDictionary:[[self.stylesDict objectForKey:@"categories"] objectAtIndex:indexPath.row]] autorelease];
		pstvc.delegate=self;
		[self.navigationController pushViewController:pstvc animated:YES];
	}
}

#pragma mark PlaceStyleTVCDelegate methods

-(void)placeStyleTVC:(id)placeStyleTVC didSelectStyle:(NSDictionary*)style
{
	[self.delegate placeStyleTVC:self didSelectStyle:style];
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
	[self.currentlySelectedStyle release];
	[self.stylesDict release];
    [super dealloc];
}


@end


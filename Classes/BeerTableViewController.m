//
//  BeerTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerTableViewController.h"
#import "ReviewsTableViewController.h"

@implementation BeerTableViewController

@synthesize beerID;
@synthesize app;
@synthesize appdel;

-(id) initWithBeerID:(NSString*)beer_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d
{
	self.beerID=beer_id;
	self.app=a;
	self.appdel=d;

	self.title=@"Beer";
	
	[super initWithStyle:UITableViewStyleGrouped];
	
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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return 2;
			break;
		default:
			break;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: If we don't have the data yet, request it from the server
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0:
			switch (indexPath.row)
		{
			case 0:
				cell.text=@"Name";
				cell.font=[UIFont boldSystemFontOfSize:20];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
				cell.text=@"Rating & Reviews";
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 2:
				cell.text=@"Description";
				cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			default:
				break;
		}
			break;
		case 1:
			switch (indexPath.row)
		{
			case 0:
				cell.text=@"Style";
				cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
				cell.text=@"ABV";
				cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			default:
				break;
		}
	}
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.section == 0 && indexPath.row == 1) 
	{
		ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.beerID dataType:Beer];
		[self.navigationController pushViewController: rtvc animated:YES];
		[rtvc release];
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


@end


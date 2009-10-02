//
//  MyTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyTableViewController.h"
#import "JSON.h"

@implementation MyTableViewController

@synthesize resultsList;
@synthesize performedSearchQuery;
@synthesize searchTypes;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.hidesBackButton=YES;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([appDelegate restoringNavigationStateAutomatically])
	{
		NSObject* navData=[appDelegate nextNavigationStateToRestore];
		if ([navData isKindOfClass:[NSString class]])
		{
			// See what type it is
			NSString* idstr=(NSString*)navData;
			if (idstr)
			{
				if ([[idstr substringToIndex:8] isEqualToString:@"brewery:"])
				{
					BreweryTableViewController* btvc=[[[BreweryTableViewController alloc] initWithBreweryID:idstr] autorelease];
					[self.navigationController pushViewController: btvc animated:NO];
					
					[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
				}
				else if ([[idstr substringToIndex:5] isEqualToString:@"beer:"])
				{
					BeerTableViewController* btvc=[[[BeerTableViewController alloc] initWithBeerID:idstr] autorelease];
					[self.navigationController pushViewController:btvc animated:NO];
					
					[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
				}
				else if ([[idstr substringToIndex:6] isEqualToString:@"place:"])
				{
					PlaceTableViewController* btvc=[[[PlaceTableViewController alloc] initWithPlaceID:idstr] autorelease];
					[self.navigationController pushViewController: btvc animated:NO];
					
					[appDelegate pushNavigationStateForTabBarItem:self.navigationController.tabBarItem withData:idstr];
				}
			}
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
	// TODO: free any search results
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
	[self.resultsList release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

//#pragma mark UIActionSheetDelegate methods
//
//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//	if (actionSheet.cancelButtonIndex==buttonIndex)
//		return;
//	
//	UIViewController* vc=[[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
//	
//	switch (buttonIndex) 
//	{
//		case 0: // Add a brewery
//		{
//			BreweryTableViewController* btvc=[[[BreweryTableViewController alloc] initWithBreweryID:nil] autorelease];
//			btvc.delegate=self;
//			[btvc setEditing:YES animated:NO];
//			[nc pushViewController:btvc animated:NO];
//			break;
//		}
//		case 1: // Add a beer
//		{
//			BeerTableViewController* btvc=[[[BeerTableViewController alloc] initWithBeerID:nil] autorelease];
//			btvc.delegate=self;
//			[btvc setEditing:YES animated:NO];
//			[nc pushViewController:btvc animated:NO];
//			break;
//		}
//		default:
//			break;
//	}
//	
//	[self.navigationController presentModalViewController:nc animated:YES];
//}


@end


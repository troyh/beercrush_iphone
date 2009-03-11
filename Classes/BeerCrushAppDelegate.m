//
//  BeerCrushAppDelegate.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "MyTableViewController.h"

@implementation BeerObject

@synthesize name;
@synthesize attribs;
@synthesize description;
@synthesize style;
@synthesize abv;
@synthesize ibu;

@end

@implementation BeerCrushAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize nav;
@synthesize mySearchBar;
@synthesize app;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	self.app=application;
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
//	UIViewController* searchResultsController=[[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//	nav=[[UINavigationController alloc] initWithRootViewController:searchResultsController];
	nav=[[UINavigationController alloc] initWithNibName:nil bundle:nil];
	nav.navigationBarHidden=YES;
	nav.delegate=self;

	CGRect sbf=application.keyWindow.frame;
//	tabBarController.view.frame=sbf;
	sbf.size.height=44;
//	sbf.origin.y=40;
//	nav.navigationBar.frame=sbf;
	
	[tabBarController.view addSubview:nav.view];
	
	// Create the search bar
//	sbf.origin.y=0;
	mySearchBar=[[UISearchBar alloc] initWithFrame:sbf];
	mySearchBar.delegate=self;
	[tabBarController.view addSubview: mySearchBar];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[nav release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];

	// Display them in a UITableView
	CGRect f=tabBarController.view.frame;
	f.size.height=411-searchBar.frame.size.height;
	f.origin.y=searchBar.frame.size.height;
	nav.view.frame=f;

	MyTableViewController* tbl=nil;
	if (nav.viewControllers.count)
	{
		if ([nav.topViewController isMemberOfClass:[MyTableViewController class]])
		{
			tbl=(MyTableViewController*)nav.topViewController;
		}
		else // This shouldn't happen...
		{
			// ...but just in case it does, pop all view controllers
			while (nav.navigationController.viewControllers.count)
				[nav.navigationController popViewControllerAnimated:YES];
		}
	}
	
	if (tbl==nil)
	{
		tbl=[[MyTableViewController alloc] initWithNibName:nil bundle:nil];
		[nav pushViewController:tbl animated:NO];
		tbl.app=app;
		tbl.appdel=self;
	}
	
	[tbl query: searchBar.text];
	[tbl.tableView reloadData];
	
	//UIAlertView* av=[[UIAlertView alloc] initWithTitle: @"Blah"  message:searchBar.text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//[av show];
	//[av release];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
	searchBar.showsCancelButton=YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
{
	return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (navigationController.viewControllers.count==1)
	{
		CGRect f=tabBarController.view.frame;
		f.size.height=411-mySearchBar.frame.size.height;
		f.origin.y=mySearchBar.frame.size.height;
		nav.view.frame=f;
		mySearchBar.hidden=NO;
		nav.navigationBarHidden=YES;
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

@end


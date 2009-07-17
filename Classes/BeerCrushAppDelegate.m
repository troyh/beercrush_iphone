//
//  BeerCrushAppDelegate.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "MyTableViewController.h"
#import "NearbyTableViewController.h"
#import "BreweryTableViewController.h"
#import "UserReviewsTVC.h"

@implementation BeerObject

@synthesize data;
//@synthesize name;
//@synthesize attribs;
//@synthesize description;
//@synthesize style;
//@synthesize abv;
//@synthesize ibu;

-(id)init
{
//	NSLog(@"BeerObject init");
	self.data=[[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
	return self;
}

-(void)dealloc
{
//	NSLog(@"BeerObject dealloc");
	[self.data release];
	[super dealloc];
}


@end

@implementation BeerCrushAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize nav;
@synthesize mySearchBar;
@synthesize app;
@synthesize xmlPostResponse;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	self.app=application;
	
	tabBarController.viewControllers=[[NSArray alloc] initWithObjects:[[UINavigationController alloc] initWithNibName:nil bundle:nil],
																	  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
																	  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
																	  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
																	  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
																	  nil];
	
	UINavigationController* ctl=[tabBarController.viewControllers objectAtIndex:0];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Beers" image:[UIImage imageNamed:@"dot.png"] tag:4422] autorelease];

	ctl=[tabBarController.viewControllers objectAtIndex:1];
	nav=ctl;
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:42] autorelease];
	tabBarController.selectedViewController=ctl;
	
	// Create the search bar
	CGRect sbf=application.keyWindow.frame;
	sbf.size.height=nav.navigationBar.frame.size.height;
	mySearchBar=[[UISearchBar alloc] initWithFrame:nav.navigationBar.frame];
	mySearchBar.delegate=self;
	//	[tabBarController.view addSubview: mySearchBar];
	[ctl.view addSubview: mySearchBar];
	
	ctl=[tabBarController.viewControllers objectAtIndex:2];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Nearby" image:[UIImage imageNamed:@"dot.png"] tag:4422] autorelease];
	NearbyTableViewController* ntvc=[[NearbyTableViewController alloc] initWithStyle: UITableViewStylePlain];
	ntvc.app=app;
	ntvc.appdel=self;
	[ctl pushViewController:ntvc animated:NO ];
	
	ctl=[tabBarController.viewControllers objectAtIndex:3];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"My Reviews" image:[UIImage imageNamed:@"star_filled.png"] tag:442] autorelease];
	UserReviewsTVC* urtvc=[[UserReviewsTVC alloc] initWithStyle:UITableViewStylePlain];
	[ctl pushViewController:urtvc animated:NO];
	[urtvc release];
	
	ctl=[tabBarController.viewControllers objectAtIndex:4];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Wish List" image:[UIImage imageNamed:@"star_empty.png"] tag:44422] autorelease];
	

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
//	UIViewController* searchResultsController=[[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//	nav=[[UINavigationController alloc] initWithRootViewController:searchResultsController];
//	nav=[[UINavigationController alloc] initWithNibName:nil bundle:nil];
//	nav=[tabBarController.viewControllers objectAtIndex:0];
//	nav.navigationBarHidden=YES;
	nav.delegate=self;
	
	[tabBarController retain];
	
	//
	// Automatically navigate to where the user last closed the app
	//

//	// Hide search bar
//	[mySearchBar resignFirstResponder];
//	mySearchBar.hidden=YES;
//	self.nav.view.frame=app.keyWindow.frame;
//	self.nav.navigationBarHidden=NO;

	// Start the navigation
//	BreweryTableViewController* btvc=[[BreweryTableViewController alloc] initWithBreweryID:@"Dogfish-Head-Craft-Brewery-Milton" app:self.app appDelegate:self];
//	[[tabBarController.viewControllers objectAtIndex:1] pushViewController: btvc animated:YES];
//	[btvc release];

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
//	CGRect f=tabBarController.view.frame;
//	f.size.height=411-searchBar.frame.size.height;
//	f.origin.y=searchBar.frame.size.height;
//	nav.view.frame=f;

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
//		CGRect f=tabBarController.view.frame;
//		f.size.height=411-mySearchBar.frame.size.height;
//		f.origin.y=mySearchBar.frame.size.height;
//		nav.view.frame=f;
		mySearchBar.hidden=NO;
//		nav.navigationBarHidden=YES;
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

// Login
-(void)login
{
	// Get the userid and password from App Preferences
	NSString* userid=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
	NSString* password=[[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	NSLog(@"Logging in...");
	NSString* bodystr=[[NSString alloc] initWithFormat:@"userid=%@&password=%@", userid, password];
	NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];

	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_LOGIN]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:60.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:body];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

	if (theConnection) {
		// We don't care about any response document, we just want the cookies to be stored (automatically)
		xmlPostResponse=[[NSMutableData data] retain];
	} else {
		// TODO: inform the user that the download could not be made
	}	
}


// NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	
	NSHTTPURLResponse* httprsp=(NSHTTPURLResponse*)response;
	NSInteger n=httprsp.statusCode;
	
	if (n!=200)
	{
		NSLog(@"Headers:");
		NSDictionary* hdrdict=[httprsp allHeaderFields];
		NSArray* headers=[hdrdict allKeys];
		for (NSUInteger i=0;i<[headers count];++i)
		{
			NSLog(@"%@:%@",[headers objectAtIndex:i],[hdrdict objectForKey:[headers objectAtIndex:i]]);
		}
		// TODO: alert the user that the login failed
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Check username and password in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
//		NSLog(@"Login failed.");
	}
	else
	{
		NSLog(@"Login successful.");
//		NSArray* cookies=[NSHTTPCookie cookiesWithResponseHeaderFields:httprsp.allHeaderFields forURL:@""];
//		// Look through cookies and find userid and usrkey
//		for (int i=0; i < [cookies count]; ++i) {
//			NSHTTPCookie* c=[cookies objectAtIndex:i];
//			if ([c.name isEqualToString:@"userid"])
//			{
//				userid=c.value;
//			}
//			else if ([c.name isEqualToString:@"usrkey"])
//			{
//				usrkey=c.value;
//			}
//		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [xmlPostResponse appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
	
    // receivedData is declared as a method instance elsewhere
	
    // inform the user
    NSLog(@"Login failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
//    NSLog(@"Succeeded! Received %d bytes of data",[reviewPostResponse length]);
	NSLog(@"Login response:%s",(char*)[xmlPostResponse mutableBytes]);
	
    // release the connection, and the data object
    [connection release];
//    [reviewPostResponse release];
}

@end


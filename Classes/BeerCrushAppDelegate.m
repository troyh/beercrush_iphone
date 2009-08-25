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
#import "LoginVC.h"
#import "BeerListTableViewController.h"

#define kTabBarItemTagBeers 1
#define kTabBarItemTagSearch 2
#define kTabBarItemTagNearby 3
#define kTabBarItemTagMyReviews 4
#define kTabBarItemTagWishList 5

@implementation BeerObject

@synthesize data;

-(id)init
{
//	DLog(@"BeerObject init");
	self.data=[[NSMutableDictionary alloc] initWithCapacity:5];
	return self;
}

-(void)dealloc
{
//	DLog(@"BeerObject dealloc");
	[self.data release];
	
	[super dealloc];
}


@end

@implementation BeerCrushAppDelegate

@synthesize window;
@synthesize loginVC;
@synthesize tabBarController;
//@synthesize nav;
//@synthesize mySearchBar;
//@synthesize app;
@synthesize xmlPostResponse;
@synthesize onBeerSelectedAction;
@synthesize onBeerSelectedTarget;
@synthesize xmlParserPath;
@synthesize currentElemValue;
@synthesize currentElemID;
@synthesize flavorsDictionary;
@synthesize stylesDictionary;
@synthesize restoringNavState;
@synthesize appState;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	loginVC=nil;
	
	// If we don't know the username/password for the user, give them the login screen
	NSString* userid=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
	NSString* password=[[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	if (userid==nil || password==nil)
	{
		[self askUserForCredentials];
	}
	else
	{
		[self startApp];
	}

}

-(void)askUserForCredentials
{
	if (loginVC==nil) // Don't create and show it if it's already up
	{
		loginVC=[[LoginVC alloc] initWithNibName:nil bundle:nil];
		[window addSubview:loginVC.view];
	}
}

-(void)startApp
{
	if (loginVC)
	{
		//[loginVC release];
		loginVC=nil; // releases it too
	}

	tabBarController.viewControllers=[[NSArray alloc] initWithObjects:
									  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
									  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
									  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
									  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
									  [[UINavigationController alloc] initWithNibName:nil bundle:nil],
									  nil];
	
	UINavigationController* ctl=[tabBarController.viewControllers objectAtIndex:0];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Beers" image:[UIImage imageNamed:@"dot.png"] tag:kTabBarItemTagBeers] autorelease];
	
	ctl=[tabBarController.viewControllers objectAtIndex:1];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:kTabBarItemTagSearch] autorelease];
	
	ctl=[tabBarController.viewControllers objectAtIndex:2];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Nearby" image:[UIImage imageNamed:@"dot.png"] tag:kTabBarItemTagNearby] autorelease];
	
	ctl=[tabBarController.viewControllers objectAtIndex:3];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"My Reviews" image:[UIImage imageNamed:@"star_filled.png"] tag:kTabBarItemTagMyReviews] autorelease];
	
	ctl=[tabBarController.viewControllers objectAtIndex:4];
	ctl.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Wish List" image:[UIImage imageNamed:@"star_empty.png"] tag:kTabBarItemTagWishList] autorelease];
	
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	
	//	UIViewController* searchResultsController=[[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
	//	nav=[[UINavigationController alloc] initWithRootViewController:searchResultsController];
	//	nav=[[UINavigationController alloc] initWithNibName:nil bundle:nil];
	//	nav=[tabBarController.viewControllers objectAtIndex:0];
	//	nav.navigationBarHidden=YES;
//	nav.delegate=self;
	
	//
	// Automatically navigate to where the user last closed the app
	//
	
	// Hide search bar
//	[mySearchBar resignFirstResponder];
//	mySearchBar.hidden=YES;
//	self.nav.view.frame=app.keyWindow.frame;
//	self.nav.navigationBarHidden=NO;
	
	/*
		 Restore the previous state of navigation:
	 
		 For each tab in the TabBarController, do the following:
			1. Move the previous nav stack out of the previous set and clear the previous stack
			2. Persist the new (empty) stack in NSUserDefaults (via synchronize)
			3. Start the navigation (each nav step will add to the stack as they normally do)
			4. Persist the new nav stack in NSUserDefaults
			5. Throw the old stack away
	 
		This way, if the app crashes while trying to restore the state of the navigation, the 
		app won't get caught in an infinite loop of launching and crashing. Also, if for some reason, 
	    (no network connection, the next step in the stack doesn't make sense anymore, the data needed 
		to navigate isn't available, etc.) the app can't navigate to the previous position, the newest 
		nav state makes sense -- view controller only goes as far as it can.
	 
		To do this, the app delegate provides methods that each controller can use to determine if it needs
	    to automatically navigate to the next step. These methods are:

				-(BOOL)saveNavigationState:(NSObject*)data;
				-(BOOL)restoringNavigationStateAutomatically;
				-(NSObject*)nextNavigationStateToRestore;

	 In each view controller's viewDidLoad method should look something like this:
	 
	 [appdel saveNavigationState:mynavdata]; // Saves the new nav state
	 if ([appdel restoringNavigationStateAutomatically]) // Go to the next step automatically?
	 {
		NSObject* navdata=[appdel nextNavigationStateToRestore];
		if (navdata)
		{
			Use navdata to go to the next nav state...
		}
	 }
	 */
	
	self.restoringNavState=[[NSUserDefaults standardUserDefaults] objectForKey:@"appstate"];
	if (self.restoringNavState)
	{
		NSMutableArray* previousNavStacks=[self.restoringNavState objectForKey:@"navstacks"];

		if ([previousNavStacks count] < [tabBarController.viewControllers count])
		{ // The app state was saved with fewer stacks than we need (we are a newer version of the app?), so add more...
			for (NSUInteger i=[previousNavStacks count];i < [tabBarController.viewControllers count];++i)
			{
				// Create a new stack for this tab bar item
				[previousNavStacks addObject:[NSMutableArray arrayWithCapacity:5]];
			}
		}
	}

	// Create a new appstate dictionary to store the app's state as it runs
	self.appState=[[NSMutableDictionary alloc] init];
	NSMutableArray* stacks=[NSMutableArray arrayWithCapacity:[self.tabBarController.viewControllers count]];
	for (int i=0;i<[self.tabBarController.viewControllers count];++i)
	{
		[stacks addObject:[NSMutableArray arrayWithCapacity:5]];
	}
	[self.appState setObject:stacks forKey:@"navstacks"];
	
	
	for (NSUInteger tabBarControllerIndex=0;tabBarControllerIndex < [tabBarController.viewControllers count];++tabBarControllerIndex)
	{
		switch (tabBarControllerIndex+1) {
			case kTabBarItemTagBeers:
				break;
			case kTabBarItemTagMyReviews:
			{
				UserReviewsTVC* urtvc=[[UserReviewsTVC alloc] initWithStyle:UITableViewStylePlain];
				[[tabBarController.viewControllers objectAtIndex:tabBarControllerIndex] pushViewController:urtvc animated:NO];
				[urtvc release];
				break;
			}
			case kTabBarItemTagNearby:
			{
				NearbyTableViewController* ntvc=[[NearbyTableViewController alloc] initWithStyle: UITableViewStylePlain];
				[[tabBarController.viewControllers objectAtIndex:tabBarControllerIndex] pushViewController:ntvc animated:NO ];
				break;
			}
			case kTabBarItemTagSearch:
			{
				MyTableViewController* tvc=[[[MyTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
				[[tabBarController.viewControllers objectAtIndex:tabBarControllerIndex] pushViewController:tvc animated:NO ];
				break;
			}
			case kTabBarItemTagWishList:
			{
				BeerListTableViewController* bltvc=[[BeerListTableViewController alloc] initWithBreweryID:[NSString stringWithFormat:@"wishlist:%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]]];
				[[tabBarController.viewControllers objectAtIndex:tabBarControllerIndex] pushViewController:bltvc animated:NO];
				[bltvc release];
				break;
			}
			default:
				// Shouldn't happen
				break;
		}
	}
	
	if (self.restoringNavState)
	{
		// We don't need to test if 'selectedtab' is there, it'll just set it to the 0-th controller anyway
		NSUInteger n=[(NSNumber*)[self.restoringNavState valueForKey:@"selectedtab"] integerValue];
		tabBarController.selectedViewController=[tabBarController.viewControllers objectAtIndex:n];
	}

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

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Save the current app state
	[self.appState setValue:[NSNumber numberWithUnsignedInt:[self.tabBarController.viewControllers indexOfObjectIdenticalTo:[self.tabBarController selectedViewController]]] forKey:@"selectedtab"];
	// TODO: if the app state is empty, just remove the key 'appstate' from NSUserDefaults
	[[NSUserDefaults standardUserDefaults] setObject:self.appState forKey:@"appstate"];
}


-(BOOL)restoringNavigationStateAutomatically
{
	if (self.restoringNavState==nil)
		return NO;

	NSMutableArray* stacks=[self.restoringNavState objectForKey:@"navstacks"];
	if (stacks==nil)
		return NO;

	NSUInteger idx=[self.tabBarController.viewControllers indexOfObjectIdenticalTo:self.tabBarController.selectedViewController];
	return [[stacks objectAtIndex:idx] count]?YES:NO;
}

-(NSObject*)nextNavigationStateToRestore
{
	NSMutableArray* stacks=[self.restoringNavState objectForKey:@"navstacks"];
	if (stacks)
	{
		NSUInteger idx=[self.tabBarController.viewControllers indexOfObjectIdenticalTo:self.tabBarController.selectedViewController];
		if (idx < [stacks count])
		{
			NSMutableArray* stack=[stacks objectAtIndex:idx];
			if ([stack count]==0)
				return nil;
			
			NSObject* obj=[[stack objectAtIndex:0] retain];
			[stack removeObjectAtIndex:0];
			[obj autorelease];
			return obj;
		}
	}
	
	return nil;
}

-(BOOL)pushNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem withData:(NSObject*)data
{
	NSUInteger idx=0;
	for (UIViewController* vc in self.tabBarController.viewControllers)
	{
		if (vc.tabBarItem.tag==tabBarItem.tag)
		{	// Found it
			NSMutableArray* stack=[[self.appState objectForKey:@"navstacks"] objectAtIndex:idx];
			[stack addObject:data];
			return stack?YES:NO;
		}
		++idx;
	}

	return NO;
}

-(void)popNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem
{
	NSMutableArray* stacks=[self.appState objectForKey:@"navstacks"];
	if (stacks)
	{
		NSUInteger idx=0;
		for (UIViewController* vc in self.tabBarController.viewControllers)
		{
			if (vc.tabBarItem.tag==tabBarItem.tag)
			{	// Found it
				if (idx < [stacks count])
				{
					if ([[stacks objectAtIndex:idx] count])
					{
						if ([vc.navigationController.viewControllers count] < [[stacks objectAtIndex:idx] count])
						{
							/* Make sure the stack has at least as many items as the navigation controller has. 
							 We have to do this because the view controllers just do pops (call this method) in 
							 viewWillAppear and it doesn't know if it's appearing because it was pushed onto the
							 nav controller's stack or if another view controller was popped.
							 */
							[[stacks objectAtIndex:idx] removeLastObject];
						}
					}
				}

				return;
			}
			++idx;
		}
	}
}

- (void)dealloc {
//	[nav release];
    [tabBarController release];
    [window release];
	[flavorsDictionary release];

	[loginVC release];
	[xmlPostResponse release];
	[xmlParserPath release];
	[currentElemValue release];
	[currentElemID release];
	[restoringNavState release];
	
    [super dealloc];
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (navigationController.viewControllers.count==1)
	{
//		CGRect f=tabBarController.view.frame;
//		f.size.height=411-mySearchBar.frame.size.height;
//		f.origin.y=mySearchBar.frame.size.height;
//		nav.view.frame=f;
//		mySearchBar.hidden=NO;
//		nav.navigationBarHidden=YES;
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

// Login
-(BOOL)login
{
	// Get the userid and password from App Preferences
	NSString* userid=[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
	NSString* password=[[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	DLog(@"Logging in...");
	NSString* bodystr=[[NSString alloc] initWithFormat:@"userid=%@&password=%@", userid, password];
	NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];

	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_LOGIN]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:60.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:body];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// create the connection with the request and start loading the data
//	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	NSHTTPURLResponse* response;
	NSError* error;

	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;

	DLog(@"status code=%d",[response statusCode]);
	if ([response statusCode]==200)
	{
		DLog(@"Login successful");
		// We don't care about any response document, we just want the cookies to be stored (automatically)
		return YES;
	} else {
		DLog(@"Login failed.");
		return NO;
	}	

}

-(NSHTTPURLResponse*)sendRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSString*)data returningData:(NSData**)responseData
{
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url 
													cachePolicy:NSURLRequestUseProtocolCachePolicy
													timeoutInterval:30.0];
	
	if ([method isEqualToString:@"POST"])
	{
		if (data)
		{
			DLog(@"POST data:%@",data);
			NSData* body=[NSData dataWithBytes:[data UTF8String] length:[data length]];
			[theRequest setHTTPBody:body];
			[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
		}
	}
	else if ([method isEqualToString:@"GET"])
	{
	}
	
	[theRequest setHTTPMethod:method];
	
	NSHTTPURLResponse* response=nil;
	NSError* error;
	int nTries=0;
	BOOL bRetry=NO;
	
	do
	{
		++nTries;
		
		DLog(@"%@ URL:%@",method,[url absoluteString]);
		[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;

		NSData* rspdata=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];

		[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;

		if (responseData)
			*responseData=rspdata;

		if (rspdata) {
			DLog(@"Response code:%d",[response statusCode]);
			DLog(@"Response data:%.*s", [rspdata length], [rspdata bytes]);
			
			bRetry=NO;
			int statuscode=[response statusCode];
			if (statuscode==420)
			{
				if (nTries < 2) // Don't retry over and over, just do it once
				{
					if ([self login]==YES)
					{
						bRetry=YES; // Successfully logged in, retry original request
					}
				}
			}
			else if (statuscode==200)
			{
			}
		} else {
			// TODO: inform the user that the download could not be made
		}	
	}
	while (bRetry);

	return response;
}

-(NSDictionary*)getFlavorsDictionary
{
	// TODO: If the file is older than 7 days and we have good network connectivity (WiFi), ask the server for a newer version using If-Modified-Since
	
	if (flavorsDictionary==nil)
	{
		NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
		NSString* filename=[[paths objectAtIndex:0] stringByAppendingString:@"/flavors.dict"];
		
		flavorsDictionary=[[NSMutableDictionary alloc] initWithContentsOfFile:filename];
		if (flavorsDictionary==nil)
		{
			flavorsDictionary=[[NSMutableDictionary alloc] initWithCapacity:128];
			
			// Download the Flavors & Aromas doc from server
			BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_GET_FLAVORS_DOC];
			NSData* answer;
			NSHTTPURLResponse* response=[del sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
			if ([response statusCode]==200)
			{
				NSXMLParser* parser=[[[NSXMLParser alloc] initWithData:answer] autorelease];
				[parser setDelegate:self];
				[parser parse];
				
				[flavorsDictionary writeToFile:filename atomically:YES];
			}
			else
			{
				// TODO: handle this gracefully
			}
		}
	}
	
	return flavorsDictionary;
}

-(NSDictionary*)getStylesDictionary
{
	// TODO: If the file is older than 7 days and we have good network connectivity (WiFi), ask the server for a newer version using If-Modified-Since

	if (stylesDictionary==nil)
	{
		stylesDictionary=[[NSMutableDictionary alloc] initWithCapacity:2];

		[self.stylesDictionary setObject:[[NSMutableArray alloc] initWithCapacity:32] forKey:@"list"];
		[self.stylesDictionary setObject:[[NSMutableDictionary alloc] initWithCapacity:32] forKey:@"names"];

		// Get styles list from server
		NSData* answer;
		NSHTTPURLResponse* response=[self sendRequest:[NSURL URLWithString:BEERCRUSH_API_URL_GET_STYLESLIST] usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSXMLParser* parser=[[[NSXMLParser alloc] initWithData:answer] autorelease];
			parser.delegate=self;
			[parser parse];
		}
		else
		{
			// TODO: handle this gracefully
		}
	}
	
	return stylesDictionary;
}

-(NSHTTPURLResponse*)postBeerReview:(NSDictionary*)userReview returningData:(NSData**)answer
{
	// Post the review
	NSMutableArray* values=[NSMutableArray arrayWithCapacity:10];
	if (values)
	{
		[values addObject:[NSString stringWithFormat:@"beer_id=%@",	[userReview objectForKey:@"beer_id"]]];
		[values addObject:[NSString stringWithFormat:@"rating=%@",	[userReview objectForKey:@"rating"]]];
		[values addObject:[NSString stringWithFormat:@"body=%@",	[userReview objectForKey:@"body"]]];
		[values addObject:[NSString stringWithFormat:@"aftertaste=%@",[userReview objectForKey:@"aftertaste"]]];
		[values addObject:[NSString stringWithFormat:@"balance=%@",[userReview objectForKey:@"balance"]]];
		if ([userReview objectForKey:@"comments"])
			[values addObject:[NSString stringWithFormat:@"comments=%@",[userReview objectForKey:@"comments"]]];
		
		NSArray* flavors=[userReview objectForKey:@"flavors"];
		if (flavors)
			[values addObject:[NSString stringWithFormat:@"flavors=%@",[flavors componentsJoinedByString:@" "]]];
		
		NSString* bodystr=[values componentsJoinedByString:@"&"];
		
		NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_POST_BEER_REVIEW];
		return [self sendRequest:url usingMethod:@"POST" withData:bodystr returningData:answer];
	}
	return nil;
}

-(void)setOnBeerSelectedAction:(SEL)s target:(id)t
{
	self.onBeerSelectedAction=s;
	self.onBeerSelectedTarget=t;
}

-(BOOL)onBeerSelected:(id)obj
{
	if ([onBeerSelectedTarget respondsToSelector:onBeerSelectedAction])
	{
		[onBeerSelectedTarget performSelector:onBeerSelectedAction withObject:obj];
		return YES;
	}
	return NO;
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
		DLog(@"Headers:");
		NSDictionary* hdrdict=[httprsp allHeaderFields];
		NSArray* headers=[hdrdict allKeys];
		for (NSUInteger i=0;i<[headers count];++i)
		{
			DLog(@"%@:%@",[headers objectAtIndex:i],[hdrdict objectForKey:[headers objectAtIndex:i]]);
		}
		// TODO: alert the user that the login failed
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Check username and password in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
//		DLog(@"Login failed.");
	}
	else
	{
		DLog(@"Login successful.");
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
    DLog(@"Login failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
//    DLog(@"Succeeded! Received %d bytes of data",[reviewPostResponse length]);
	DLog(@"Login response:%s",(char*)[xmlPostResponse mutableBytes]);
	
    // release the connection, and the data object
    [connection release];
//    [reviewPostResponse release];
}

/*
 
 Sample styles doc:
 
 <styles>
 <style num="1">
 <name>Light Lager</name>
 <style num="1A">
 <name>Light American Lager</name>
 </style>
 <style num="1B">
 <name>Standard American Lager</name>
 </style>
 <style num="1C">
 <name>Premium American Lager</name>
 </style>
 <style num="1D">
 <name>Munich Helles</name>
 </style>
 <style num="1E">
 <name>Dortmunder Export</name>
 </style>
 </style>
 <style num="2">
 <name>Pilsner</name>
 <style num="2A">
 <name>German Pilsner</name>
 </style>
 <style num="2B">
 <name>Boehmian Pilsner</name>
 </style>
 <style num="2C">
 <name>Classic American Pilsner</name>
 </style>
 </style>
 <style num="3">
 <name>European Amber Lager</name>
 <style num="3A">
 <name>Vienna Lager</name>
 </style>
 <style num="3B">
 <name>Oktoberfest/Maerzen</name>
 </style>
 </style>
 </styles>
 
 */


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	[self.currentElemValue release];
	self.currentElemValue=nil;
	self.currentElemID=nil;
	xmlParserPath=[[NSMutableArray alloc] initWithCapacity:5]; // This also releases a previous xmlParserPath
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.currentElemValue release];
	self.currentElemValue=nil;
	self.currentElemID=nil;
	xmlParserPath=nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"title"])
	{
		// Is it the /flavors/group/title element?
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",nil]])
		{
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	else if ([elementName isEqualToString:@"flavor"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",@"flavors",nil]]) // Is it the /flavors/group/flavors/flavor element?
		{
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
			self.currentElemID=[[attributeDict objectForKey:@"id"] copy];
		}
	}
	else if ([elementName isEqualToString:@"style"])
	{
		if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",nil]])
		{
			[[self.stylesDictionary objectForKey:@"list"] addObject:[NSMutableArray arrayWithCapacity:5]];
			//			[self.stylesList addObject:[attributeDict objectForKey:@"num"]];
		}
		else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",@"style",nil]])
		{
			[[[self.stylesDictionary objectForKey:@"list"] lastObject] addObject:[attributeDict objectForKey:@"num"]];
		}
	}
	else if ([elementName isEqualToString:@"name"])
	{
		if ([[xmlParserPath lastObject] isEqualToString:@"style"])
		{
			[self.currentElemValue release];
			self.currentElemValue=[[NSMutableString alloc] initWithCapacity:64];
		}
	}
	
	[xmlParserPath addObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[xmlParserPath removeLastObject];
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"title"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",nil]]) // Is it the /flavors/group/title element?
			{
				if ([flavorsDictionary objectForKey:@"titles"]==nil)
					[flavorsDictionary setObject:[NSMutableArray arrayWithCapacity:24] forKey:@"titles"];
				[[flavorsDictionary objectForKey:@"titles"] addObject:currentElemValue];
				
				// Add an array in groups for this title
				if ([flavorsDictionary objectForKey:@"groups"]==nil)
					[flavorsDictionary setObject:[NSMutableArray arrayWithCapacity:24] forKey:@"groups"];
				[[flavorsDictionary objectForKey:@"groups"] addObject:[[NSMutableArray alloc] initWithCapacity:10]];
			}
		}
		else if ([elementName isEqualToString:@"flavor"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"flavors",@"group",@"flavors",nil]]) // Is it the /flavors/group/flavors/flavor element?
			{
				if ([flavorsDictionary objectForKey:@"byid"]==nil)
					[flavorsDictionary setObject:[NSMutableDictionary dictionaryWithCapacity:128] forKey:@"byid"];
				[[flavorsDictionary objectForKey:@"byid"] setObject:currentElemValue forKey:currentElemID];

				[[[flavorsDictionary objectForKey:@"groups"] lastObject] addObject:currentElemID];
			}
		}
		else if ([elementName isEqualToString:@"style"])
		{
		}
		else if ([elementName isEqualToString:@"name"])
		{
			if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",@"style",nil]])
			{
				[[self.stylesDictionary objectForKey:@"names"] setObject:self.currentElemValue forKey:[NSString stringWithFormat:@"%d",[[self.stylesDictionary objectForKey:@"list"] count]]];
			}
			else if ([xmlParserPath isEqualToArray:[NSArray arrayWithObjects:@"styles",@"style",@"style",nil]])
			{
				[[self.stylesDictionary objectForKey:@"names"] setObject:self.currentElemValue forKey:[[[self.stylesDictionary objectForKey:@"list"] lastObject] lastObject]];
			}
		}
		
		self.currentElemValue=nil;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self.currentElemValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}



@end


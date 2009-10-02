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
#import "UserProfileTVC.h"
#import "BuddiesTVC.h"
#import "RecommendedTVC.h"
#import "BookmarksTVC.h"
#import "PlacesTVC.h"
#import "JSON.h"
#import "SearchVC.h"

// Unique numbers to identify the tabs (they are not necessarily in this order)
#define kTabBarItemTagBeers 1
#define kTabBarItemTagPlaces 2
#define kTabBarItemTagNearby 3
#define kTabBarItemTagMyBeerReviews 4
#define kTabBarItemTagWishList 5
#define kTabBarItemTagMyPlaces 6
#define kTabBarItemTagProfile 7
#define kTabBarItemTagBuddies 8
#define kTabBarItemTagRecommended 9
#define kTabBarItemTagBookmarks 10

#pragma mark Utility functions

void normalizeToString(NSMutableDictionary* dict,NSString* key)
{
	if ([dict objectForKey:key]==nil)
	{
		[dict setObject:@"" forKey:key];
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSString class]])
	{
		// Do nothing, it's already a valid string
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSArray class]])
	{
		NSArray* a=[dict objectForKey:key];
		if ([a count])
			[dict setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:key]] forKey:key];
		else
			[dict setObject:@"" forKey:key];
	}
	else
		[dict setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:key]] forKey:key];
}

void normalizeToNumber(NSMutableDictionary* dict,NSString* key)
{
	if ([dict objectForKey:key]==nil)
	{
		[dict setObject:[NSNumber numberWithInt:0] forKey:key];
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSNumber class]])
	{
		// Do nothing, it's already a number
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSString class]])
	{
		[dict setObject:[NSNumber numberWithInt:[[dict objectForKey:key] intValue]] forKey:key];
	}
	else
	{
		[dict setObject:[NSNumber numberWithInt:0] forKey:key];
	}
}

void normalizeToBoolean(NSMutableDictionary* dict,NSString* key)
{
	if ([dict objectForKey:key]==nil)
	{
		[dict setObject:[NSNumber numberWithInt:0] forKey:key];
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSString class]])
	{
		[dict setObject:[NSNumber numberWithInt:[[dict objectForKey:key] boolValue]?1:0] forKey:key];
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSNumber class]])
	{
		[dict setObject:[NSNumber numberWithInt:[[dict objectForKey:key] boolValue]?1:0] forKey:key];
	}
	else
		[dict setObject:[NSNumber numberWithInt:0] forKey:key];
}

void normalizeToArray(NSMutableDictionary* data, NSString* key, NSUInteger n)
{
	if ([data objectForKey:key]==nil)
		[data setObject:[NSMutableArray arrayWithCapacity:n] forKey:key];
}

void normalizeToDictionary(NSMutableDictionary* data, NSString* key, NSUInteger n)
{
	if ([data objectForKey:key]==nil)
		[data setObject:[NSMutableDictionary dictionaryWithCapacity:n] forKey:key];
}

NSMutableArray* appendDifferentValuesToArray(NSArray* keyNames,NSDictionary* orig,NSDictionary* curr)
{
	NSMutableArray* values=[[[NSMutableArray alloc] init] autorelease];
	for (NSString* keyName in keyNames)
	{
		NSDictionary* origDict=orig;
		NSDictionary* currDict=curr;
		
		NSArray* parts=[keyName componentsSeparatedByString:@":"];
		for (NSUInteger i=1;i < [parts count];++i)
		{
			origDict=[origDict objectForKey:[parts objectAtIndex:i-1]];
			currDict=[currDict objectForKey:[parts objectAtIndex:i-1]];
		}
		
		NSObject* origObj=[origDict objectForKey:[parts objectAtIndex:[parts count]-1]];
		NSObject* currObj=[currDict objectForKey:[parts objectAtIndex:[parts count]-1]];
		
		if ([origObj class] == [currObj class])
		{
			if ([origObj isKindOfClass:[NSString class]])
			{
				NSString* origString=(NSString*)origObj;
				NSString* currString=(NSString*)currObj;
				if ([origString isEqualToString:currString]==NO)
				{
					[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,currString]];
				}
			}
			else if ([origObj isKindOfClass:[NSNumber class]])
			{
				NSNumber* origNumber=(NSNumber*)origObj;
				NSNumber* currNumber=(NSNumber*)currObj;
				if ([origNumber intValue] != [currNumber intValue])
				{
					[values addObject:[NSString stringWithFormat:@"%@=%d",keyName,[currNumber intValue]]];
				}
			}
			else if ([origObj isKindOfClass:[NSArray class]])
			{
				NSArray* origArr=(NSArray*)origObj;
				NSArray* currArr=(NSArray*)currObj;
				if ([origArr isEqualToArray:currArr]==NO)
				{
					[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,[currArr componentsJoinedByString:@" "]]];
				}
			}
			else {
				// What to do?
			}
		}
		else {
			[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,currObj]];
		}
	}
	
	return values;
}

void normalizeBeerData(NSMutableDictionary* beerData)
{
	normalizeToString(beerData, @"name");
	normalizeToString(beerData, @"description");
	normalizeToString(beerData, @"grains");
	normalizeToString(beerData, @"hops");
	normalizeToString(beerData, @"availability");
	
	normalizeToArray(beerData, @"styles", 3);
	normalizeToDictionary(beerData, @"@attributes", 5);
	
	normalizeToString([beerData objectForKey:@"@attributes"], @"abv");
	normalizeToString([beerData objectForKey:@"@attributes"], @"ibu");
	normalizeToString([beerData objectForKey:@"@attributes"], @"og");
	normalizeToString([beerData objectForKey:@"@attributes"], @"fg");
	normalizeToString([beerData objectForKey:@"@attributes"], @"srm");
}

void normalizePlaceData(NSMutableDictionary* placeData)
{
	normalizeToString(placeData, @"name");
	normalizeToString(placeData, @"description");
	normalizeToString(placeData, @"phone");
	normalizeToString(placeData, @"placestyle");
	normalizeToString(placeData, @"placetype");
	normalizeToString(placeData, @"uri");
	normalizeToBoolean(placeData, @"kid_friendly");
	
	if ([placeData objectForKey:@"hours"]==nil)
		[placeData setObject:[NSMutableDictionary dictionaryWithCapacity:3] forKey:@"hours"];
	normalizeToString([placeData objectForKey:@"hours"], @"open");
	
	if ([placeData objectForKey:@"restaurant"]==nil)
		[placeData setObject:[NSMutableDictionary dictionaryWithCapacity:3] forKey:@"restaurant"];
	
	normalizeToNumber([placeData objectForKey:@"restaurant"],@"price_range");
	normalizeToBoolean([placeData objectForKey:@"restaurant"], @"outdoor_seating");
	normalizeToString([placeData objectForKey:@"restaurant"],@"food_description");
	
	if ([placeData objectForKey:@"@attributes"]==nil)
		[placeData setObject:[NSMutableDictionary dictionaryWithCapacity:3] forKey:@"@attributes"];
	
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"wifi");
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"bottled_beer_to_go");
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"growlers_to_go");
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"kegs_to_go");
	
	if ([placeData objectForKey:@"address"]==nil)
		[placeData setObject:[NSMutableDictionary dictionaryWithCapacity:5] forKey:@"address"];
	
	normalizeToString([placeData objectForKey:@"address"], @"street");
	normalizeToString([placeData objectForKey:@"address"], @"city");
	normalizeToString([placeData objectForKey:@"address"], @"state");
	normalizeToString([placeData objectForKey:@"address"], @"zip");
	normalizeToString([placeData objectForKey:@"address"], @"country");
}

void normalizePlaceReviewData(NSMutableDictionary* placeReviewData)
{
	// TODO: implement this
}

void normalizeBreweryData(NSMutableDictionary* data)
{
	normalizeToString(data, @"name");
	normalizeToString(data, @"description");
	normalizeToString(data, @"phone");
	normalizeToString(data, @"uri");
	normalizeToString(data, @"tourinfo");
	normalizeToString(data, @"tasting");
	normalizeToString(data, @"hours");
	
	if ([data objectForKey:@"togo"]==nil)
		[data setObject:[NSMutableDictionary dictionaryWithCapacity:3] forKey:@"togo"];
	normalizeToBoolean([data objectForKey:@"togo"], @"bottled_beer");
	normalizeToBoolean([data objectForKey:@"togo"], @"growlers");
	normalizeToBoolean([data objectForKey:@"togo"], @"kegs");
	
	if ([data objectForKey:@"address"]==nil)
		[data setObject:[NSMutableDictionary dictionaryWithCapacity:5] forKey:@"address"];
	normalizeToString([data objectForKey:@"address"], @"street");
	normalizeToString([data objectForKey:@"address"], @"city");
	normalizeToString([data objectForKey:@"address"], @"state");
	normalizeToString([data objectForKey:@"address"], @"zip");
	normalizeToString([data objectForKey:@"address"], @"country");
}


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

@synthesize activityHUD;
@synthesize sharedOperationQueue;
@synthesize window;
@synthesize loginVC;
@synthesize tabBarController;
@synthesize onBeerSelectedAction;
@synthesize onBeerSelectedTarget;
@synthesize flavorsDictionary;
@synthesize stylesDictionary;
@synthesize colorsDictionary;
@synthesize placeStylesDictionary;
@synthesize restoringNavState;
@synthesize appState;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	// Create the sharedOperationQueue to use for async operations
	self.sharedOperationQueue=[[NSOperationQueue alloc] init];
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
		loginVC=nil; // releases it too
	}
	
//	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//	button.frame = CGRectMake(290, 400, 20, 20);
//	[button.titleLabel setFont:[UIFont fontWithName:@"Georgia-BoldItalic" size:14]];
//	[button setTitle:@"i" forState:UIControlStateNormal];
//	[button addTarget:self action:@selector(showAboutUs) forControlEvents:UIControlEventTouchUpInside];
//
//	[self.window addSubview:button];

//	tabBarController.viewControllers=[NSArray arrayWithObjects:
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  [[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease],
//									  nil];
	
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	
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

	// This determines the default order that the tabs appear
	int tabOrder[]={
		kTabBarItemTagBeers,
		kTabBarItemTagPlaces,
		kTabBarItemTagNearby,
		kTabBarItemTagWishList,
		kTabBarItemTagMyBeerReviews,
		kTabBarItemTagMyPlaces,
		kTabBarItemTagProfile,
		kTabBarItemTagBuddies,
		kTabBarItemTagRecommended,
		kTabBarItemTagBookmarks
	};
	
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
		
		NSArray* customTabOrder=[self.restoringNavState objectForKey:@"taborder"];
		if (customTabOrder)
		{
			int i=0;
			for (NSNumber* n in customTabOrder)
			{
				tabOrder[i++]=[n integerValue];
			}
		}
		else // Use default tab order
		{
			// Do nothing, just use it as set above
		}
	}
	
	
	// Create a new appstate dictionary to store the app's state as it runs
	self.appState=[[NSMutableDictionary alloc] init];
	NSMutableArray* stacks=[NSMutableArray arrayWithCapacity:(sizeof(tabOrder)/sizeof(tabOrder[0]))];
	for (int i=0;i<(sizeof(tabOrder)/sizeof(tabOrder[0]));++i)
	{
		[stacks addObject:[NSMutableArray arrayWithCapacity:10]];
	}
	[self.appState setObject:stacks forKey:@"navstacks"];

	NSMutableArray* tabBarControllers=[NSMutableArray arrayWithCapacity:(sizeof(tabOrder)/sizeof(tabOrder[0]))];
	
	for (size_t tabBarControllerIndex=0; tabBarControllerIndex < (sizeof(tabOrder)/sizeof(tabOrder[0]));++tabBarControllerIndex)
	{
		switch (tabOrder[tabBarControllerIndex]) {
			case kTabBarItemTagBeers:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Beers" image:[UIImage imageNamed:@"tab_beers.png"] tag:kTabBarItemTagBeers] autorelease];
				SearchVC* svc=[[[SearchVC alloc] init] autorelease];
				svc.searchTypes=BeerCrushSearchTypeBeers|BeerCrushSearchTypeBreweries; // Search both beers and breweries
				[nc pushViewController:svc animated:NO];
				break;
			}
			case kTabBarItemTagPlaces:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Places" image:[UIImage imageNamed:@"tab_places.png"] tag:kTabBarItemTagPlaces] autorelease];
				SearchVC* svc=[[[SearchVC alloc] init] autorelease];
				svc.searchTypes=BeerCrushSearchTypePlaces; // Search only Places
				[nc pushViewController:svc animated:NO];
				break;
			}
			case kTabBarItemTagNearby:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Nearby" image:[UIImage imageNamed:@"tab_nearby.png"] tag:kTabBarItemTagNearby] autorelease];
				NearbyTableViewController* ntvc=[[NearbyTableViewController alloc] initWithStyle: UITableViewStylePlain];
				[nc pushViewController:ntvc animated:NO ];
				break;
			}
			case kTabBarItemTagWishList:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Wish List" image:[UIImage imageNamed:@"tab_wishlist.png"] tag:kTabBarItemTagWishList] autorelease];
				BeerListTableViewController* bltvc=[[[BeerListTableViewController alloc] initWithBreweryID:[NSString stringWithFormat:@"wishlist:%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]]] autorelease];
				[nc pushViewController:bltvc animated:NO];
				break;
			}
			case kTabBarItemTagMyBeerReviews:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"My Beers" image:[UIImage imageNamed:@"tab_beerreviews.png"] tag:kTabBarItemTagMyBeerReviews] autorelease];
				UserReviewsTVC* urtvc=[[[UserReviewsTVC alloc] initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:urtvc animated:NO];
				break;
			}
			case kTabBarItemTagMyPlaces:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"My Places" image:[UIImage imageNamed:@"beer.png"] tag:kTabBarItemTagMyPlaces] autorelease];
				PlacesTVC* bltvc=[[[PlacesTVC alloc] initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:bltvc animated:NO];
				break;
			}
			case kTabBarItemTagProfile:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"beer.png"] tag:kTabBarItemTagProfile] autorelease];
				UserProfileTVC* uptvc=[[[UserProfileTVC alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
				[nc pushViewController:uptvc animated:NO];
				break;
			}
			case kTabBarItemTagBuddies:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Buddies" image:[UIImage imageNamed:@"beer.png"] tag:kTabBarItemTagBuddies] autorelease];
				BuddiesTVC* btvc=[[[BuddiesTVC alloc] initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:btvc animated:NO];
				break;
			}
			case kTabBarItemTagRecommended:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Recommended" image:[UIImage imageNamed:@"beer.png"] tag:kTabBarItemTagRecommended] autorelease];
				RecommendedTVC* rtvc=[[[RecommendedTVC alloc]  initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:rtvc animated:NO];
				break;
			}
			case kTabBarItemTagBookmarks:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:kTabBarItemTagBookmarks] autorelease];
				BookmarksTVC* btvc=[[[BookmarksTVC alloc]  initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:btvc animated:NO];
				break;
			}
			default:
				// Shouldn't happen
				break;
		}
	}
	
	tabBarController.viewControllers=tabBarControllers;
	tabBarController.delegate=self;
	
	if (self.restoringNavState)
	{
		// We don't need to test if 'selectedtabtag' is there, it'll just set it to the 0-th controller anyway
		NSInteger tag=[(NSNumber*)[self.restoringNavState valueForKey:@"selectedtabtag"] integerValue];
		// Find the viewcontroller with the tabbaritem that has this tag
		for (UIViewController* vc in self.tabBarController.viewControllers) {
			if (tag == vc.tabBarItem.tag)
			{
				tabBarController.selectedViewController=vc;
				break;
			}
		}
	}

}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
	if (changed)
	{
		NSMutableArray* newTabOrder=[NSMutableArray arrayWithCapacity:10];
		for (UIViewController* vc in viewControllers)
		{
			[newTabOrder addObject:[NSNumber numberWithInt:vc.tabBarItem.tag]];
		}
		// Save it in appState
		[self.appState setObject:newTabOrder forKey:@"taborder"];
	}
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	// Save the current app state
	NSInteger tag=self.tabBarController.selectedViewController.tabBarItem.tag;
//	[NSNumber numberWithUnsignedInt:[self.tabBarController.viewControllers indexOfObjectIdenticalTo:[self.tabBarController selectedViewController]]];
	[self.appState setValue:[NSNumber numberWithInt:tag] forKey:@"selectedtabtag"];
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
	if (idx >= [stacks count])
		return NO;
	
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
	if (data)
	{
		NSUInteger idx=0;
		for (UIViewController* vc in self.tabBarController.viewControllers)
		{
			if (vc.tabBarItem.tag==tabBarItem.tag)
			{	// Found it
				NSMutableArray* stacks=[self.appState objectForKey:@"navstacks"];
				if (idx < [stacks count])
				{
					[[stacks objectAtIndex:idx] addObject:data];
					return YES;
				}
				break;
			}
			++idx;
		}
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
	[self.activityHUD release];
	[sharedOperationQueue release];
	
    [tabBarController release];
    [window release];
	[flavorsDictionary release];

	[loginVC release];
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
	NSString* bodystr=[[[NSString alloc] initWithFormat:@"userid=%@&password=%@", userid, password] autorelease];
	NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];

	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_LOGIN]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:60.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:body];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// create the connection with the request and start loading the data
	NSHTTPURLResponse* response;
	NSError* error;

	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	NSData* respdata=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;

	DLog(@"status code=%d",[response statusCode]);
	if ([response statusCode]==200)
	{
		DLog(@"Login successful");
		// We don't care about any response document, we just want the cookies to be stored (automatically)
		DLog(@"Response data:%.*s", [respdata length], [respdata bytes]);
		return YES;
	} else {
		DLog(@"Login failed.");
		return NO;
	}	

}

-(NSHTTPURLResponse*)sendJSONRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSObject*)data returningJSON:(NSMutableDictionary**)jsonResponse
{
	NSData* answer;
	NSHTTPURLResponse* response=[self sendRequest:url usingMethod:method withData:data returningData:&answer];
	if ([response statusCode]==200)
	{
		NSString* s=[[[NSString alloc] initWithData:answer encoding:NSUTF8StringEncoding] autorelease];
		if (jsonResponse)
			*jsonResponse=[s JSONValue];
	}
	return response;
}

-(NSHTTPURLResponse*)sendRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSObject*)data returningData:(NSData**)responseData
{
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url 
													cachePolicy:NSURLRequestUseProtocolCachePolicy
													timeoutInterval:30.0];
	
	if ([method isEqualToString:@"POST"])
	{
		if (data)
		{
			if ([data isKindOfClass:[NSString class]])
			{
				NSString* stringData=(NSString*)data;
				DLog(@"POST data:%@",data);
				NSData* body=[NSData dataWithBytes:[stringData UTF8String] length:[stringData length]];
				[theRequest setHTTPBody:body];
				[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
			}
			else if ([data isKindOfClass:[NSData class]])
			{
				NSData* dataData=(NSData*)data;
				// The following code based on http://iphone.zcentric.com/?p=218
				/*
				 add some header info now
				 we always need a boundary when we post a file
				 also we need to set the content type
				 
				 You might want to generate a random boundary.. this is just the same 
				 as my output from wireshark on a valid html post
				 */
				NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
				NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
				[theRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
				
				/*
				 now lets create the body of the post
				 */
				NSMutableData *body = [NSMutableData data];
				[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];	
				[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
				[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
				[body appendData:[NSData dataWithData:dataData]];
				[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
				// setting the body of the post to the reqeust
				[theRequest setHTTPBody:body];
			}
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
		NSString* filename=[[paths objectAtIndex:0] stringByAppendingString:@"/flavors.plist"];
		
		flavorsDictionary=nil;
//		flavorsDictionary=[[NSMutableDictionary alloc] initWithContentsOfFile:filename]; TODO: re-enable this when we're ready to cache data
		if (flavorsDictionary==nil)
		{
			flavorsDictionary=[[NSMutableDictionary alloc] initWithCapacity:128];
			
			// Download the Flavors & Aromas doc from server
			BeerCrushAppDelegate* del=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_GET_FLAVORS_DOC];
			NSMutableDictionary* answer;
			NSHTTPURLResponse* response=[del sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
			if ([response statusCode]==200)
			{
				self.flavorsDictionary=answer;
				// Make flavors byid dictionary
				NSMutableDictionary* byidDict=[[[NSMutableDictionary alloc] initWithCapacity:[[self.flavorsDictionary objectForKey:@"flavors"] count]] autorelease];
				[self.flavorsDictionary setObject:byidDict forKey:@"byid"];
				for (NSDictionary* flavor in [self.flavorsDictionary objectForKey:@"flavors"])
				{
					NSArray* subflavors=[flavor objectForKey:@"flavors"];
					for (NSDictionary* subflavor in subflavors)
					{
						[byidDict setObject:subflavor forKey:[subflavor objectForKey:@"id"]];
					}
				}
				
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

void recursivelyGetBeerStyleIDs(NSArray* fromArray, NSMutableDictionary* toDict)
{
	if (fromArray==nil)
		return;
	
	for (NSDictionary* styleInfo in fromArray)
	{
		[toDict setObject:styleInfo forKey:[styleInfo objectForKey:@"id"]];
		recursivelyGetBeerStyleIDs([styleInfo objectForKey:@"styles"],toDict);
	}
}

-(NSDictionary*)getStylesDictionary
{
	// TODO: If the file is older than 7 days and we have good network connectivity (WiFi), ask the server for a newer version using If-Modified-Since

	if (stylesDictionary==nil)
	{
		// Get styles list from server
		NSMutableDictionary* answer;
		NSHTTPURLResponse* response=[self sendJSONRequest:[NSURL URLWithString:BEERCRUSH_API_URL_GET_STYLESLIST] usingMethod:@"GET" withData:nil returningJSON:&answer];
		if ([response statusCode]==200)
		{
			self.stylesDictionary=answer;
			[self.stylesDictionary setObject:[[[NSMutableDictionary alloc] initWithCapacity:32] autorelease] forKey:@"names"];
			recursivelyGetBeerStyleIDs([self.stylesDictionary objectForKey:@"styles"], [self.stylesDictionary objectForKey:@"names"]);
		}
		else
		{
			// TODO: handle this gracefully
		}
	}
	
	return stylesDictionary;
}

-(NSDictionary*)getColorsDictionary
{
	if (self.colorsDictionary==nil)
	{
		NSData* answer;
		NSHTTPURLResponse* response=[self sendRequest:[NSURL URLWithString:BEERCRUSH_API_URL_GET_COLORSLIST] usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSString* s=[[[NSString alloc] initWithData:answer encoding:NSUTF8StringEncoding] autorelease];
			self.colorsDictionary=[NSMutableDictionary dictionaryWithDictionary:[s JSONValue]];
			
			// Make colornamebysrm key
			[self.colorsDictionary setObject:[NSMutableDictionary dictionaryWithCapacity:12] forKey:@"colornamebysrm"];
			for (NSDictionary* colorInfo in [self.colorsDictionary objectForKey:@"colors"])
			{
				[[self.colorsDictionary objectForKey:@"colornamebysrm"] setObject:colorInfo forKey:[[colorInfo objectForKey:@"@attributes"] objectForKey:@"srm"]];
			}
		}
		else
		{
			// TODO: alert the user
		}
	}

	return self.colorsDictionary;
}

void recursivelyGetPlaceStyleIDs(NSDictionary* fromDict, NSMutableDictionary* toDict)
{
	for (NSDictionary* category in [fromDict objectForKey:@"categories"]) 
	{
		if ([category objectForKey:@"id"])
		{
			[toDict setObject:category forKey:[category objectForKey:@"id"]];
		}
		
		if ([category objectForKey:@"categories"])
		{
			recursivelyGetPlaceStyleIDs(category, toDict);
		}
	}
}

-(NSDictionary*)getPlaceStylesDictionary
{
	if (self.placeStylesDictionary==nil)
	{
		NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URI_GET_PLACE_STYLES];
		NSData* answer;
		NSHTTPURLResponse* response=[self sendRequest:url usingMethod:@"GET" withData:nil returningData:&answer];
		if ([response statusCode]==200)
		{
			NSString* s=[[[NSString alloc] initWithData:answer encoding:NSUTF8StringEncoding] autorelease];
			self.placeStylesDictionary=[s JSONValue];
			
			// Create the 'byid' dictionary
			NSMutableDictionary* byid=[[[NSMutableDictionary alloc] initWithCapacity:30] autorelease];
			
			recursivelyGetPlaceStyleIDs(self.placeStylesDictionary,byid);
			
			[self.placeStylesDictionary setObject:byid forKey:@"byid"];
			
		}
	}
	return self.placeStylesDictionary;
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

-(NSMutableDictionary*)getBeerDoc:(NSString*)beerID
{
	// TODO: support caching
	
	// Separate the brewery ID and the beer ID from the beerID
	NSArray* idparts=[beerID componentsSeparatedByString:@":"];
	
	// Retrieve JSON doc for this beer
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_DOC, [idparts objectAtIndex:1], [idparts objectAtIndex:2] ]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		normalizeBeerData(answer);
		[answer retain];
		return answer;
	}
	else {
		// TODO: alert the user
		DLog(@"Response status code=%d",[response statusCode]);
	}

	return nil;
}

-(NSMutableDictionary*)getReviewsOfBeer:(NSString*)beerID byUserID:(NSString*)userID
{
	// TODO: support caching

	// Separate the brewery ID and the beer ID from the beerID
	NSArray* idparts=[beerID componentsSeparatedByString:@":"];

	// Retrieve user's review for this beer
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC, 
							  [idparts objectAtIndex:1], 
							  [idparts objectAtIndex:2], 
							  userID]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		[answer retain];
		return answer;
	}
	else {
		// TODO: alert the user
		DLog(@"Response status code=%d",[response statusCode]);
	}
	return nil;
}

-(NSMutableDictionary*)getBeerReviewsByUser:(NSString*)userID seqNum:(NSNumber*)seqNum
{
	NSMutableDictionary* answer=nil;
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_BEER_REVIEWS_DOC, userID, seqNum]];
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		return answer;
	}
	return nil;
}

-(NSString*)breweryNameFromBeerID:(NSString*)beer_id
{
	NSArray* parts=[beer_id componentsSeparatedByString:@":"];
	NSMutableDictionary* doc=[self getBreweryDoc:[parts objectAtIndex:1]];
	NSObject* s=[doc objectForKey:@"name"];
	if (s && [s isKindOfClass:[NSString class]])
		return (NSString*)s;
	return @"";
}

-(NSMutableDictionary*)getBreweryDoc:(NSString*)breweryID
{
	// TODO: support caching
	NSArray* parts=[breweryID componentsSeparatedByString:@":"];
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_DOC_JSON,[parts lastObject]]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		normalizeBreweryData(answer);
		return answer;
	}
	
	return nil;
}

-(NSMutableDictionary*)getPlaceDoc:(NSString*)placeID
{
	// Separate the 2 parts of the place ID
	NSArray* idparts=[placeID componentsSeparatedByString:@":"];
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_PLACE_DOC, [idparts objectAtIndex:1]]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		normalizePlaceData(answer);
		return answer;
	}
	return nil;
}

-(NSMutableDictionary*)getPlaceReviews:(NSString*)placeID byUser:(NSString*)user_id
{
	// Separate the 2 parts of the place ID
	NSArray* idparts=[placeID componentsSeparatedByString:@":"];
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_PLACE_REVIEW_DOC, 
							  [idparts objectAtIndex:1], 
							  user_id]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		normalizePlaceReviewData(answer);
		return answer;
	}
	return nil;
}

-(NSMutableDictionary*)getReviewsForDocID:(NSString*)docid
{
	// Separate the parts of the reviewedDocID to determine what kind of doc it is
	NSArray* idparts=[docid componentsSeparatedByString:@":"];
	
	NSURL* url=nil;
	if ([[idparts objectAtIndex:0] isEqualToString:@"beer"])
	{	// Retrieve XML doc for this beer
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_ALL_BEER_REVIEWS_DOC, 
								  [idparts objectAtIndex:1],
								  [idparts objectAtIndex:2],
								  0]];
	}
	else if ([[idparts objectAtIndex:0] isEqualToString:@"place"]) 
	{ // Retrieve XML doc for this place
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_ALL_PLACE_REVIEWS_DOC, 
								  [idparts objectAtIndex:1],
								  0]];
	}
	
	if (url)
	{
		NSMutableDictionary* answer;
		NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
		if ([response statusCode]==200)
		{
			return answer;
		}
	}
	
	return nil;
}

-(NSMutableDictionary*)getBreweriesList
{
	// Get list of breweries from the server
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_GET_ALL_BREWERIES_DOC];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		return answer;
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

-(void)dismissActivityHUD
{ 
	[self.activityHUD show:NO];
	[self.activityHUD release];
	self.activityHUD=nil;
} 

-(void)presentActivityHUD:(NSString*)hudText
{ 
	// UIProgressHUD is undocumented by Apple. If you get screwed, try this instead: http://www.bukovinski.com/2009/04/08/mbprogresshud-for-iphone/
	if (self.activityHUD==nil)
		self.activityHUD = [[UIProgressHUD alloc] initWithWindow:self.tabBarController.selectedViewController.view];
	[self.activityHUD setText:hudText]; 
	[self.activityHUD show:YES]; 
}

-(void)performAsyncOperationWithTarget:(id)target selector:(SEL)sel object:(id)object withActivityHUD:(BOOL)withActivityHUD andActivityHUDText:(NSString*)hudText
{
	if (withActivityHUD)
		[self presentActivityHUD:hudText];
	NSInvocationOperation* op=[[[NSInvocationOperation alloc] initWithTarget:target selector:sel object:object] autorelease];
	[self.sharedOperationQueue addOperation:op];
}

@end


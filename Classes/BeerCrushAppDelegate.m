//
//  BeerCrushAppDelegate.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
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

@implementation UIColor (BeerCrush)

+(UIColor*)beercrushLightTanColor 	{return [UIColor colorWithRed:(234.0/255) green:(221.0/255) blue:(201.0/255) 	alpha:1.0];}
+(UIColor*)beercrushTanColor		{return [UIColor colorWithRed:(196.0/255) green:(154.0/255) blue:(108.0/255) 	alpha:1.0];}
+(UIColor*)beercrushLightRedColor 	{return [UIColor colorWithRed:(238.0/255) green:(49.0/255) 	blue:(36.0/255) 	alpha:1.0];}
+(UIColor*)beercrushRedColor 		{return [UIColor colorWithRed:(111.0/255) green:(0.0/255) 	blue:(20.0/255) 	alpha:1.0];}
+(UIColor*)beercrushLightBlueColor 	{return [UIColor colorWithRed:(56.0/255)  green:(189.0/255) blue:(236.0/255) 	alpha:1.0];}
+(UIColor*)beercrushBlueColor 		{return [UIColor colorWithRed:(19.0/255)  green:(122.0/255) blue:(161.0/255) 	alpha:1.0];}

@end


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


typedef enum _VCType {
	kVCTypeUnknown=0,
	kVCTypeSearchVC,
	kVCTypeBeerTableViewController,
	kVCTypeBreweryTableViewController,
	kVCTypePlaceTableViewController,
	kVCTypeNearbyTableViewController,
	kVCTypeBeerListTableViewController,
	kVCTypeUserReviewsTVC,
	kVCTypePlacesTVC,
	kVCTypeUserProfileTVC,
	kVCTypeBuddiesTVC,
	kVCTypeRecommendedTVC,
	kVCTypeBookmarksTVC
} VCType;

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

void normalizeToNumber(NSMutableDictionary* dict,NSString* key, BOOL addIfNotExist)
{
	if ([dict objectForKey:key]==nil)
	{
		if (addIfNotExist)
			[dict setObject:[NSNumber numberWithInt:0] forKey:key];
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSNumber class]])
	{
		// Do nothing, it's already a number
	}
	else if ([[dict objectForKey:key] isKindOfClass:[NSString class]])
	{
		[dict setObject:[NSNumber numberWithFloat:[[dict objectForKey:key] floatValue]] forKey:key];
	}
	else
	{
		[dict setObject:[NSNumber numberWithInt:0] forKey:key];
	}
}

void normalizeToBoolean(NSMutableDictionary* dict,NSString* key,BOOL addIfNotExist)
{
	if ([dict objectForKey:key]==nil)
	{
		if (addIfNotExist)
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

		if ([origObj isKindOfClass:[NSString class]])
		{
			if ([currObj isKindOfClass:[NSString class]]) {
				NSString* origString=(NSString*)origObj;
				NSString* currString=(NSString*)currObj;
				if ([origString isEqualToString:currString]==NO)
				{
					[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,currString]];
				}
			}
			else {
				[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,currObj]];
			}
		}
		else if ([origObj isKindOfClass:[NSNumber class]])
		{
			if ([currObj isKindOfClass:[NSNumber class]]) {
				NSNumber* origNumber=(NSNumber*)origObj;
				NSNumber* currNumber=(NSNumber*)currObj;
				if ([origNumber isEqualToNumber:currNumber]==NO)
				{
					[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,currNumber]];
				}
			}
			else {
				[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,currObj]];
			}
		}
		else if ([origObj isKindOfClass:[NSArray class]])
		{
			if ([currObj isKindOfClass:[NSArray class]]) {
				NSArray* origArr=(NSArray*)origObj;
				NSArray* currArr=(NSArray*)currObj;
				if ([origArr isEqualToArray:currArr]==NO)
				{
					[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,[currArr componentsJoinedByString:@" "]]];
				}
			}
			else {
				[values addObject:[NSString stringWithFormat:@"%@=%@",keyName,currObj]];
			}
		}
		else {
			// What to do?
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
	normalizeToString(beerData, @"otherings");
	normalizeToArray(beerData, @"styles", 3);
	normalizeToNumber(beerData, @"abv",NO);
	normalizeToNumber(beerData, @"ibu",NO);
	normalizeToNumber(beerData, @"og",NO);
	normalizeToNumber(beerData, @"fg",NO);
	normalizeToNumber(beerData, @"srm",NO);
	normalizeToNumber(beerData, @"calories_per_ml",NO);
	
	if ([beerData objectForKey:@"review_summary"]==nil)
		[beerData setObject:[NSMutableDictionary dictionaryWithCapacity:4] forKey:@"review_summary"];
	normalizeToNumber([beerData objectForKey:@"review_summary"], @"total", YES);
	normalizeToNumber([beerData objectForKey:@"review_summary"], @"body_avg", YES);
	normalizeToNumber([beerData objectForKey:@"review_summary"], @"balance_avg", YES);
	normalizeToNumber([beerData objectForKey:@"review_summary"], @"aftertaste_avg", YES);

	if ([[beerData objectForKey:@"review_summary"] objectForKey:@"flavors"]==nil)
		[[beerData objectForKey:@"review_summary"] setObject:[NSArray array] forKey:@"flavors"];
}

void normalizePlaceData(NSMutableDictionary* placeData)
{
	normalizeToString(placeData, @"name");
	normalizeToString(placeData, @"description");
	normalizeToString(placeData, @"phone");
	normalizeToString(placeData, @"placestyle");
	normalizeToString(placeData, @"placetype");
	normalizeToString(placeData, @"uri");
	normalizeToBoolean(placeData, @"kid_friendly",NO);
	
	if ([placeData objectForKey:@"hours"]==nil)
		[placeData setObject:[NSMutableDictionary dictionaryWithCapacity:3] forKey:@"hours"];
	normalizeToString([placeData objectForKey:@"hours"], @"open");
	
	if ([placeData objectForKey:@"restaurant"]==nil)
		[placeData setObject:[NSMutableDictionary dictionaryWithCapacity:3] forKey:@"restaurant"];
	
	normalizeToNumber([placeData objectForKey:@"restaurant"],@"price_range",NO);
	normalizeToBoolean([placeData objectForKey:@"restaurant"], @"outdoor_seating",NO);
	normalizeToString([placeData objectForKey:@"restaurant"],@"food_description");
	
	if ([placeData objectForKey:@"@attributes"]==nil)
		[placeData setObject:[NSMutableDictionary dictionaryWithCapacity:3] forKey:@"@attributes"];
	
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"wifi",NO);
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"bottled_beer_to_go",NO);
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"growlers_to_go",NO);
	normalizeToBoolean([placeData objectForKey:@"@attributes"], @"kegs_to_go",NO);
	
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
	normalizeToBoolean([data objectForKey:@"togo"], @"bottled_beer",NO);
	normalizeToBoolean([data objectForKey:@"togo"], @"growlers",NO);
	normalizeToBoolean([data objectForKey:@"togo"], @"kegs",NO);
	
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
@synthesize tabBarController;
@synthesize flavorsDictionary;
@synthesize stylesDictionary;
@synthesize colorsDictionary;
@synthesize placeStylesDictionary;
@synthesize documentCache;
@synthesize restoringNavState;
@synthesize appState;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	// Create the sharedOperationQueue to use for async operations
	self.sharedOperationQueue=[[NSOperationQueue alloc] init];
	
	self.documentCache=[NSMutableDictionary dictionaryWithCapacity:100];
	
	[self startApp];
}

-(void)startApp
{
	
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
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				nc.delegate=self;
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
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				nc.delegate=self;
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
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				nc.delegate=self;
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Nearby" image:[UIImage imageNamed:@"tab_nearby.png"] tag:kTabBarItemTagNearby] autorelease];
				
				NearbyTableViewController* ntvc=[[NearbyTableViewController alloc] initWithStyle: UITableViewStylePlain];
				[nc pushViewController:ntvc animated:NO ];
				break;
			}
			case kTabBarItemTagWishList:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				nc.delegate=self;
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Wish List" image:[UIImage imageNamed:@"tab_wishlist.png"] tag:kTabBarItemTagWishList] autorelease];
				
				BeerListTableViewController* bltvc=[[[BeerListTableViewController alloc] initWithBreweryID:@"wishlist:"] autorelease];
				[nc pushViewController:bltvc animated:NO];
				break;
			}
			case kTabBarItemTagMyBeerReviews:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				nc.delegate=self;
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"My Beers" image:[UIImage imageNamed:@"tab_beerreviews.png"] tag:kTabBarItemTagMyBeerReviews] autorelease];
				
				UserReviewsTVC* urtvc=[[[UserReviewsTVC alloc] init] autorelease];
				[nc pushViewController:urtvc animated:NO];
				break;
			}
			case kTabBarItemTagMyPlaces:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				nc.delegate=self;
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"My Places" image:[UIImage imageNamed:@"tab_placeratings.png"] tag:kTabBarItemTagMyPlaces] autorelease];
				
				PlacesTVC* bltvc=[[[PlacesTVC alloc] initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:bltvc animated:NO];
				break;
			}
			case kTabBarItemTagProfile:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				nc.delegate=self;
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"tab_profile.png"] tag:kTabBarItemTagProfile] autorelease];
				
				UserProfileTVC* uptvc=[[[UserProfileTVC alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
				[nc pushViewController:uptvc animated:NO];
				break;
			}
			case kTabBarItemTagBuddies:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Buddies" image:[UIImage imageNamed:@"tab_buddies.png"] tag:kTabBarItemTagBuddies] autorelease];
				
				BuddiesTVC* btvc=[[[BuddiesTVC alloc] initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:btvc animated:NO];
				break;
			}
			case kTabBarItemTagRecommended:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
				[tabBarControllers addObject:nc];
				nc.tabBarItem=[[[UITabBarItem alloc] initWithTitle:@"Recommended" image:[UIImage imageNamed:@"tab_recommended.png"] tag:kTabBarItemTagRecommended] autorelease];
				
				RecommendedTVC* rtvc=[[[RecommendedTVC alloc]  initWithStyle:UITableViewStylePlain] autorelease];
				[nc pushViewController:rtvc animated:NO];
				break;
			}
			case kTabBarItemTagBookmarks:
			{
				UINavigationController* nc=[[[UINavigationController alloc] initWithNibName:nil bundle:nil] autorelease];
				nc.navigationBar.tintColor=[UIColor beercrushTanColor];
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
	tabBarController.moreNavigationController.navigationBar.tintColor=[UIColor beercrushTanColor];
	
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
	
	DLog(@"standardUserDefaults=%@",[NSUserDefaults standardUserDefaults]);
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

-(void)abortNavigationRestorationForTabBarItem:(UITabBarItem*)tabBarItem
{
	NSUInteger idx=0;
	for (UIViewController* vc in self.tabBarController.viewControllers)
	{
		if (vc.tabBarItem.tag==tabBarItem.tag)
		{	// Found it
			NSMutableArray* stacks=[self.restoringNavState objectForKey:@"navstacks"];
			NSMutableArray* stack=[stacks objectAtIndex:idx];
			[stack removeAllObjects];
			break;
		}
		++idx;
	}
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

	[restoringNavState release];
	
    [super dealloc];
}


-(BOOL)haveUserCredentials
{
//	return NO; // Just for debugging
	// Get the userid and password from App Preferences
	NSString* email=[[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
	NSString* password=[[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	if (email==nil || password==nil || [email length]==0 || [password length]==0)
		return NO;
	
	return YES;
}

-(void)askUserForCredentialsWithDelegate:(id<LoginVCDelegate>)delegate
{
	LoginVC* loginVC=[[[LoginVC alloc] initWithNibName:nil bundle:nil] autorelease];
	loginVC.delegate=delegate?delegate:self;
	UINavigationController* nc=[[[UINavigationController alloc] initWithRootViewController:loginVC] autorelease];
	[self.tabBarController.selectedViewController presentModalViewController:nc animated:YES];
}

-(BOOL)automaticLogin
{
	BOOL didSuccessfullyLogin=NO;
	
	// Get the userid and password from App Preferences
	NSString* email=[[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
	NSString* password=[[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	if (email==nil || password==nil || [email length]==0 || [password length]==0)
	{
		// Just can't do it, somebody needs to ask user for them
		DLog(@"Can't attempt login, need credentials");
	}
	else 
	{
		// TODO: do this over HTTPS
		DLog(@"Logging in...");
		NSString* bodystr=[[[NSString alloc] initWithFormat:@"email=%@&password=%@", email, password] autorelease];
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
			didSuccessfullyLogin=YES;
			
			NSString* s=[[[NSString alloc] initWithData:respdata encoding:NSUTF8StringEncoding] autorelease];
			NSDictionary* logininfo=[s JSONValue];

			// Store the login info in UserDefaults
			[[NSUserDefaults standardUserDefaults] setObject:[logininfo objectForKey:@"name"] forKey:@"username"];
			[[NSUserDefaults standardUserDefaults] setObject:[logininfo objectForKey:@"userid"] forKey:@"user_id"];
			[[NSUserDefaults standardUserDefaults] setObject:[logininfo objectForKey:@"usrkey"] forKey:@"usrkey"];
		} 
		else 
		{
			DLog(@"Login failed.");
			// Erase the login info in UserDefaults
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"usrkey"];
			if ([response statusCode]==403 || [response statusCode]==404) // 404 means email doesn't exist, 403 means password was wrong
			{
				/* 
				 Remove the password so they are asked for it again. We could remove the email address on 404 errors but that would
				 be annoying to the user if they just had a typo in their email address and had to retype the entire thing, which is more
				 painful on an iPhone.
				 */
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
			}
		}	
	}
	
	return didSuccessfullyLogin;
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
	int nTries=0;
	BOOL bRetry=NO;
	NSHTTPURLResponse* response=nil;
	
	do
	{
		++nTries;
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url 
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:30.0];
		
		NSString* userid=[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
		NSString* usrkey=[[NSUserDefaults standardUserDefaults] objectForKey:@"usrkey"];
		
		// Always add userid and usrkey parameters as cookies
		[theRequest setValue:[NSString stringWithFormat:@"userid=%@; usrkey=%@",userid,usrkey] forHTTPHeaderField:@"Cookie"];

		if ([method isEqualToString:@"POST"])
		{
			if (data)
			{
				if ([data isKindOfClass:[NSString class]])
				{
					NSString* stringData=(NSString*)data;
					
//					stringData=[stringData stringByAppendingFormat:@"&userid=%@&usrkey=%@",userid,usrkey];
					
					NSData* body=[stringData dataUsingEncoding:NSUTF8StringEncoding];
					DLog(@"POST data:%@",stringData);
					
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
//					[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"userid\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//					[body appendData:[userid dataUsingEncoding:NSUTF8StringEncoding]];
//					[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//					[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"usrkey\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//					[body appendData:[usrkey dataUsingEncoding:NSUTF8StringEncoding]];
//					[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
					[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
					[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//					DLog(@"POST data:%s<PHOTO DATA HERE>",body.bytes);
					DLog(@"POST data length:%d",[dataData length]);
					[body appendData:dataData];
					[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
					// setting the body of the post to the reqeust
					[theRequest setHTTPBody:body];
				}
			}
		}
		else if ([method isEqualToString:@"GET"])
		{
		}

		DLog(@"%@ URL:%@",method,[url absoluteString]);
		DLog(@"Auth:userid=%@; usrkey=%@",userid,usrkey);

		[theRequest setHTTPMethod:method];
		
		NSError* error;
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
		NSData* rspdata=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
		[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;

		if (responseData)
			*responseData=rspdata;

		if (rspdata) {
			
			bRetry=NO;
			NSInteger statuscode=[response statusCode];
			
			DLog(@"Response code:%d",statuscode);
			DLog(@"Response data:%.*s", [rspdata length], [rspdata bytes]);

			if (statuscode==403) // 403 means that the user must be logged in
			{
				if (nTries < 2) // Don't retry over and over, just do it once
				{
					if ([self automaticLogin]==YES)
					{
						bRetry=YES; // Successfully logged in, retry original request
					}
				}
			}
			else if (statuscode==200)
			{
			}
		} else {
			// Let caller give an error alert
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
				[self genericAlert:NSLocalizedString(@"Flavors ",@"GetFlavorsDictionary: Alert Message") 
							 title:NSLocalizedString(@"Unable to get Flavors list",@"GetFlavorsDictionary: Alert Title") 
					   buttonTitle:nil];
			}
		}
	}
	
	return flavorsDictionary;
}

-(void)genericAlert:(NSString*)message title:(NSString*)alertTitle buttonTitle:(NSString*)buttonTitle
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:(alertTitle?alertTitle:@"")
												  message:(message?message:@"")
												 delegate:nil
										cancelButtonTitle:(buttonTitle?buttonTitle:@"")
										otherButtonTitles:nil];
	[alert show];
	[alert release];
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
			[self genericAlert:NSLocalizedString(@"Styles",@"GetStylesDictionary: Alert Message") 
						 title:NSLocalizedString(@"Unable to get Styles list",@"GetStylesDictionary: Alert Title") 
				   buttonTitle:nil];
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
				NSObject* srm=[colorInfo objectForKey:@"srm"];
				if (srm!=nil)
					[[self.colorsDictionary objectForKey:@"colornamebysrm"] setObject:colorInfo forKey:srm];
			}
		}
		else
		{
			[self genericAlert:NSLocalizedString(@"Colors",@"GetColorDictionary: Alert Message") 
						 title:NSLocalizedString(@"Unable to get Colors list",@"GetColorsDictionary: Alert Title") 
				   buttonTitle:nil];
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
	// TODO: support caching
	if (self.placeStylesDictionary==nil)
	{
		NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URI_GET_PLACE_STYLES];
		NSMutableDictionary* answer;
		NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
		if ([response statusCode]==200)
		{
			self.placeStylesDictionary=answer;
			
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
		
		// Add Purchase Place
		NSString* s=[userReview objectForKey:@"purchase_place_id"];
		if (s && [s length])
			[values addObject:[NSString stringWithFormat:@"purchase_place_id=%@",s]];

		// Add Purchase Price
		NSNumber* n=[userReview objectForKey:@"purchase_price"];
		if (n)
			[values addObject:[NSString stringWithFormat:@"purchase_price=%@",n]];

		// Add Purchase Date
		s=[userReview objectForKey:@"date_drank"];
		if (s && [s length])
			[values addObject:[NSString stringWithFormat:@"date_drank=%@",s]];
		
		// Add Poured From
		s=[userReview objectForKey:@"poured_from"];
		if (s && [s length])
			[values addObject:[NSString stringWithFormat:@"poured_from=%@",s]];

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
		DLog(@"Response status code=%d",[response statusCode]);
		[self genericAlert:NSLocalizedString(@"Unable to get information about beer",@"GetBeerDoc: Alert Message") 
					 title:NSLocalizedString(@"Beer",@"GetBeerDoc: Alert Title") 
			   buttonTitle:nil];
	}

	return nil;
}

-(NSMutableDictionary*)getPhotoset:(NSString*)photosetID
{
	// TODO: support caching
	
	// Separate the brewery ID and the beer ID from the beerID
	NSArray* idparts=[photosetID componentsSeparatedByString:@":"];
	NSURL* url=nil;
	
	if ([idparts count]==2) // Brewery or Place
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERYORPLACE_PHOTOSET_DOC, [idparts objectAtIndex:0], [idparts objectAtIndex:1] ]];
	else if ([idparts count] == 3) // Beer
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_PHOTOSET_DOC, [idparts objectAtIndex:0], [idparts objectAtIndex:1], [idparts objectAtIndex:2] ]];
	
	if (url)
	{
		// Retrieve JSON doc for this beer's photoset
		NSMutableDictionary* answer;
		NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
		if ([response statusCode]==200)
		{
			[answer retain];
			return answer;
		}
		else {
			DLog(@"Response status code=%d",[response statusCode]);
			[self genericAlert:NSLocalizedString(@"Unable to get photos",@"GetPhotos: Alert Message") 
						 title:NSLocalizedString(@"Photos",@"GetPhotos: Alert Title") 
				   buttonTitle:nil];
		}
	}
	
	return nil;
}

-(NSMutableDictionary*)getReviewsOfBeer:(NSString*)beerID byUserID:(NSString*)userID
{
	// TODO: support caching

	if (beerID && [beerID length])
	{
		// Separate the brewery ID and the beer ID from the beerID
		NSArray* idparts=[beerID componentsSeparatedByString:@":"];

		if (userID && [userID length])
		{
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
				DLog(@"Response status code=%d",[response statusCode]);
		//		[self genericAlert:NSLocalizedString(@"Beer Reviews",@"GetBeerReviews: Alert Message") 
		//					 title:NSLocalizedString(@"Unable to get beer reviews",@"GetBeerReviews: Alert Title") 
		//			   buttonTitle:nil];
			}
		}
	}
	return nil;
}

-(double)getPredictedRatingForBeer:(NSString*)beerID forUserID:(NSString*)userID 
{
	// TODO: support caching
	
	if (beerID && [beerID length])
	{
		// Separate the brewery ID and the beer ID from the beerID
		NSArray* idparts=[beerID componentsSeparatedByString:@":"];
		
		if (userID && [userID length])
		{
			// Retrieve user's review for this beer
			NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BEER_PERSONALIZATION, 
											 [idparts objectAtIndex:1], 
											 [idparts objectAtIndex:2]]];
			NSMutableDictionary* answer;
			NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
			if ([response statusCode]==200)
			{
				id o=[answer valueForKey:@"predictedrating"];
				if ([o isKindOfClass:[NSNull class]])
					return 0;
				return [[answer valueForKey:@"predictedrating"] doubleValue];
			}
			else {
				DLog(@"Response status code=%d",[response statusCode]);
				//		[self genericAlert:NSLocalizedString(@"Beer Reviews",@"GetBeerReviews: Alert Message") 
				//					 title:NSLocalizedString(@"Unable to get beer reviews",@"GetBeerReviews: Alert Title") 
				//			   buttonTitle:nil];
			}
		}
	}
	return 0;
}

-(NSMutableDictionary*)getBeerReviewsByUser:(NSString*)userID seqNum:(NSNumber*)seqNum
{
	NSMutableDictionary* answer=nil;
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_BEER_REVIEWS_DOC, userID]];
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		return answer;
	}
	else
	{
//		[self genericAlert:NSLocalizedString(@"Beer Reviews",@"GetUserBeerReviews: Alert Message") 
//					 title:NSLocalizedString(@"Unable to get beer reviews",@"GetUserBeerReviews: Alert Title") 
//			   buttonTitle:nil];
	}
	return nil;
}

-(NSMutableDictionary*)getUserDoc:(NSString*)userID
{
	NSMutableDictionary* answer=nil;
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_INFO, userID]];
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		return answer;
	}
	else
	{
		//		[self genericAlert:NSLocalizedString(@"Beer Reviews",@"GetUserBeerReviews: Alert Message") 
		//					 title:NSLocalizedString(@"Unable to get beer reviews",@"GetUserBeerReviews: Alert Title") 
		//			   buttonTitle:nil];
	}
	return nil;
}

-(NSString*)breweryNameFromBeerID:(NSString*)beer_id
{
	if (beer_id && [beer_id length])
	{
		NSArray* parts=[beer_id componentsSeparatedByString:@":"];
		if ([parts count] >= 2)
		{
			NSMutableDictionary* doc=[self getBreweryDoc:[parts objectAtIndex:1]];
			if (doc)
			{
				NSObject* s=[doc objectForKey:@"name"];
				if (s && [s isKindOfClass:[NSString class]])
					return (NSString*)s;
			}
		}
	}
	return @"";
}

-(NSMutableDictionary*)getBreweryDoc:(NSString*)breweryID
{
	NSMutableDictionary* doc=[self.documentCache objectForKey:breweryID];
	if (doc)
		return doc;
	
	NSArray* parts=[breweryID componentsSeparatedByString:@":"];
	if ([parts count])
	{
		NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_DOC,[parts lastObject]]];
		NSMutableDictionary* answer;
		NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
		if ([response statusCode]==200)
		{
			normalizeBreweryData(answer);
			[self.documentCache setObject:answer forKey:breweryID];
			return answer;
		}
		else {
	//		[self genericAlert:NSLocalizedString(@"Brewery",@"GetBreweryDoc: Alert Message") 
	//					 title:NSLocalizedString(@"Unable to get information for brewery",@"GetBreweryDoc: Alert Title") 
	//			   buttonTitle:nil];
		}
	}
	
	return nil;
}

-(NSDictionary*)getBeerList:(NSString*)breweryID
{
	// TODO: support caching
	NSArray* idparts=[breweryID componentsSeparatedByString:@":"];
	NSURL* url=nil;
	if ([idparts count]==2)
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_BEERLIST,[idparts objectAtIndex:1]]];
	else if ([idparts count]==1)
		url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_BREWERY_BEERLIST,[idparts objectAtIndex:0]]];
	
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		return answer;
	}
	return nil;
}

-(NSDictionary*)getBeerMenu:(NSString*)placeID
{
	// TODO: support caching
	
	// Remove "place:" from ID
	NSArray* idparts=[placeID componentsSeparatedByString:@":"];
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_MENU_DOC, [idparts objectAtIndex:1]]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
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
	else {
		[self genericAlert:NSLocalizedString(@"Place",@"GetPlaceDoc: Alert Message") 
					 title:NSLocalizedString(@"Unable to get information for place",@"GetPlaceDoc: Alert Title") 
			   buttonTitle:nil];
	}

	return nil;
}

-(NSMutableDictionary*)getPlacesWithBeer:(NSString*)beerID nearLocation:(CLLocation*)location withinDistance:(NSUInteger)distance
{
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_NEARBY_PLACES_WITH_BEER, 
									 location.coordinate.latitude, 
									 location.coordinate.longitude,
									 distance,
									 beerID]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		return answer;
	}
	else {
	}
	
	return nil;
}

-(NSMutableDictionary*)getPlaceReviews:(NSString*)placeID byUser:(NSString*)user_id
{
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_USER_PLACE_REVIEW_DOC, 
							  placeID,
							  user_id]];
	NSMutableDictionary* answer;
	NSHTTPURLResponse* response=[self sendJSONRequest:url usingMethod:@"GET" withData:nil returningJSON:&answer];
	if ([response statusCode]==200)
	{
		normalizePlaceReviewData(answer);
		return answer;
	}
	else {
//		[self genericAlert:NSLocalizedString(@"Reviews",@"GetPlaceReviews: Alert Message") 
//					 title:NSLocalizedString(@"Unable to get reviews",@"GetPlaceReviews: Alert Title") 
//			   buttonTitle:nil];
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
		else {
//			[self genericAlert:NSLocalizedString(@"Reviews",@"GetReviews: Alert Message") 
//						 title:NSLocalizedString(@"Unable to get reviews",@"GetReviews: Alert Title") 
//				   buttonTitle:nil];
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
	else {
//		[self genericAlert:NSLocalizedString(@"Breweries",@"GetBreweriesDoc: Alert Message") 
//					 title:NSLocalizedString(@"Unable to get brewery list",@"GetBreweriesDoc: Alert Title") 
//			   buttonTitle:nil];
	}

	return nil;
}

-(void)dismissActivityHUD
{ 
	if ([NSThread isMainThread]==NO) {
		[self performSelectorOnMainThread:@selector(dismissActivityHUD) withObject:nil waitUntilDone:NO];
	}
	else 
	{
		[self.activityHUD show:NO];
		self.activityHUD=nil;
	}
} 

-(void)presentActivityHUD:(NSString*)hudText
{ 
	// UIProgressHUD is undocumented by Apple. If you get screwed, try this instead: http://www.bukovinski.com/2009/04/08/mbprogresshud-for-iphone/
	if (self.activityHUD==nil) {
		if (self.tabBarController.selectedIndex>=4) { // The More nav controller
			self.activityHUD = [[UIProgressHUD alloc] initWithWindow:self.tabBarController.moreNavigationController.visibleViewController.view];
		}
		else
			self.activityHUD = [[UIProgressHUD alloc] initWithWindow:self.tabBarController.selectedViewController.view];
	}
	[self.activityHUD setText:hudText]; 
	[self.activityHUD show:YES]; 
}

-(void)performAsyncOperationWithTarget:(id)target selector:(SEL)sel object:(id)object requiresUserCredentials:(BOOL)requiresCredentials activityHUDText:(NSString*)hudText
{
	if (requiresCredentials && [self haveUserCredentials]==NO)
	{
		[self askUserForCredentialsWithDelegate:self];
	}
	else
	{
		if (hudText)
			[self presentActivityHUD:hudText];
		NSInvocationOperation* op=[[[NSInvocationOperation alloc] initWithTarget:target selector:sel object:object] autorelease];
		[self.sharedOperationQueue addOperation:op];
	}
}

#pragma mark LoginVCDelegate methods

-(void)loginVCSuccessful
{
	[self.tabBarController.selectedViewController dismissModalViewControllerAnimated:YES];
}

-(void)loginVCNewAccount:(NSString*)userid andPassword:(NSString*)password
{
	[self.tabBarController.selectedViewController dismissModalViewControllerAnimated:YES];
}

-(void)loginVCFailed
{
	// Don't care, the user can cancel if they can't or don't want to login
}

-(void)loginVCCancelled
{
	[self.tabBarController.selectedViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	// Do auto-navigation to restore app state
	if ([self restoringNavigationStateAutomatically])
	{
		NSObject* obj=[self nextNavigationStateToRestore];
		if (obj && [obj isKindOfClass:[NSDictionary class]])
		{
			UIViewController* vc=nil;
			
			NSDictionary* navdict=(NSDictionary*)obj;
			
			// Instantiate a view controller of type VCClass
			NSNumber* vctype=[navdict objectForKey:@"vctype"];
			NSObject* navobj=[navdict objectForKey:@"navobj"];

			switch ([vctype intValue]) {
				case kVCTypeSearchVC:
					vc=[[[SearchVC alloc] init] autorelease];
					if ([navobj isKindOfClass:[NSNumber class]])
					{
						SearchVC* svc=(SearchVC*)vc;
						NSNumber* st=(NSNumber*)navobj;
						svc.searchTypes=[st intValue];
					}
					break;
				case kVCTypeBeerTableViewController:
					if ([navobj isKindOfClass:[NSString class]])
						vc=[[[BeerTableViewController alloc] initWithBeerID:(NSString*)navobj] autorelease];
					break;
				case kVCTypeBreweryTableViewController:
					if ([navobj isKindOfClass:[NSString class]])
						vc=[[[BreweryTableViewController alloc] initWithBreweryID:(NSString*)navobj] autorelease];
					break;
				case kVCTypePlaceTableViewController:
					if ([navobj isKindOfClass:[NSString class]])
						vc=[[[PlaceTableViewController alloc] initWithPlaceID:(NSString*)navobj] autorelease];
					break;
				case kVCTypeBeerListTableViewController:
					if ([navobj isKindOfClass:[NSString class]])
						vc=[[[BeerListTableViewController alloc] initWithBreweryID:(NSString*)navobj] autorelease];
					break;
				case kVCTypeNearbyTableViewController:
					vc=[[[NearbyTableViewController alloc] init] autorelease];
					break;
				case kVCTypeUserReviewsTVC:
					vc=[[[UserReviewsTVC alloc] init] autorelease];
					break;
				case kVCTypePlacesTVC:
				case kVCTypeUserProfileTVC:
				case kVCTypeBuddiesTVC:
				case kVCTypeRecommendedTVC:
				case kVCTypeBookmarksTVC:
				default:
					// Stop restoring...
					[self abortNavigationRestorationForTabBarItem:navigationController.tabBarItem];
					break;
			}
			/* 
			 Manually call viewWillDisappear on top view controller because it won't get called otherwise. 
			 I don't know if it's a bug in the iPhone SDK or not, but it doesn't make sense to me.
			 SearchVC, specifically, needs this so it can show/hide the searchbar control when it is presented 
			 or covered up.
			 */
			[navigationController.topViewController viewWillDisappear:NO];
			
			if (vc)
				[navigationController pushViewController:vc animated:NO];
		}
	}
	else 
	{
		NSMutableDictionary* navdict=[NSMutableDictionary dictionaryWithCapacity:2];
		NSObject* navobj=nil;
		VCType vctype=kVCTypeUnknown;
		
		// Ask the new view controller for its nav restore data
		if ([viewController respondsToSelector:@selector(navigationRestorationData)])
		{
			navobj=[viewController performSelector:@selector(navigationRestorationData)];
			
			if ([viewController isKindOfClass:[SearchVC class]])
				vctype=kVCTypeSearchVC;
			else if ([viewController isKindOfClass:[BeerTableViewController class]])
				vctype=kVCTypeBeerTableViewController;
			else if ([viewController isKindOfClass:[BreweryTableViewController class]])
				vctype=kVCTypeBreweryTableViewController;
			else if ([viewController isKindOfClass:[PlaceTableViewController class]])
				vctype=kVCTypePlaceTableViewController;
			else if ([viewController isKindOfClass:[NearbyTableViewController class]])
				vctype=kVCTypeNearbyTableViewController;
			else if ([viewController isKindOfClass:[BeerListTableViewController class]])
				vctype=kVCTypeBeerListTableViewController;
			else if ([viewController isKindOfClass:[UserReviewsTVC class]])
				vctype=kVCTypeUserReviewsTVC;
			else if ([viewController isKindOfClass:[PlacesTVC class]])
				vctype=kVCTypePlacesTVC;
			else if ([viewController isKindOfClass:[UserProfileTVC class]])
				vctype=kVCTypeUserProfileTVC;
			else if ([viewController isKindOfClass:[BuddiesTVC class]])
				vctype=kVCTypeBuddiesTVC;
			else if ([viewController isKindOfClass:[RecommendedTVC class]])
				vctype=kVCTypeRecommendedTVC;
			else if ([viewController isKindOfClass:[BookmarksTVC class]])
				vctype=kVCTypeBookmarksTVC;
		}
				
		[navdict setObject:[NSNumber numberWithInt:vctype] forKey:@"vctype"];
		if (navobj)
			[navdict setObject:navobj forKey:@"navobj"];
		
		[self pushNavigationStateForTabBarItem:navigationController.tabBarItem withData:navdict];
	}
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//	
//}

@end


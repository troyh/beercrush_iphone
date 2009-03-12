//
//  BeerCrushAppDelegate.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeerCrushAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	UINavigationController* nav;
	UISearchBar* mySearchBar;
	UIApplication* app;
	
//	NSArray* searchResultsList;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UINavigationController* nav;
@property (nonatomic, retain) UISearchBar* mySearchBar;
@property (nonatomic, retain) UIApplication* app;

-(void)login;

@end

@interface BeerObject : NSObject
{
	NSString* name;
	NSDictionary* attribs;
	NSString* description;
	NSString* style;
	unsigned int abv;
	unsigned int ibu;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSDictionary* attribs;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* style;
@property (nonatomic) unsigned int abv;
@property (nonatomic) unsigned int ibu;

@end


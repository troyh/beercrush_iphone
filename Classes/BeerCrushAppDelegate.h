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
	NSMutableData* xmlPostResponse;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UINavigationController* nav;
@property (nonatomic, retain) UISearchBar* mySearchBar;
@property (nonatomic, retain) UIApplication* app;
@property (nonatomic, retain) NSMutableData* xmlPostResponse;

-(void)login;

@end

//#define BEERCRUSH_API_URL_HOST					"http://troyandgay.com:2337"
#define BEERCRUSH_API_URL_HOST					"http://192.168.63.128"

#define BEERCRUSH_API_URL_LOGIN					@BEERCRUSH_API_URL_HOST"/api/login"
#define BEERCRUSH_API_URL_GET_BREWERY_META_DOC	@BEERCRUSH_API_URL_HOST"/xml/brewery/%@"
#define BEERCRUSH_API_URL_GET_BEER_DOC			@BEERCRUSH_API_URL_HOST"/xml/beer/%@"
#define BEERCRUSH_API_URL_EDIT_BEER_DOC			@BEERCRUSH_API_URL_HOST"/api/edit/beer"
#define BEERCRUSH_API_URL_POST_BEER_REVIEW		@BEERCRUSH_API_URL_HOST"/api/post/beer_review"
#define BEERCRUSH_API_URL_GET_BREWERY_DOC		@BEERCRUSH_API_URL_HOST"/xml/brewery/%@"
#define BEERCRUSH_API_URL_EDIT_BREWERY_DOC		@BEERCRUSH_API_URL_HOST"/api/edit/brewery"
#define BEERCRUSH_API_URL_POST_PLACE_REVIEW		@BEERCRUSH_API_URL_HOST"/api/post/place_review"
#define BEERCRUSH_API_URL_AUTOCOMPLETE_QUERY	@BEERCRUSH_API_URL_HOST"/api/autocomplete.fcgi?output=xml&q=%@"
#define BEERCRUSH_API_URL_NEARBY_QUERY			@BEERCRUSH_API_URL_HOST"/api/nearby.fcgi?lat=%f&lon=%f&within=5"
#define BEERCRUSH_API_URL_GET_PLACE_DOC			@BEERCRUSH_API_URL_HOST"/api/xml/place/%@.xml"
#define BEERCRUSH_API_URL_EDIT_PLACE_DOC		@BEERCRUSH_API_URL_HOST"/api/edit/place"

@interface BeerObject : NSObject
{
	NSMutableDictionary* data;
//	NSString* name;
//	NSDictionary* attribs;
//	NSString* description;
//	NSString* style;
//	unsigned int abv;
//	unsigned int ibu;
}

@property (nonatomic,retain) NSMutableDictionary* data;
//@property (nonatomic, retain) NSString* name;
//@property (nonatomic, retain) NSDictionary* attribs;
//@property (nonatomic, retain) NSString* description;
//@property (nonatomic, retain) NSString* style;
//@property (nonatomic) unsigned int abv;
//@property (nonatomic) unsigned int ibu;

-(id)init;

@end


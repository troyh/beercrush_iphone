//
//  BeerCrushAppDelegate.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginVC.h"

@interface BeerCrushAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
	LoginVC* loginVC;
    UITabBarController *tabBarController;
	UINavigationController* nav;
	UISearchBar* mySearchBar;
	UIApplication* app;
	SEL onBeerSelectedAction;
	id onBeerSelectedTarget;
	
//	NSArray* searchResultsList;
	NSMutableData* xmlPostResponse;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LoginVC* loginVC;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UINavigationController* nav;
@property (nonatomic, retain) UISearchBar* mySearchBar;
@property (nonatomic, retain) UIApplication* app;
@property (nonatomic, retain) NSMutableData* xmlPostResponse;
@property(nonatomic) SEL onBeerSelectedAction;
@property(nonatomic,assign) id onBeerSelectedTarget;

-(void)startApp;
-(void)askUserForCredentials;
-(BOOL)login;
-(NSHTTPURLResponse*)sendRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSString*)data returningData:(NSData**)responseData;
-(void)setOnBeerSelectedAction:(SEL)s target:(id)t;
-(BOOL)onBeerSelected:(id)obj;

@end

//#define BEERCRUSH_API_URL_HOST					"http://beercrush.com"
#define BEERCRUSH_API_URL_HOST					"http://macdev"

#define BEERCRUSH_API_URL_AUTOCOMPLETE_QUERY			@BEERCRUSH_API_URL_HOST"/api/autocomplete.fcgi?q=%@"
#define BEERCRUSH_API_URL_CREATE_ACCOUNT				@BEERCRUSH_API_URL_HOST"/api/createlogin"
#define BEERCRUSH_API_URL_EDIT_BEER_DOC					@BEERCRUSH_API_URL_HOST"/api/beer/edit"
#define BEERCRUSH_API_URL_EDIT_BREWERY_DOC				@BEERCRUSH_API_URL_HOST"/api/brewery/edit"
#define BEERCRUSH_API_URL_EDIT_PLACE_DOC				@BEERCRUSH_API_URL_HOST"/api/place/edit"
#define BEERCRUSH_API_URL_EDIT_MENU_DOC					@BEERCRUSH_API_URL_HOST"/api/menu/edit"
#define BEERCRUSH_API_URL_GET_ALL_BEER_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/xml/review/beer/%@/%@/_all.%d.xml"
#define BEERCRUSH_API_URL_GET_ALL_BREWERIES_DOC			@BEERCRUSH_API_URL_HOST"/xml/breweries.xml"
#define BEERCRUSH_API_URL_GET_ALL_BREWERY_REVIEWS_DOC	@BEERCRUSH_API_URL_HOST"/xml/review/brewery/%@/_all.%d.xml"
#define BEERCRUSH_API_URL_GET_ALL_PLACE_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/xml/review/place/%@/_all.%d.xml"
#define BEERCRUSH_API_URL_GET_BEER_DOC					@BEERCRUSH_API_URL_HOST"/xml/beer/%@/%@"
#define BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC			@BEERCRUSH_API_URL_HOST"/xml/review/beer/%@/%@/%@"
#define BEERCRUSH_API_URL_GET_BREWERY_DOC				@BEERCRUSH_API_URL_HOST"/xml/brewery/%@"
#define BEERCRUSH_API_URL_GET_MENU_DOC					@BEERCRUSH_API_URL_HOST"/xml/menu/%@/%@"
#define BEERCRUSH_API_URL_GET_PLACE_DOC					@BEERCRUSH_API_URL_HOST"/xml/place/%@"
#define BEERCRUSH_API_URL_GET_PLACE_REVIEW_DOC			@BEERCRUSH_API_URL_HOST"/xml/review/place/%@/%@"
#define BEERCRUSH_API_URL_GET_USER_BEER_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/xml/user/%@/reviews/beer.%d.xml"
#define BEERCRUSH_API_URL_GET_USER_PLACE_REVIEWS_DOC	@BEERCRUSH_API_URL_HOST"/xml/user/%@/reviews/place.%d.xml"
#define BEERCRUSH_API_URL_GET_USER_WISHLIST_DOC			@BEERCRUSH_API_URL_HOST"/xml/user/%@/wishlist"
#define BEERCRUSH_API_URL_LOGIN							@BEERCRUSH_API_URL_HOST"/api/login"
#define BEERCRUSH_API_URL_NEARBY_QUERY					@BEERCRUSH_API_URL_HOST"/api/nearby.fcgi?lat=%f&lon=%f&within=%d"
#define BEERCRUSH_API_URL_POST_BEER_REVIEW				@BEERCRUSH_API_URL_HOST"/api/beer/review"
#define BEERCRUSH_API_URL_POST_PLACE_REVIEW				@BEERCRUSH_API_URL_HOST"/api/place/review"

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


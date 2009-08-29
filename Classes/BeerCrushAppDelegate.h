//
//  BeerCrushAppDelegate.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginVC.h"

// The following DLog and ALog macros from: http://iPhoneIncubator.com/blog/debugging/the-evolution-of-a-replacement-for-nslog
// DLog is almost a drop-in replacement for NSLog  
// DLog();  
// DLog(@"here");  
// DLog(@"value: %d", x);  
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);  
#ifdef DEBUG  
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);  
#else  
#   define DLog(...)  
#endif  

// ALog always displays output regardless of the DEBUG setting  
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface BeerCrushAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
	LoginVC* loginVC;
    UITabBarController *tabBarController;
	SEL onBeerSelectedAction;
	id onBeerSelectedTarget;
	
	NSMutableData* xmlPostResponse;

	NSMutableArray* xmlParserPath;
	NSMutableString* currentElemValue;
	NSMutableString* currentElemID;
	NSMutableDictionary* flavorsDictionary;
	NSMutableDictionary* stylesDictionary;
	NSMutableDictionary* colorsDictionary;
	
	NSMutableDictionary* restoringNavState;
	NSMutableDictionary* appState;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LoginVC* loginVC;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableData* xmlPostResponse;
@property(nonatomic) SEL onBeerSelectedAction;
@property(nonatomic,assign) id onBeerSelectedTarget;
@property (nonatomic, retain) NSMutableArray* xmlParserPath;
@property (nonatomic, retain) NSMutableString* currentElemValue;
@property (nonatomic, retain) NSMutableString* currentElemID;
@property (nonatomic, retain) NSMutableDictionary* flavorsDictionary;
@property (nonatomic, retain) NSMutableDictionary* stylesDictionary;
@property (nonatomic, retain) NSMutableDictionary* colorsDictionary;
@property (nonatomic, retain) NSMutableDictionary* restoringNavState;
@property (nonatomic, retain) NSMutableDictionary* appState;

-(void)startApp;
-(void)askUserForCredentials;
-(BOOL)login;
-(NSHTTPURLResponse*)sendRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSString*)data returningData:(NSData**)responseData;
-(void)setOnBeerSelectedAction:(SEL)s target:(id)t;
-(BOOL)onBeerSelected:(id)obj;
-(NSDictionary*)getFlavorsDictionary;
-(NSDictionary*)getStylesDictionary;
-(NSDictionary*)getColorsDictionary;
-(NSHTTPURLResponse*)postBeerReview:(NSDictionary*)userReview returningData:(NSData**)answer;
-(BOOL)restoringNavigationStateAutomatically;
-(NSObject*)nextNavigationStateToRestore;
-(BOOL)pushNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem withData:(NSObject*)data;
-(void)popNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem;

-(NSString*)breweryNameFromBeerID:(NSString*)beer_id;

@end

#ifdef DEBUG
#define BEERCRUSH_API_URL_HOST					"http://macdev"
//#define BEERCRUSH_API_URL_HOST					"http://beercrush.com"
#else
//#define BEERCRUSH_API_URL_HOST					"http://macdev"
#define BEERCRUSH_API_URL_HOST					"http://beercrush.com"
#endif

#define BEERCRUSH_API_URL_AUTOCOMPLETE_QUERY			@BEERCRUSH_API_URL_HOST"/api/autocomplete.fcgi?q=%@&dataset=%s"
#define BEERCRUSH_API_URL_CREATE_ACCOUNT				@BEERCRUSH_API_URL_HOST"/api/createlogin"
#define BEERCRUSH_API_URL_EDIT_BEER_DOC					@BEERCRUSH_API_URL_HOST"/api/beer/edit"
#define BEERCRUSH_API_URL_EDIT_BREWERY_DOC				@BEERCRUSH_API_URL_HOST"/api/brewery/edit"
#define BEERCRUSH_API_URL_EDIT_PLACE_DOC				@BEERCRUSH_API_URL_HOST"/api/place/edit"
#define BEERCRUSH_API_URL_EDIT_MENU_DOC					@BEERCRUSH_API_URL_HOST"/api/menu/edit"
#define BEERCRUSH_API_URL_EDIT_WISHLIST_DOC				@BEERCRUSH_API_URL_HOST"/api/wishlist/edit"
#define BEERCRUSH_API_URL_GET_ALL_BEER_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/xml/review/beer/%@/%@/_all.%d.xml"
#define BEERCRUSH_API_URL_GET_ALL_BREWERIES_DOC			@BEERCRUSH_API_URL_HOST"/xml/breweries.xml"
#define BEERCRUSH_API_URL_GET_ALL_BREWERY_REVIEWS_DOC	@BEERCRUSH_API_URL_HOST"/xml/review/brewery/%@/_all.%d.xml"
#define BEERCRUSH_API_URL_GET_ALL_PLACE_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/xml/review/place/%@/_all.%d.xml"
#define BEERCRUSH_API_URL_GET_BEER_DOC					@BEERCRUSH_API_URL_HOST"/xml/beer/%@/%@"
#define BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC			@BEERCRUSH_API_URL_HOST"/xml/review/beer/%@/%@/%@"
#define BEERCRUSH_API_URL_GET_BREWERY_DOC				@BEERCRUSH_API_URL_HOST"/xml/brewery/%@"
#define BEERCRUSH_API_URL_GET_BREWERY_DOC_JSON			@BEERCRUSH_API_URL_HOST"/json/brewery/%@.json"
#define BEERCRUSH_API_URL_GET_COLORSLIST				@BEERCRUSH_API_URL_HOST"/xml/beercolors"
#define BEERCRUSH_API_URL_GET_FLAVORS_DOC				@BEERCRUSH_API_URL_HOST"/xml/flavors"
#define BEERCRUSH_API_URL_GET_MENU_DOC					@BEERCRUSH_API_URL_HOST"/xml/menu/%@/%@"
#define BEERCRUSH_API_URL_GET_PLACE_DOC					@BEERCRUSH_API_URL_HOST"/xml/place/%@"
#define BEERCRUSH_API_URL_GET_PLACE_REVIEW_DOC			@BEERCRUSH_API_URL_HOST"/xml/review/place/%@/%@"
#define BEERCRUSH_API_URL_GET_STYLESLIST				@BEERCRUSH_API_URL_HOST"/xml/styles"
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


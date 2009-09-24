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

@interface UIProgressHUD : NSObject 
- (UIProgressHUD *) initWithWindow: (UIView*)aWindow; 
- (void) show: (BOOL)aShow; 
- (void) setText: (NSString*)aText; 
@end

void normalizeToString(NSMutableDictionary* dict,NSString* key);
void normalizeToNumber(NSMutableDictionary* dict,NSString* key);
void normalizeToBoolean(NSMutableDictionary* dict,NSString* key);
void normalizeToArray(NSMutableDictionary* data, NSString* key, NSUInteger n);
void normalizeToDictionary(NSMutableDictionary* data, NSString* key, NSUInteger n);
void normalizeBeerData(NSMutableDictionary* beerData);
void normalizePlaceData(NSMutableDictionary* placeData);
void normalizePlaceReviewData(NSMutableDictionary* placeReviewData);
void normalizeBreweryData(NSMutableDictionary* data);
NSMutableArray* appendDifferentValuesToArray(NSArray* keyNames,NSDictionary* orig,NSDictionary* curr);


@interface BeerCrushAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
	LoginVC* loginVC;
    UITabBarController *tabBarController;
	SEL onBeerSelectedAction;
	id onBeerSelectedTarget;
	UIProgressHUD* activityHUD;
	
	NSOperationQueue* sharedOperationQueue;
	
	NSMutableDictionary* flavorsDictionary;
	NSMutableDictionary* stylesDictionary;
	NSMutableDictionary* colorsDictionary;
	NSMutableDictionary* placeStylesDictionary;
	
	NSMutableDictionary* restoringNavState;
	NSMutableDictionary* appState;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LoginVC* loginVC;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSOperationQueue* sharedOperationQueue;
@property(nonatomic) SEL onBeerSelectedAction;
@property(nonatomic,assign) id onBeerSelectedTarget;
@property (nonatomic, retain) UIProgressHUD* activityHUD;
@property (nonatomic, retain) NSMutableDictionary* flavorsDictionary;
@property (nonatomic, retain) NSMutableDictionary* stylesDictionary;
@property (nonatomic, retain) NSMutableDictionary* colorsDictionary;
@property (nonatomic, retain) NSMutableDictionary* placeStylesDictionary;
@property (nonatomic, retain) NSMutableDictionary* restoringNavState;
@property (nonatomic, retain) NSMutableDictionary* appState;

-(void)startApp;
-(void)askUserForCredentials;
-(BOOL)login;
-(NSHTTPURLResponse*)sendJSONRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSObject*)data returningJSON:(NSMutableDictionary**)jsonResponse;
-(NSHTTPURLResponse*)sendRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSObject*)data returningData:(NSData**)responseData;
-(void)setOnBeerSelectedAction:(SEL)s target:(id)t;
-(BOOL)onBeerSelected:(id)obj;
-(NSDictionary*)getFlavorsDictionary;
-(NSDictionary*)getStylesDictionary;
-(NSDictionary*)getColorsDictionary;
-(NSDictionary*)getPlaceStylesDictionary;
-(NSMutableDictionary*)getBeerDoc:(NSString*)beerID;
-(NSMutableDictionary*)getReviewsOfBeer:(NSString*)beerID byUserID:(NSString*)userID;
-(NSHTTPURLResponse*)postBeerReview:(NSDictionary*)userReview returningData:(NSData**)answer;
-(NSMutableDictionary*)getBreweryDoc:(NSString*)breweryID;
-(NSMutableDictionary*)getPlaceDoc:(NSString*)placeID;
-(NSMutableDictionary*)getPlaceReviews:(NSString*)placeID byUser:(NSString*)user_id;
-(NSMutableDictionary*)getReviewsForDocID:(NSString*)docid;
-(NSMutableDictionary*)getBeerReviewsByUser:(NSString*)userID seqNum:(NSNumber*)seqNum;
-(NSMutableDictionary*)getBreweriesList;

-(BOOL)restoringNavigationStateAutomatically;
-(NSObject*)nextNavigationStateToRestore;
-(BOOL)pushNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem withData:(NSObject*)data;
-(void)popNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem;
-(void)dismissActivityHUD;
-(void)presentActivityHUD:(NSString*)hudText;
-(void)performAsyncOperationWithTarget:(id)target selector:(SEL)sel object:(id)object withActivityHUD:(BOOL)withActivityHUD andActivityHUDText:(NSString*)hudText;

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
#define BEERCRUSH_API_URL_GET_ALL_BEER_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/json/review/beer/%@/%@/_all.%d"
#define BEERCRUSH_API_URL_GET_ALL_BREWERIES_DOC			@BEERCRUSH_API_URL_HOST"/json/breweries"
#define BEERCRUSH_API_URL_GET_ALL_PLACE_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/json/review/place/%@/_all.%d"
#define BEERCRUSH_API_URL_GET_BEER_DOC					@BEERCRUSH_API_URL_HOST"/json/beer/%@/%@"
#define BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC			@BEERCRUSH_API_URL_HOST"/json/review/beer/%@/%@/%@"
#define BEERCRUSH_API_URL_GET_BREWERY_BEERLIST			@BEERCRUSH_API_URL_HOST"/json/brewery/%@/beerlist"
#define BEERCRUSH_API_URL_GET_BREWERY_DOC_JSON			@BEERCRUSH_API_URL_HOST"/json/brewery/%@"
#define BEERCRUSH_API_URL_GET_COLORSLIST				@BEERCRUSH_API_URL_HOST"/json/beercolors"
#define BEERCRUSH_API_URL_GET_FLAVORS_DOC				@BEERCRUSH_API_URL_HOST"/json/flavors"
#define BEERCRUSH_API_URL_GET_MENU_DOC					@BEERCRUSH_API_URL_HOST"/json/menu/%@/%@"
#define BEERCRUSH_API_URL_GET_PLACE_DOC					@BEERCRUSH_API_URL_HOST"/json/place/%@"
#define BEERCRUSH_API_URL_GET_PLACE_REVIEW_DOC			@BEERCRUSH_API_URL_HOST"/json/review/place/%@/%@"
#define BEERCRUSH_API_URI_GET_PLACE_STYLES				@BEERCRUSH_API_URL_HOST"/json/restaurantcategories"
#define BEERCRUSH_API_URL_GET_STYLESLIST				@BEERCRUSH_API_URL_HOST"/json/styles"
#define BEERCRUSH_API_URL_GET_USER_BEER_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/json/user/%@/reviews/beer.%@"
#define BEERCRUSH_API_URL_GET_USER_PLACE_REVIEWS_DOC	@BEERCRUSH_API_URL_HOST"/json/user/%@/reviews/place.%d"
#define BEERCRUSH_API_URL_GET_USER_WISHLIST_DOC			@BEERCRUSH_API_URL_HOST"/json/user/%@/wishlist"
#define BEERCRUSH_API_URL_LOGIN							@BEERCRUSH_API_URL_HOST"/api/login"
#define BEERCRUSH_API_URL_NEARBY_QUERY					@BEERCRUSH_API_URL_HOST"/api/nearby.fcgi?lat=%f&lon=%f&within=%d"
#define BEERCRUSH_API_URL_POST_BEER_REVIEW				@BEERCRUSH_API_URL_HOST"/api/beer/review"
#define BEERCRUSH_API_URL_POST_PLACE_REVIEW				@BEERCRUSH_API_URL_HOST"/api/place/review"
#define BEERCRUSH_API_URL_SEARCH_QUERY					@BEERCRUSH_API_URL_HOST"/api/search?q=%@&dataset=%s"
#define BEERCRUSH_API_URL_UPLOAD_PLACE_IMAGE			@BEERCRUSH_API_URL_HOST"/api/place/photo?place_id=%@"
#define BEERCRUSH_API_URL_UPLOAD_BEER_IMAGE				@BEERCRUSH_API_URL_HOST"/api/beer/photo?beer_id=%@"
#define BEERCRUSH_API_URL_UPLOAD_BREWERY_IMAGE			@BEERCRUSH_API_URL_HOST"/api/brewery/?brewery_id=%@"

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


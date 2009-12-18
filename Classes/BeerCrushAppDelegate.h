//
//  BeerCrushAppDelegate.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

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
void normalizeToNumber(NSMutableDictionary* dict,NSString* key, BOOL addIfNotExist);
void normalizeToBoolean(NSMutableDictionary* dict,NSString* key,BOOL addIfNotExist);
void normalizeToArray(NSMutableDictionary* data, NSString* key, NSUInteger n);
void normalizeToDictionary(NSMutableDictionary* data, NSString* key, NSUInteger n);
void normalizeBeerData(NSMutableDictionary* beerData);
void normalizePlaceData(NSMutableDictionary* placeData);
void normalizePlaceReviewData(NSMutableDictionary* placeReviewData);
void normalizeBreweryData(NSMutableDictionary* data);
NSMutableArray* appendDifferentValuesToArray(NSArray* keyNames,NSDictionary* orig,NSDictionary* curr);


@interface BeerCrushAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate,LoginVCDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	UIProgressHUD* activityHUD;
	
	NSOperationQueue* sharedOperationQueue;
	
	NSMutableDictionary* flavorsDictionary;
	NSMutableDictionary* stylesDictionary;
	NSMutableDictionary* colorsDictionary;
	NSMutableDictionary* placeStylesDictionary;
	NSMutableDictionary* documentCache;
	
	NSMutableDictionary* restoringNavState;
	NSMutableDictionary* appState;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSOperationQueue* sharedOperationQueue;
@property (nonatomic, retain) UIProgressHUD* activityHUD;
@property (nonatomic, retain) NSMutableDictionary* flavorsDictionary;
@property (nonatomic, retain) NSMutableDictionary* stylesDictionary;
@property (nonatomic, retain) NSMutableDictionary* colorsDictionary;
@property (nonatomic, retain) NSMutableDictionary* placeStylesDictionary;
@property (nonatomic, retain) NSMutableDictionary* documentCache;
@property (nonatomic, retain) NSMutableDictionary* restoringNavState;
@property (nonatomic, retain) NSMutableDictionary* appState;

-(void)startApp;
-(void)askUserForCredentialsWithDelegate:(id<LoginVCDelegate>)delegate;
-(BOOL)haveUserCredentials;
-(BOOL)automaticLogin;
-(NSHTTPURLResponse*)sendJSONRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSObject*)data returningJSON:(NSMutableDictionary**)jsonResponse;
-(NSHTTPURLResponse*)sendRequest:(NSURL*)url usingMethod:(NSString*)method withData:(NSObject*)data returningData:(NSData**)responseData;
-(NSDictionary*)getFlavorsDictionary;
-(NSDictionary*)getStylesDictionary;
-(NSDictionary*)getColorsDictionary;
-(NSDictionary*)getPlaceStylesDictionary;
-(NSMutableDictionary*)getBeerDoc:(NSString*)beerID;
-(NSMutableDictionary*)getReviewsOfBeer:(NSString*)beerID byUserID:(NSString*)userID;
-(NSHTTPURLResponse*)postBeerReview:(NSDictionary*)userReview returningData:(NSData**)answer;
-(NSMutableDictionary*)getBreweryDoc:(NSString*)breweryID;
-(NSDictionary*)getBeerList:(NSString*)breweryID;
-(NSDictionary*)getBeerMenu:(NSString*)placeID;
-(NSMutableDictionary*)getPlaceDoc:(NSString*)placeID;
-(NSMutableDictionary*)getPlacesWithBeer:(NSString*)beerID nearLocation:(CLLocation*)location withinDistance:(NSUInteger)distance;
-(NSMutableDictionary*)getPlaceReviews:(NSString*)placeID byUser:(NSString*)user_id;
-(NSMutableDictionary*)getReviewsForDocID:(NSString*)docid;
-(NSMutableDictionary*)getBeerReviewsByUser:(NSString*)userID seqNum:(NSNumber*)seqNum;
-(NSMutableDictionary*)getBreweriesList;

//-(BOOL)restoringNavigationStateAutomatically;
//-(NSObject*)nextNavigationStateToRestore;
//-(BOOL)pushNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem withData:(NSObject*)data;
//-(void)popNavigationStateForTabBarItem:(UITabBarItem*)tabBarItem;
-(void)dismissActivityHUD;
-(void)presentActivityHUD:(NSString*)hudText;
-(void)performAsyncOperationWithTarget:(id)target selector:(SEL)sel object:(id)object requiresUserCredentials:(BOOL)requiresCredentials activityHUDText:(NSString*)hudText;

-(NSString*)breweryNameFromBeerID:(NSString*)beer_id;

-(void)genericAlert:(NSString*)message title:(NSString*)alertTitle buttonTitle:(NSString*)buttonTitle;

@end

#ifdef DEBUG
#define BEERCRUSH_API_URL_HOST					"http://duff"
#else
#define BEERCRUSH_API_URL_HOST					"http://beercrush.com"
#endif

#define BEERCRUSH_API_URL_AUTOCOMPLETE_QUERY			@BEERCRUSH_API_URL_HOST"/api/autocomplete.fcgi?q=%@&dataset=%s"
#define BEERCRUSH_API_URL_CREATE_ACCOUNT				@BEERCRUSH_API_URL_HOST"/api/createlogin"
#define BEERCRUSH_API_URL_EDIT_BEER_DOC					@BEERCRUSH_API_URL_HOST"/api/beer/edit"
#define BEERCRUSH_API_URL_EDIT_BREWERY_DOC				@BEERCRUSH_API_URL_HOST"/api/brewery/edit"
#define BEERCRUSH_API_URL_EDIT_PLACE_DOC				@BEERCRUSH_API_URL_HOST"/api/place/edit"
#define BEERCRUSH_API_URL_EDIT_MENU_DOC					@BEERCRUSH_API_URL_HOST"/api/menu/edit"
#define BEERCRUSH_API_URL_EDIT_WISHLIST_DOC				@BEERCRUSH_API_URL_HOST"/api/wishlist/edit"
#define BEERCRUSH_API_URL_GET_ALL_BEER_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/api/review/beer?beer_id=beer:%@:%@&seqnum=%d"
#define BEERCRUSH_API_URL_GET_ALL_BREWERIES_DOC			@BEERCRUSH_API_URL_HOST"/api/breweries"
#define BEERCRUSH_API_URL_GET_ALL_PLACE_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/api/review/place?place_id=place:%@&seqnum=%d"
#define BEERCRUSH_API_URL_GET_BEER_DOC					@BEERCRUSH_API_URL_HOST"/api/beer/view?beer_id=beer:%@:%@"
#define BEERCRUSH_API_URL_GET_BEER_REVIEW_DOC			@BEERCRUSH_API_URL_HOST"/api/review/beer?beer_id=beer:%@:%@&seqnum=%@"
#define BEERCRUSH_API_URL_GET_BREWERY_BEERLIST			@BEERCRUSH_API_URL_HOST"/api/brewery/beerlist?brewery_id=%@"
#define BEERCRUSH_API_URL_GET_BREWERY_DOC				@BEERCRUSH_API_URL_HOST"/api/brewery/view?brewery_id=brewery:%@"
#define BEERCRUSH_API_URL_GET_COLORSLIST				@BEERCRUSH_API_URL_HOST"/api/beercolors"
#define BEERCRUSH_API_URL_GET_FLAVORS_DOC				@BEERCRUSH_API_URL_HOST"/api/flavors"
#define BEERCRUSH_API_URL_GET_MENU_DOC					@BEERCRUSH_API_URL_HOST"/api/menu/view?place_id=%@"
#define BEERCRUSH_API_URL_GET_NEARBY_PLACES_WITH_BEER   @BEERCRUSH_API_URL_HOST"/api/nearby_beer.fcgi?lat=%f&lon=%f&within=%d&beer_id=%@"
#define BEERCRUSH_API_URL_GET_PLACE_DOC					@BEERCRUSH_API_URL_HOST"/api/place/view?place_id=place:%@"
#define BEERCRUSH_API_URL_GET_USER_PLACE_REVIEW_DOC		@BEERCRUSH_API_URL_HOST"/api/review/place?place_id=place:%@&user_id=%@"
#define BEERCRUSH_API_URI_GET_PLACE_STYLES				@BEERCRUSH_API_URL_HOST"/api/restaurantcategories"
#define BEERCRUSH_API_URL_GET_STYLESLIST				@BEERCRUSH_API_URL_HOST"/api/beerstyles"
#define BEERCRUSH_API_URL_GET_USER_BEER_REVIEWS_DOC		@BEERCRUSH_API_URL_HOST"/api/review/beer?user_id=user:%@&seqnum=%@"
#define BEERCRUSH_API_URL_GET_USER_PLACE_REVIEWS_DOC	@BEERCRUSH_API_URL_HOST"/api/review/place?user_id=user:%@&seqnum=%d"
#define BEERCRUSH_API_URL_GET_USER_WISHLIST_DOC			@BEERCRUSH_API_URL_HOST"/api/wishlist/view?user_id=user:%@"
#define BEERCRUSH_API_URL_LOGIN							@BEERCRUSH_API_URL_HOST"/api/login"
#define BEERCRUSH_API_URL_NEARBY_QUERY					@BEERCRUSH_API_URL_HOST"/api/nearby.fcgi?lat=%f&lon=%f&within=%d"
#define BEERCRUSH_API_URL_POST_BEER_REVIEW				@BEERCRUSH_API_URL_HOST"/api/beer/review"
#define BEERCRUSH_API_URL_POST_PLACE_REVIEW				@BEERCRUSH_API_URL_HOST"/api/place/review"
#define BEERCRUSH_API_URL_SEARCH_QUERY					@BEERCRUSH_API_URL_HOST"/api/search?q=%@&dataset=%s&start=%d"
#define BEERCRUSH_API_URL_UPLOAD_PLACE_IMAGE			@BEERCRUSH_API_URL_HOST"/api/place/photo?place_id=%@"
#define BEERCRUSH_API_URL_UPLOAD_BEER_IMAGE				@BEERCRUSH_API_URL_HOST"/api/beer/photo?beer_id=%@"
#define BEERCRUSH_API_URL_UPLOAD_BREWERY_IMAGE			@BEERCRUSH_API_URL_HOST"/api/brewery/photo?brewery_id=%@"

@interface UIColor (BeerCrush)

+(UIColor*)beercrushLightTanColor;
+(UIColor*)beercrushTanColor;
+(UIColor*)beercrushLightRedColor;
+(UIColor*)beercrushRedColor;
+(UIColor*)beercrushLightBlueColor;
+(UIColor*)beercrushBlueColor; 	

@end


typedef enum resultType
{
	Beer=1,
	Brewer=2,
	Place=3
} ResultType;


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


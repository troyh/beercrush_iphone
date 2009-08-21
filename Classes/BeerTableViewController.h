//
//  BeerTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BeerCrushAppDelegate.h"
#import "FullBeerReviewTVC.h"

@interface BeerTableViewController : UITableViewController <FullBeerReviewTVCDelegate> {
	NSString* beerID;
	NSString* breweryID;
	BeerObject* beerObj;
	NSMutableString* currentElemValue;
//	int xmlParseDepth;
//	BOOL bParsingBeerReview;
	NSMutableArray* xmlParserPath;
	NSMutableDictionary* userReviewData;
	
	// UI controls
	RatingControl* userRatingControl;
	RatingControl* overallRatingControl;
	UISlider* bodySlider;
	UISlider* balanceSlider;
	UISlider* aftertasteSlider;
	
	NSMutableArray* buttons;
	UIView* dataTableView;
}

@property (nonatomic,retain) NSString* beerID;
@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) BeerObject* beerObj;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (nonatomic,retain) NSMutableDictionary* userReviewData;
@property (nonatomic,retain) RatingControl* userRatingControl;
@property (nonatomic,retain) RatingControl* overallRatingControl;
@property (nonatomic,retain) UISlider* bodySlider;
@property (nonatomic,retain) UISlider* balanceSlider;
@property (nonatomic,retain) UISlider* aftertasteSlider;
@property (nonatomic,assign) NSMutableArray* buttons;
@property (nonatomic,retain) UIView* dataTableView;

-(id) initWithBeerID:(NSString*)beer_id;

@end

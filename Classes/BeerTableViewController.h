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
}

@property (nonatomic,retain) NSString* beerID;
@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) BeerObject* beerObj;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (nonatomic,retain) NSMutableDictionary* userReviewData;

-(id) initWithBeerID:(NSString*)beer_id;

@end

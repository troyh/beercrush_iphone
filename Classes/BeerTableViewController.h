//
//  BeerTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BeerCrushAppDelegate.h"

@interface BeerTableViewController : UITableViewController {
	NSString* beerID;
	NSString* breweryID;
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
	BeerObject* beerObj;
	NSMutableString* currentElemValue;
	int xmlParseDepth;
	BOOL bParsingBeerReview;
	NSMutableData* xmlPostResponse;
	UIView* overlay;
	UIActivityIndicatorView* spinner;
}

@property (nonatomic,retain) NSString* beerID;
@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) UIApplication* app;
@property (nonatomic,retain) BeerCrushAppDelegate* appdel;
@property (nonatomic,retain) BeerObject* beerObj;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic) int xmlParseDepth;
@property (nonatomic) BOOL bParsingBeerReview;
@property (nonatomic, retain) NSMutableData* xmlPostResponse;
@property (nonatomic, retain) UIView* overlay;
@property (nonatomic, retain) UIActivityIndicatorView* spinner;

-(id) initWithBeerID:(NSString*)beer_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d;

@end

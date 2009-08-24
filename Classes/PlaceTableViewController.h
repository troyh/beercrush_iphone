//
//  BreweryTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"
#import "NearbyTableViewController.h"

@interface PlaceTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate> {
	NSString* placeID;
	//	NSMutableArray* breweryInfo;
	PlaceObject* placeObject;
	NSMutableString* currentElemValue;
	NSMutableData* xmlPostResponse;
	UIView* overlay;
	UIActivityIndicatorView* spinner;
	NSMutableArray* xmlParserPath;
}

@property (nonatomic,retain) NSString* placeID;
@property (nonatomic,retain) PlaceObject* placeObject;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableData* xmlPostResponse;
@property (nonatomic, retain) UIView* overlay;
@property (nonatomic, retain) UIActivityIndicatorView* spinner;
@property (nonatomic, retain) NSMutableArray* xmlParserPath;

-(id) initWithPlaceID:(NSString*)place_id;
//- (void)editPlace:(id)sender;

@end

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
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
	NSString* placeID;
	//	NSMutableArray* breweryInfo;
	PlaceObject* placeObject;
	NSMutableString* currentElemValue;
	NSMutableData* reviewPostResponse;
}

@property (nonatomic,retain) NSString* placeID;
@property (nonatomic,retain) PlaceObject* placeObject;
@property (nonatomic,retain) UIApplication* app;
@property (nonatomic,retain) BeerCrushAppDelegate* appdel;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableData* reviewPostResponse;

-(id) initWithPlaceID:(NSString*)place_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d;
- (void)editPlace:(id)sender;

@end

//
//  BreweryTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"

@interface BreweryObject: NSObject
{
	NSString* name;
	NSString* street;
	NSString* city;
	NSString* state;
	NSString* zip;
	NSString* phone;
}

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* street;
@property (nonatomic,retain) NSString* city;
@property (nonatomic,retain) NSString* state;
@property (nonatomic,retain) NSString* zip;
@property (nonatomic,retain) NSString* phone;

-(id)init;

@end

@interface BreweryTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate> {
	NSString* breweryID;
//	NSMutableArray* breweryInfo;
	BreweryObject* breweryObject;
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
	NSMutableString* currentElemValue;
	NSMutableData* reviewPostResponse;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) BreweryObject* breweryObject;
@property (nonatomic,retain) UIApplication* app;
@property (nonatomic,retain) BeerCrushAppDelegate* appdel;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableData* reviewPostResponse;

-(id) initWithBreweryID:(NSString*)brewery_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d;

@end

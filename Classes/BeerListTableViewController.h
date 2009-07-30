//
//  BeerListTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerTableViewController.h"

@interface BeerListTableViewController : UITableViewController {
	NSString* breweryID;
	NSMutableArray* beerList;
	NSMutableString* currentElemValue;
	NSMutableDictionary* currentElemAttribs;
	UIApplication* app;
	BeerTableViewController* btvc;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) NSMutableArray* beerList;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableDictionary* currentElemAttribs;
@property (nonatomic,retain) UIApplication* app;
@property (nonatomic,retain) BeerTableViewController* btvc;

-(id)initWithBreweryID:(NSString*)brewery_id andApp:(UIApplication*)app;
-(void)newBeerPanel;
-(void)newBeerSaveButtonClicked;
-(void)newBeerCancelButtonClicked;

@end

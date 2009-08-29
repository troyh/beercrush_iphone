//
//  BeerListTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerTableViewController.h"

@interface BeerListTableViewController : UITableViewController <BeerTableViewControllerDelegate> {
	NSString* breweryID;
	NSString* placeID;
	NSString* wishlistID;
	
	NSMutableArray* beerList;
	NSMutableString* currentElemValue;
	NSMutableDictionary* currentElemAttribs;
	NSMutableArray* xmlParserPath;
	BeerTableViewController* btvc;
	BOOL setRightBarButtonItem;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) NSString* placeID;
@property (nonatomic,retain) NSString* wishlistID;
@property (nonatomic,retain) NSMutableArray* beerList;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableDictionary* currentElemAttribs;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (nonatomic,retain) BeerTableViewController* btvc;
@property (nonatomic,assign) BOOL setRightBarButtonItem;

-(id)initWithBreweryID:(NSString*)brewery_id;
-(void)newBeerPanel;
-(void)addBeerToMenu:(NSString*)beerID;
-(void)didSaveBeerEdits;
-(void)didCancelBeerEdits;

@end

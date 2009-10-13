//
//  MyTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"
#import "BreweryTableViewController.h"
#import "BeerTableViewController.h"
#import "PlaceTableViewController.h"
#import "LogoVC.h"
#import "SearchVC.h"

@interface MyTableViewController : UITableViewController 
{
	BeerCrushSearchType searchTypes;
	NSMutableArray* resultsList;
	BOOL performedSearchQuery;
}

@property (nonatomic, retain) NSMutableArray* resultsList;
@property (nonatomic, assign) BOOL performedSearchQuery;
@property (nonatomic, assign) BeerCrushSearchType searchTypes;

@end


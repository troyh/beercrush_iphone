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

typedef enum
{
	BeerCrushSearchTypeBeers = 1,
	BeerCrushSearchTypeBreweries = 2,
	BeerCrushSearchTypePlaces = 4
} BeerCrushSearchType;

@interface MyTableViewController : UITableViewController 
	<UISearchBarDelegate,
	UIActionSheetDelegate,
	BreweryVCDelegate,
	PlaceVCDelegate>
{
	UISearchBar* searchBar;
	NSMutableArray* resultsList;
	int searchTypes;
	BOOL performedSearchQuery;
}

@property (nonatomic,retain) UISearchBar* searchBar;
@property (nonatomic, retain) NSMutableArray* resultsList;
@property (nonatomic, assign) int searchTypes;
@property (nonatomic, assign) BOOL performedSearchQuery;

-(void)autocomplete:(NSString*)qs;
-(void)query:(NSString*)qs;

@end

typedef enum resultType
{
	Beer=1,
	Brewer=2,
	Place=3
} ResultType;

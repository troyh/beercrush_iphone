//
//  SearchVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 10/1/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceTableViewController.h"
#import "BreweryTableViewController.h"
#import "LogoVC.h"

typedef enum
{
	BeerCrushSearchTypeBeers = 1,
	BeerCrushSearchTypeBreweries = 2,
	BeerCrushSearchTypePlaces = 4
} BeerCrushSearchType;

@protocol SearchVCDelegate;

@interface SearchVC : UIViewController 
	<UISearchBarDelegate,
	BreweryVCDelegate,
	PlaceVCDelegate,
	UITableViewDelegate,
	UITableViewDataSource>
{
	LogoVC* logoView;
	BeerCrushSearchType searchTypes;
	id<SearchVCDelegate> delegate;
	UISearchBar* searchBar;
	NSMutableArray* resultsList;
	BOOL performedSearchQuery;
	BOOL isPerformingAsyncQuery;
	UIEdgeInsets insets;
}

@property (nonatomic, retain) NSMutableArray* resultsList;
@property (nonatomic,retain) UISearchBar* searchBar;
@property (nonatomic, retain) LogoVC* logoView;
@property (nonatomic, assign) BeerCrushSearchType searchTypes;
@property (nonatomic, assign) id<SearchVCDelegate> delegate;
@property (nonatomic, assign) BOOL performedSearchQuery;
@property (nonatomic, assign) BOOL isPerformingAsyncQuery;
@property (nonatomic, assign) UIEdgeInsets insets;

-(void)autocomplete:(NSString*)qs;
-(void)query:(NSString*)qs;

@end

@protocol SearchVCDelegate

-(BOOL)searchVC:(SearchVC*)searchVC didSelectSearchResult:(NSString*)id_string;

@end

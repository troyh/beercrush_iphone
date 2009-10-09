//
//  BrowseBrewersTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BrowseBrewersTVC : UITableViewController {
	NSMutableArray* breweryList;
	NSMutableArray* breweryGroups;
	NSMutableArray* currentGroup;
	NSMutableDictionary* currentBrewery;
}

@property (nonatomic,retain) NSMutableArray* breweryList;
@property (nonatomic,retain) NSMutableArray* breweryGroups;
@property (nonatomic,retain) NSMutableArray* currentGroup;
@property (nonatomic,retain) NSMutableDictionary* currentBrewery;

@end

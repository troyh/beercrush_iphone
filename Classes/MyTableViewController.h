//
//  MyTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"

@interface MyTableViewController : UITableViewController <UISearchBarDelegate> {
	UISearchBar* searchBar;
	NSInteger autoCompleteResultsCount;
	NSData* autoCompleteResultsData;
}

@property (nonatomic,retain) UISearchBar* searchBar;
@property (nonatomic) NSInteger autoCompleteResultsCount;
@property (nonatomic, retain) NSData* autoCompleteResultsData;

-(void)query:(NSString*)qs;

@end

typedef enum resultType
{
	Beer=1,
	Brewer=2,
	Place=3
} ResultType;

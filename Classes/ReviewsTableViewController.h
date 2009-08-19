//
//  ReviewsTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTableViewController.h"
#import "BeerTableViewController.h"

@interface ReviewsTableViewController : UITableViewController {
	NSString* reviewedDocID;
	NSMutableArray* xmlParserPath;
	NSMutableArray* reviewsList;
	NSMutableString* currentElemValue;
	NSInteger totalReviews;
	BeerTableViewController* beerTVC;
}

@property (nonatomic,retain) NSString* reviewedDocID;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (nonatomic,retain) NSMutableArray* reviewsList;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic) NSInteger totalReviews;
@property (nonatomic,retain) BeerTableViewController* beerTVC;

-(id)initWithID:(NSString*)dataid dataType:(ResultType)t;

@end

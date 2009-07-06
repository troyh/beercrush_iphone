//
//  ReviewsTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTableViewController.h"

@interface ReviewsTableViewController : UITableViewController {
	NSString* beerID;
	NSMutableArray* xmlParserPath;
	NSMutableArray* reviewsList;
	NSMutableString* currentElemValue;
}

@property (nonatomic,retain) NSString* beerID;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (nonatomic,retain) NSMutableArray* reviewsList;
@property (nonatomic,retain) NSMutableString* currentElemValue;

-(id)initWithID:(NSString*)dataid dataType:(ResultType)t;

@end

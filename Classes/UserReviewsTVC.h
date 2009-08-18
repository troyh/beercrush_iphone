//
//  UserReviewsTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 7/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullBeerReviewTVC.h"

@interface UserReviewsTVC : UITableViewController <FullBeerReviewTVCDelegate> {
	NSMutableArray* reviewsList;
	NSMutableArray* xmlParserPath;
	NSMutableString* currentElemValue;
	NSUInteger selectedRow;
}

@property (nonatomic,retain) NSMutableArray* reviewsList;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,assign) NSUInteger selectedRow;

@end

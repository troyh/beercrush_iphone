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
	NSUInteger totalReviews;
	NSUInteger seqNext;
	NSUInteger seqMax;
}

@property (nonatomic,retain) NSMutableArray* reviewsList;
@property (nonatomic,assign) NSUInteger totalReviews;
@property (nonatomic,assign) NSUInteger seqNext;
@property (nonatomic,assign) NSUInteger seqMax;

-(void)retrieveReviews:(NSUInteger)seqnum;

@end

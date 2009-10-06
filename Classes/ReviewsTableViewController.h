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
#import "FullBeerReviewTVC.h"

@interface ReviewsTableViewController : UITableViewController <FullBeerReviewTVCDelegate> {
	NSString* reviewedDocID;
	NSMutableArray* reviewsList;
	NSUInteger totalReviews;
	NSUInteger reviewsSeqNum;
	NSUInteger reviewsSeqMax;
	id<FullBeerReviewTVCDelegate> fullBeerReviewDelegate;
}

@property (nonatomic,retain) NSString* reviewedDocID;
@property (nonatomic,retain) NSMutableArray* reviewsList;
@property (nonatomic, assign) NSUInteger totalReviews;
@property (nonatomic, assign) NSUInteger reviewsSeqNum;
@property (nonatomic, assign) NSUInteger reviewsSeqMax;
@property (assign) id<FullBeerReviewTVCDelegate> fullBeerReviewDelegate;

-(id)initWithID:(NSString*)dataid dataType:(ResultType)t;

@end

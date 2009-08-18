//
//  FullBeerReviewTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"
#import "RatingControl.h"
#import "FlavorsAromasTVC.h"

@protocol FullBeerReviewTVCDelegate
@optional

-(BOOL)hasUserReview;
-(NSMutableDictionary*)getUserReview;
-(void)fullBeerReviewPosted;

@end

@interface FullBeerReviewTVC : UITableViewController <FlavorsAromasTVCDelegate> {
	BeerObject* beerObj;
	UISlider* balanceSlider;
	UISlider* bodySlider;
	UISlider* aftertasteSlider;
	RatingControl* ratingControl;
	id<FullBeerReviewTVCDelegate> delegate;
}

@property (nonatomic, retain) BeerObject* beerObj;
@property (nonatomic, retain) UISlider* balanceSlider;
@property (nonatomic, retain) UISlider* bodySlider;
@property (nonatomic, retain) UISlider* aftertasteSlider;
@property (nonatomic, retain) RatingControl* ratingControl;
@property (assign) id<FullBeerReviewTVCDelegate> delegate;

-(id)initWithBeerObject:(BeerObject*)beer;

@end

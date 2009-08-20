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
	NSMutableDictionary* userReview;
	
	RatingControl* ratingControl;
	UISlider* bodySlider;
	UISlider* balanceSlider;
	UISlider* aftertasteSlider;
	UILabel* flavorsLabel;
	UITextView* commentsTextView;
	
	id<FullBeerReviewTVCDelegate> delegate;
}

@property (nonatomic, retain) BeerObject* beerObj;
@property (nonatomic, retain) NSMutableDictionary* userReview;
@property (assign) id<FullBeerReviewTVCDelegate> delegate;
@property (nonatomic, retain) RatingControl* ratingControl;
@property (nonatomic, retain) UISlider* bodySlider;
@property (nonatomic, retain) UISlider* balanceSlider;
@property (nonatomic, retain) UISlider* aftertasteSlider;
@property (nonatomic, retain) UILabel* flavorsLabel;
@property (nonatomic, retain) UITextView* commentsTextView;

-(id)initWithBeerObject:(BeerObject*)beer andReview:(NSDictionary*)review;
-(NSString*)getFlavorsCellText;
-(UIView*)view:(UIView*)view findSubviewOfClass:(Class)class;

@end

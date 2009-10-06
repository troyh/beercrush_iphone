//
//  FullBeerReviewTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchVC.h"
#import "RatingControl.h"
#import "FlavorsAromasTVC.h"
#import "DatePickerVC.h"
#import "PouredFromVC.h"

@protocol FullBeerReviewTVCDelegate

-(void)fullBeerReview:(NSDictionary*)userReview withChanges:(BOOL)modified;
-(NSString*)beerName;
-(NSString*)breweryName;

@end

@interface FullBeerReviewTVC : UITableViewController <FlavorsAromasTVCDelegate,DatePickerVCDelegate,PouredFromVCDelegate,SearchVCDelegate,EditLineVCDelegate> {
	NSMutableDictionary* userReview;
	
	RatingControl* ratingControl;
	UISlider* bodySlider;
	UISlider* balanceSlider;
	UISlider* aftertasteSlider;
	UILabel* flavorsLabel;
	UITextView* commentsTextView;
	
	id<FullBeerReviewTVCDelegate> delegate;
}

@property (nonatomic, retain) NSMutableDictionary* userReview;
@property (assign) id<FullBeerReviewTVCDelegate> delegate;
@property (nonatomic, retain) RatingControl* ratingControl;
@property (nonatomic, retain) UISlider* bodySlider;
@property (nonatomic, retain) UISlider* balanceSlider;
@property (nonatomic, retain) UISlider* aftertasteSlider;
@property (nonatomic, retain) UILabel* flavorsLabel;
@property (nonatomic, retain) UITextView* commentsTextView;

-(id)initWithReviewObject:(NSDictionary*)review;
-(NSString*)getFlavorsCellText;

@end

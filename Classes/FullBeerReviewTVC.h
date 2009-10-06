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

@protocol FullBeerReviewTVCDelegate;

@interface FullBeerReviewTVC : UITableViewController <FlavorsAromasTVCDelegate,DatePickerVCDelegate,PouredFromVCDelegate,SearchVCDelegate,EditLineVCDelegate> {
	id<FullBeerReviewTVCDelegate> delegate;
	NSMutableDictionary* userReview;
@private	
	RatingControl* ratingControl;
	UISlider* bodySlider;
	UISlider* balanceSlider;
	UISlider* aftertasteSlider;
	UILabel* flavorsLabel;
	UITextView* commentsTextView;
	
}

@property (nonatomic, retain) NSMutableDictionary* userReview;
@property (assign) id<FullBeerReviewTVCDelegate> delegate;
@property (nonatomic, retain) RatingControl* ratingControl;
@property (nonatomic, retain) UISlider* bodySlider;
@property (nonatomic, retain) UISlider* balanceSlider;
@property (nonatomic, retain) UISlider* aftertasteSlider;
@property (nonatomic, retain) UILabel* flavorsLabel;
@property (nonatomic, retain) UITextView* commentsTextView;

-(id)initAsNewReviewOfBeer:(NSDictionary*)beer;
-(id)initWithReviewObject:(NSDictionary*)review;
-(NSString*)getFlavorsCellText;

@end

@protocol FullBeerReviewTVCDelegate

-(void)fullBeerReview:(NSDictionary*)userReview withChanges:(BOOL)modified;
-(void)fullBeerReviewVCReviewCancelled:(FullBeerReviewTVC *)vc;
-(NSDictionary*)fullBeerReviewGetBeerData;
-(NSString*)beerName;
-(NSString*)breweryName;

@end

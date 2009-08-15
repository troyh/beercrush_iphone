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

@interface FullBeerReviewTVC : UITableViewController {
	BeerObject* beerObj;
	UISlider* balanceSlider;
	UISlider* bodySlider;
	UISlider* aftertasteSlider;
	RatingControl* ratingControl;
}

@property (nonatomic, retain) BeerObject* beerObj;
@property (nonatomic, retain) UISlider* balanceSlider;
@property (nonatomic, retain) UISlider* bodySlider;
@property (nonatomic, retain) UISlider* aftertasteSlider;
@property (nonatomic, retain) RatingControl* ratingControl;

-(id)initWithBeerObject:(BeerObject*)beer;

@end

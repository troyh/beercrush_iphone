//
//  FullBeerReviewTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"

@interface FullBeerReviewTVC : UITableViewController {
	BeerObject* beerObj;
}

@property (nonatomic, retain) BeerObject* beerObj;

-(id)initWithBeerObject:(BeerObject*)beer;

@end

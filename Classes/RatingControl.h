//
//  RatingControl.h
//  BeerCrush
//
//  Created by Troy Hakala on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//#import <Cocoa/Cocoa.h>

@interface RatingControl : UIControl
{
	NSUInteger highestRating;
	NSUInteger currentRating;
	NSMutableArray* starImageViews;
	CGRect starBox;
}

@property (nonatomic,assign) NSUInteger highestRating;
@property (nonatomic,assign) NSUInteger currentRating;
@property (nonatomic,retain) NSMutableArray* starImageViews;
@property (nonatomic,assign) CGRect starBox;

- (void)setStarsForRating:(NSUInteger)rating;
- (NSUInteger)setStarsForTouch:(UITouch*)pt;

@end


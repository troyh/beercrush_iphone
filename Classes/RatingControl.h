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
}

@property (nonatomic,assign) NSUInteger highestRating;
@property (nonatomic,assign) NSUInteger currentRating;
@property (nonatomic,retain) NSMutableArray* starImageViews;

- (void)setStarsForRating:(NSUInteger)rating;
- (NSUInteger)setStarsForPoint:(CGPoint)pt;

@end


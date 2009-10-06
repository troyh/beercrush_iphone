//
//  RatingView.m
//  BeerCrush
//
//  Created by Troy Hakala on 10/6/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import "RatingView.h"


@implementation RatingView

@synthesize rating;
@synthesize starFull;
@synthesize starHalf;
@synthesize starNone;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		// Get the 3 types of stars
		self.starFull=[UIImage imageNamed:@"star_sm_full.png"];
		self.starHalf=[UIImage imageNamed:@"star_sm_half.png"];
		self.starNone=[UIImage imageNamed:@"star_sm_empty.png"];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context=UIGraphicsGetCurrentContext();
	UIColor* bg=[UIColor whiteColor];
	CGContextSetFillColorWithColor(context, bg.CGColor);
	CGContextFillRect(context, rect);
	int w=rect.size.width/5;
	int h=(rect.size.height - self.starFull.size.height)/2;
	for (int i=1; i <= 5; ++i) {
		if (i <= self.rating)
			[self.starFull drawAtPoint:CGPointMake(rect.origin.x + ((i-1) * w), rect.origin.y + h)];
		else if ((i-1) < self.rating)
			[self.starHalf drawAtPoint:CGPointMake(rect.origin.x + ((i-1) * w), rect.origin.y + h)];
		else
			[self.starNone drawAtPoint:CGPointMake(rect.origin.x + ((i-1) * w), rect.origin.y + h)];
	}
	
}


- (void)dealloc {
    [super dealloc];
}


@end

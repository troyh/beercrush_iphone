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
//@synthesize starFull;
//@synthesize starHalf;
//@synthesize starNone;

static UIImage* starFull;
static UIImage* starHalf;
static UIImage* starNone;

+(UIImage*)starFull { 
	if (starFull==nil)
		starFull=[UIImage imageNamed:@"star_sm_full.png"];
	return starFull; 
}

+(UIImage*)starHalf {
	if (starHalf==nil)
		starHalf=[UIImage imageNamed:@"star_sm_half.png"];
	return starHalf;
}

+(UIImage*)starNone {
	if (starNone==nil)
		starNone=[UIImage imageNamed:@"star_sm_empty.png"];
	return starNone;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		// Get the 3 types of stars
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context=UIGraphicsGetCurrentContext();
	UIColor* bg=[UIColor whiteColor];
	CGContextSetFillColorWithColor(context, bg.CGColor);
	CGContextFillRect(context, rect);
	int w=rect.size.width/5;
	int h=(rect.size.height - [RatingView starFull].size.height)/2;
	for (int i=1; i <= 5; ++i) {
		if (i <= self.rating)
			[[RatingView starFull] drawAtPoint:CGPointMake(rect.origin.x + ((i-1) * w), rect.origin.y + h)];
		else if ((i-1) < self.rating)
			[[RatingView starHalf] drawAtPoint:CGPointMake(rect.origin.x + ((i-1) * w), rect.origin.y + h)];
		else
			[[RatingView starNone] drawAtPoint:CGPointMake(rect.origin.x + ((i-1) * w), rect.origin.y + h)];
	}
	
}


- (void)dealloc {
    [super dealloc];
}


@end

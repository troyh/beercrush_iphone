//
//  RatingControl.m
//  BeerCrush
//
//  Created by Troy Hakala on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RatingControl.h"

@implementation RatingControl

@synthesize highestRating;
@synthesize currentRating;
@synthesize starImageViews;

#define kDefaultHighestRating 5

- (id)initWithFrame:(CGRect)aRect
{
	[super initWithFrame:aRect];

	self.contentMode=UIViewContentModeCenter;
	
	self.highestRating=kDefaultHighestRating;
	self.currentRating=0; // Default is no rating
	self.starImageViews=[[NSMutableArray alloc] initWithCapacity:self.highestRating];

	if ([self.starImageViews count]==0)
	{
		// Put star images in
		int partition_width=self.frame.size.width/self.highestRating;
		for (int i=0;i<self.highestRating;++i)
		{
			UIImage* emptyStarImage=[UIImage imageNamed:@"dot.png"];
			if (emptyStarImage)
			{
				UIImage* starImage=[UIImage imageNamed:@"star_filled.png"];
				if (starImage)
				{
					UIImageView* iv=[[UIImageView alloc] initWithImage:emptyStarImage highlightedImage:starImage];
					iv.center=CGPointMake((i*partition_width)+(0.5*partition_width),self.frame.size.height/2);
					[self addSubview:iv];
					
					[self.starImageViews addObject:iv];
					
					[iv release];
				}
			}
		}
	}
//	[self setStarsForRating:self.currentRating];
	
	return self;
}

-(void)dealloc
{
	[self.starImageViews release];
	[super dealloc];
}

//-(void)drawRect:(CGRect)rect
//{
//	[super drawRect:rect];
//	[self.superview drawRect:rect];
//	[self setStarsForRating:self.currentRating];
//}

//- (void)willRemoveSubview:(UIView *)subview
//{
//	[super willRemoveSubview:subview];
//}

- (void)setStarsForRating:(NSUInteger)rating
{
	// Highlight all stars up to touchedRating
	for (int i=0;i<self.highestRating;++i)
	{
		UIImageView* iv=[self.starImageViews objectAtIndex:i];
		iv.highlighted=(i < rating)?YES:NO;
	}
}

- (NSUInteger)setStarsForPoint:(CGPoint)pt
{
	int touchedRating=(pt.x / (self.frame.size.width/self.highestRating))+1;
	[self setStarsForRating:touchedRating];
	return touchedRating;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self setStarsForPoint:[touch locationInView:touch.view]];
	return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self setStarsForPoint:[touch locationInView:touch.view]];
	return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (touch.phase==UITouchPhaseEnded)
	{
		CGPoint pt=[touch locationInView:touch.view];
		if ([self pointInside:pt withEvent:event])
		{
			self.currentRating=[self setStarsForPoint:pt];
			// Notify the owner of a rating
			[self sendActionsForControlEvents:UIControlEventValueChanged];
		}
		else // User lifted finger outside of rating area, cancelling review
		{
			// Revert to current rating
			[self setStarsForRating:self.currentRating];
		}
	}
}

- (void)didMoveToWindow
{
	if (self.window!=nil)
		[self setStarsForRating:self.currentRating];
}

@end


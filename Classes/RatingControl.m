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
@synthesize starBox;

#define kDefaultHighestRating 5
#define kFramePadding 40

- (id)initWithFrame:(CGRect)aRect
{
	[super initWithFrame:aRect];

	self.contentMode=UIViewContentModeCenter;
	
	self.highestRating=kDefaultHighestRating;
	self.currentRating=0; // Default is no rating
	self.starImageViews=[NSMutableArray arrayWithCapacity:self.highestRating];

	// Shrink it a bit to make it look better
	CGRect tmp=CGRectInset(aRect,kFramePadding,0);
	tmp.origin.x-=10;
	self.starBox=tmp;

//	self.frame=self.superview.frame;
	if ([self.starImageViews count]==0)
	{
		// Put star images in
		int partition_width=self.starBox.size.width/self.highestRating;
		//NSLog(@"Partition width:%d",partition_width);
		for (int i=0;i<self.highestRating;++i)
		{
			UIImage* emptyStarImage=[UIImage imageNamed:@"dot.png"];
			if (emptyStarImage)
			{
				UIImage* starImage=[UIImage imageNamed:@"star_filled.png"];
				if (starImage)
				{
					UIImageView* iv=[[UIImageView alloc] initWithImage:emptyStarImage highlightedImage:starImage];
					iv.center=CGPointMake((self.starBox.origin.x-self.frame.origin.x)+(i*partition_width)+(0.5*partition_width),self.frame.size.height/2);
					//NSLog(@"Center #%d:%d",i,(int)iv.center.x);
					[self addSubview:iv];
					
					[self.starImageViews addObject:iv];
					
					[iv release];
					[starImage release];
				}
				[emptyStarImage release];
			}
		}
	}
//	[self setStarsForRating:self.currentRating];
	
	return self;
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

- (NSUInteger)setStarsForTouch:(UITouch*)touch
{
	CGPoint pt=[touch locationInView:touch.view];
	if (CGRectContainsPoint(self.starBox, pt))
	{
		pt.x-=(self.frame.size.width - self.starBox.size.width)/2;
		int touchedRating=(pt.x / (self.starBox.size.width/self.highestRating))+1;

		[self setStarsForRating:touchedRating];
		return touchedRating;
	}
	return self.currentRating;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self setStarsForTouch:touch];
	return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self setStarsForTouch:touch];
	return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (touch.phase==UITouchPhaseEnded)
	{
		CGPoint pt=[touch locationInView:touch.view];
		//		if ([self pointInside:pt withEvent:event])
		if (CGRectContainsPoint(self.starBox, pt))
		{
			self.currentRating=[self setStarsForTouch:touch];
			//NSLog(@"star rating:%d",self.currentRating);
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
	[self setStarsForRating:self.currentRating];
}

@end


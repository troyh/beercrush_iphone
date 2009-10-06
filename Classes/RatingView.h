//
//  RatingView.h
//  BeerCrush
//
//  Created by Troy Hakala on 10/6/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RatingView : UIView {
	float rating;
@private
	UIImage* starFull;
	UIImage* starHalf;
	UIImage* starNone;
}

@property (nonatomic, assign) float rating;
@property (nonatomic, retain) UIImage* starFull;
@property (nonatomic, retain) UIImage* starHalf;
@property (nonatomic, retain) UIImage* starNone;

@end

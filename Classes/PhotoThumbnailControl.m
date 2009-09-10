//
//  PhotoThumbnailControl.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PhotoThumbnailControl.h"


@implementation PhotoThumbnailControl

@synthesize image;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	[self.image drawInRect:rect];
}


- (void)dealloc {
	[self.image release];
	
    [super dealloc];
}


@end

//
//  ColorsTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorsTVCDelegate;

@interface ColorsTVC : UITableViewController {
	NSDictionary* colorsDict;
	NSUInteger selectedColorSRM;
	id<ColorsTVCDelegate> delegate;
}

@property (nonatomic,retain) NSDictionary* colorsDict;
@property (nonatomic,assign) NSUInteger selectedColorSRM;
@property (assign) id<ColorsTVCDelegate> delegate;

@end

@protocol ColorsTVCDelegate

-(void)colorsTVC:(ColorsTVC*)tvc didSelectColor:(NSUInteger)srm;

@end

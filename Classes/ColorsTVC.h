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

	NSMutableDictionary* colorsList;
	NSMutableArray* colorsNums;
	
	NSMutableString* currentElemValue;
	NSMutableArray* xmlParserPath;
	
	id<ColorsTVCDelegate> delegate;
	
}

@property (nonatomic,retain) NSMutableDictionary* colorsList;
@property (nonatomic,retain) NSMutableArray* colorsNums;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;

@property (assign) id<ColorsTVCDelegate> delegate;

@end

@protocol ColorsTVCDelegate

-(void)colorsTVC:(ColorsTVC*)tvc didSelectColor:(NSUInteger)srm;

@end

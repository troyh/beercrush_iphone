//
//  MyTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"

@interface MyTableViewController : UITableViewController {
	NSMutableArray* searchResultsList_title;
	NSMutableArray* searchResultsList_desc;
	NSMutableArray* searchResultsList_type;
	NSMutableArray* searchResultsList_uri;
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
}

@property (nonatomic, retain) UIApplication* app;
@property (nonatomic, retain) BeerCrushAppDelegate* appdel;

-(void)query:(NSString*)qs;

@end

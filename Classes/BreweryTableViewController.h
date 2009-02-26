//
//  BreweryTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"

@interface BreweryTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate> {
	NSString* breweryID;
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) UIApplication* app;
@property (nonatomic,retain) BeerCrushAppDelegate* appdel;

-(id) initWithBreweryID:(NSString*)brewery_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d;

@end

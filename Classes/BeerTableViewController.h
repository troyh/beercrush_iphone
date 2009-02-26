//
//  BeerTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BeerCrushAppDelegate.h"

@interface BeerTableViewController : UITableViewController {
	NSString* beerID;
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
}

@property (nonatomic,retain) NSString* beerID;
@property (nonatomic,retain) UIApplication* app;
@property (nonatomic,retain) BeerCrushAppDelegate* appdel;

-(id) initWithBeerID:(NSString*)beer_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d;

@end

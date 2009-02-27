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
	NSMutableArray* searchResultsList_id;
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
	NSMutableString* currentElemValue;
	BOOL bInResultElement;
}

@property (nonatomic, retain) UIApplication* app;
@property (nonatomic, retain) BeerCrushAppDelegate* appdel;
@property (nonatomic, retain) NSMutableString* currentElemValue;
@property (nonatomic) BOOL bInResultElement;

-(void)query:(NSString*)qs;

@end

typedef enum resultType
{
	Beer=1,
	Brewer=2
} ResultType;

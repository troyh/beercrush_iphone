//
//  BreweryTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"
#import "CountryListTVC.h"
#import "EditTextVC.h"

@interface BreweryObject: NSObject
{
	NSMutableDictionary* data;
}

@property (nonatomic,retain) NSMutableDictionary* data;

-(id)init;

@end

@interface BreweryTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,CountryListTVCDelegate,EditTextVCDelegate,UITextViewDelegate> {
	NSString* breweryID;
	BreweryObject* breweryObject;
	NSDictionary* originalBreweryData;
	NSMutableString* currentElemValue;
	NSMutableArray* xmlParserPath;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) BreweryObject* breweryObject;
@property (nonatomic,retain) NSDictionary* originalBreweryData;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;

-(id) initWithBreweryID:(NSString*)brewery_id;

@end

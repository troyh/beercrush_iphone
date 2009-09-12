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
#import "PhotoViewer.h"

@interface BreweryObject: NSObject
{
	NSMutableDictionary* data;
}

@property (nonatomic,retain) NSMutableDictionary* data;

-(id)init;

@end

@protocol BreweryVCDelegate;

@interface BreweryTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate,CountryListTVCDelegate,EditTextVCDelegate,UITextViewDelegate,PhotoViewerDelegate> {
	NSString* breweryID;
	BreweryObject* breweryObject;
	NSDictionary* originalBreweryData;
	NSMutableString* currentElemValue;
	NSMutableArray* xmlParserPath;
	id<BreweryVCDelegate> delegate;
	BOOL editingWasCanceled;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) BreweryObject* breweryObject;
@property (nonatomic,retain) NSDictionary* originalBreweryData;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (assign) id<BreweryVCDelegate> delegate;
@property (assign) BOOL editingWasCanceled;

-(id) initWithBreweryID:(NSString*)brewery_id;
-(void)startEditingMode;
-(void)endEditingMode;

@end

@protocol BreweryVCDelegate

-(void)breweryVCDidCancelEditing:(BreweryTableViewController*)btvc;

@end

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
#import "EditURIVC.h"
#import "EditLineVC.h"
#import "EditAddressVC.h"
#import "PhoneNumberEditTableViewController.h"

@interface BreweryObject: NSObject
{
	NSMutableDictionary* data;
}

@property (nonatomic,retain) NSMutableDictionary* data;

-(id)init;

@end

@protocol BreweryVCDelegate;

@interface BreweryTableViewController : UITableViewController 
	<UITableViewDataSource,
	UITableViewDelegate,
	CountryListTVCDelegate,
	EditTextVCDelegate,
	UITextViewDelegate,
	PhotoViewerDelegate,
	EditURIVCDelegate,
	EditLineVCDelegate,
	EditAddressVCDelegate,
	PhoneNumberEditVCDelegate> 
{
	NSString* breweryID;
	BreweryObject* breweryObject;
	NSDictionary* originalBreweryData;
	NSDictionary* beerList;
	id<BreweryVCDelegate> delegate;
	BOOL editingWasCanceled;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) BreweryObject* breweryObject;
@property (nonatomic,retain) NSDictionary* originalBreweryData;
@property (nonatomic,retain) NSDictionary* beerList;
@property (assign) id<BreweryVCDelegate> delegate;
@property (assign) BOOL editingWasCanceled;

-(id) initWithBreweryID:(NSString*)brewery_id;
-(void)startEditingMode;
-(void)endEditingMode;

@end

@protocol BreweryVCDelegate

-(void)breweryVCDidFinishEditing:(BreweryTableViewController*)btvc;
-(void)breweryVCDidCancelEditing:(BreweryTableViewController*)btvc;

@end

//
//  BreweryTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerCrushAppDelegate.h"
#import "NearbyTableViewController.h"
#import "PlaceTypeTVC.h"
#import "PlaceStyleTVC.h"
#import "EditTextVC.h"
#import "PlacePriceTVC.h"
#import "EditAddressVC.h"
#import "EditURIVC.h"
#import "PhoneNumberEditTableViewController.h"
#import "PhotoViewer.h"

@interface PlaceTableViewController : UITableViewController 
	<UITableViewDataSource,
	UITableViewDelegate,
	EditTextVCDelegate,
	PlaceTypeTVCDelegate,
	PlaceStyleTVCDelegate,
	PlacePriceTVCDelegate,
	EditAddressVCDelegate,
	EditURIVCDelegate,
	PhoneNumberEditVCDelegate,
	PhotoViewerDelegate> 
{
	NSString* placeID;
	NSMutableDictionary* placeData;
	NSDictionary* originalPlaceData;
	NSMutableString* currentElemValue;
	NSMutableData* xmlPostResponse;
	UIView* overlay;
	UIActivityIndicatorView* spinner;
	NSMutableArray* xmlParserPath;
}

@property (nonatomic,retain) NSString* placeID;
@property (nonatomic, retain) NSMutableDictionary* placeData;
@property (nonatomic,retain) NSDictionary* originalPlaceData;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableData* xmlPostResponse;
@property (nonatomic, retain) UIView* overlay;
@property (nonatomic, retain) UIActivityIndicatorView* spinner;
@property (nonatomic, retain) NSMutableArray* xmlParserPath;

-(id) initWithPlaceID:(NSString*)place_id;
//- (void)editPlace:(id)sender;

@end

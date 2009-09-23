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
#import "EditLineVC.h"

@protocol PlaceVCDelegate;

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
	PhotoViewerDelegate,
	EditLineVCDelegate> 
{
	NSString* placeID;
	NSMutableDictionary* placeData;
	NSDictionary* originalPlaceData;
	NSMutableDictionary* userReviewData;
	id<PlaceVCDelegate> delegate;
}

@property (nonatomic,retain) NSString* placeID;
@property (nonatomic, retain) NSMutableDictionary* placeData;
@property (nonatomic,retain) NSDictionary* originalPlaceData;
@property (nonatomic,retain) NSMutableDictionary* userReviewData;
@property (assign) id<PlaceVCDelegate> delegate;

-(id) initWithPlaceID:(NSString*)place_id;
//- (void)editPlace:(id)sender;

@end

@protocol PlaceVCDelegate

-(void)placeVCDidFinishEditing:(PlaceTableViewController*)placeVC;
-(void)placeVCDidCancelEditing:(PlaceTableViewController*)placeVC;

@end

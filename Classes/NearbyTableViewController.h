//
//  NearbyTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "BeerCrushAppDelegate.h"

@interface PlaceObject: NSObject
{
	NSString* name;
	NSString* place_id;
	CLLocation* loc;
	NSString* street;
	NSString* city;
	NSString* state;
	NSString* zip;
	NSString* phone;
}

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* place_id;
@property (nonatomic,retain) CLLocation* loc;
@property (nonatomic,retain) NSString* street;
@property (nonatomic,retain) NSString* city;
@property (nonatomic,retain) NSString* state;
@property (nonatomic,retain) NSString* zip;
@property (nonatomic,retain) NSString* phone;

-(id)init;

@end


@interface NearbyTableViewController : UITableViewController<CLLocationManagerDelegate> {
	UIApplication* app;
	BeerCrushAppDelegate* appdel;
	NSMutableString* currentElemValue;
	CLLocation* myLocation;
	PlaceObject* placeObject;
	NSMutableArray* places;
}

@property (nonatomic, retain) UIApplication* app;
@property (nonatomic, retain) BeerCrushAppDelegate* appdel;
@property (nonatomic, retain) CLLocation* myLocation;
@property (nonatomic, retain) NSMutableString* currentElemValue;
@property (nonatomic, retain) PlaceObject* placeObject;
@property (nonatomic, retain) NSMutableArray* places;

@end

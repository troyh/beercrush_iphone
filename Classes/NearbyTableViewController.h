//
//  NearbyTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLLocation.h>
#import "BeerCrushAppDelegate.h"

@interface PlaceObject: NSObject
{
	NSString* place_id;
	NSMutableDictionary* data;
	NSMutableDictionary* editeddata;
	CLLocationDistance distanceAway;
//	NSString* name;
//	CLLocation* loc;
//	NSString* street;
//	NSString* city;
//	NSString* state;
//	NSString* zip;
//	NSString* phone;
//	NSString* uri;
	
}

@property (nonatomic,retain) NSString* place_id;
@property (nonatomic,retain) NSMutableDictionary* data;
@property (nonatomic,retain) NSMutableDictionary* editeddata;
@property (nonatomic) CLLocationDistance distanceAway;
//@property (nonatomic,retain) NSString* name;
//@property (nonatomic,retain) CLLocation* loc;
//@property (nonatomic,retain) NSString* street;
//@property (nonatomic,retain) NSString* city;
//@property (nonatomic,retain) NSString* state;
//@property (nonatomic,retain) NSString* zip;
//@property (nonatomic,retain) NSString* phone;
//@property (nonatomic,retain) NSString* uri;

-(id)init;
-(NSInteger)compareLocation:(id)other;

@end


@interface NearbyTableViewController : UITableViewController<CLLocationManagerDelegate> {
	NSMutableString* currentElemValue;
	CLLocation* myLocation;
	PlaceObject* placeObject;
	NSMutableArray* places;
}

@property (nonatomic, retain) CLLocation* myLocation;
@property (nonatomic, retain) NSMutableString* currentElemValue;
@property (nonatomic, retain) PlaceObject* placeObject;
@property (nonatomic, retain) NSMutableArray* places;

@end

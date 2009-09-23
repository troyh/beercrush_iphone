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
}

@property (nonatomic,retain) NSString* place_id;
@property (nonatomic,retain) NSMutableDictionary* data;
@property (nonatomic,retain) NSMutableDictionary* editeddata;
@property (nonatomic) CLLocationDistance distanceAway;

-(id)init;
-(NSInteger)compareLocation:(id)other;

@end


@interface NearbyTableViewController : UITableViewController<CLLocationManagerDelegate> {
	CLLocation* myLocation;
	NSMutableArray* places;
	CLLocationManager* locationManager;
}

@property (nonatomic, retain) CLLocation* myLocation;
@property (nonatomic, retain) NSMutableArray* places;
@property (nonatomic, retain) CLLocationManager* locationManager;
@end

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


@interface NearbyTableViewController : UITableViewController<CLLocationManagerDelegate> {
	CLLocation* myLocation;
	NSMutableDictionary* places;
	CLLocationManager* locationManager;
	NSString* beerID;
}

@property (nonatomic, retain) CLLocation* myLocation;
@property (nonatomic, retain) NSMutableDictionary* places;
@property (nonatomic, retain) CLLocationManager* locationManager;
@property (nonatomic,retain) NSString* beerID;

@end

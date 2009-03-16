//
//  NearbyTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface PlaceObject: NSObject
{
	NSString* name;
	NSString* place_id;
	CLLocation* loc;
}

@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* place_id;
@property (nonatomic,retain) CLLocation* loc;

-(id)init;

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

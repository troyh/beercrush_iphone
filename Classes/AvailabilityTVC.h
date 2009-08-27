//
//  AvailabilityTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AvailabilityTVCDelegate;

@interface AvailabilityTVC : UITableViewController {
	NSArray* options;
	NSString* selectedAvailability;
	id<AvailabilityTVCDelegate> delegate;
}

@property (nonatomic,retain) NSArray* options;
@property (nonatomic,retain) NSString* selectedAvailability;
@property (assign) id<AvailabilityTVCDelegate> delegate;

@end

@protocol AvailabilityTVCDelegate

-(void)availabilityTVC:(AvailabilityTVC*)tvc didSelectAvailability:(NSString*)s;

@end

//
//  PlaceTypeTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaceTypeTVCDelegate;


@interface PlaceTypeTVC : UITableViewController {
	NSArray* typeOptions;
	NSString* currentlySelectedType;
	id<PlaceTypeTVCDelegate> delegate;
}

@property (nonatomic,retain) NSArray* typeOptions;
@property (assign) id<PlaceTypeTVCDelegate> delegate;
@property (nonatomic,retain) NSString* currentlySelectedType;

-(id)init;

@end

@protocol PlaceTypeTVCDelegate

-(void)placeType:(PlaceTypeTVC*)placeType didSelectType:(NSString*)typeName;

@end

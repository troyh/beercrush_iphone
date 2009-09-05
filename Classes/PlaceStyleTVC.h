//
//  PlaceStyleTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaceStyleTVCDelegate

-(void)placeStyleTVC:(id)placeStyleTVC didSelectStyle:(NSDictionary*)style;

@end


@interface PlaceStyleTVC : UITableViewController <PlaceStyleTVCDelegate> {
	NSString* currentlySelectedStyle;
	NSDictionary* stylesDict;
	id<PlaceStyleTVCDelegate> delegate;
}

@property (assign) id<PlaceStyleTVCDelegate> delegate;
@property (nonatomic,copy) NSString* currentlySelectedStyle;
@property (nonatomic,retain) NSDictionary* stylesDict;

-(id)init;
-(id)initWithCategoryDictionary:(NSDictionary*)dict;

@end


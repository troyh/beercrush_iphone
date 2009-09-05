//
//  PlacePriceTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlacePriceTVCDelegate;

@interface PlacePriceTVC : UITableViewController {
	NSUInteger currentlySelectedPrice;
	id<PlacePriceTVCDelegate> delegate;
@private
	NSArray* priceOptions;
}

@property (assign) NSUInteger currentlySelectedPrice;
@property (nonatomic,retain) NSArray* priceOptions;
@property (assign) id<PlacePriceTVCDelegate> delegate;

@end

@protocol PlacePriceTVCDelegate

-(void)placePriceTVC:(PlacePriceTVC*)placePriceTVC didSelectPrice:(NSUInteger)price;

@end

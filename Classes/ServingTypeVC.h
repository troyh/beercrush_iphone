//
//  ServingTypeVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 11/10/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServingTypeVCDelegate;

/*
 These are a bitmask, so use bit-numbering, not sequential numbering
 */
typedef enum 
{
	BeerCrushServingTypeUnknown=0,
	BeerCrushServingTypeTap=1,
	BeerCrushServingTypeCask=2,
	BeerCrushServingTypeBottle355=4,
	BeerCrushServingTypeBottle650=8,
	BeerCrushServingTypeCan=16
} BeerCrushServingType;


@interface ServingTypeVC : UITableViewController {
	id<ServingTypeVCDelegate> delegate;
	BeerCrushServingType selectedType;
	NSArray* servingTypeOptions;
	NSObject* dataObject;
}

@property (assign) id<ServingTypeVCDelegate> delegate;
@property (nonatomic,assign) BeerCrushServingType selectedType;
@property (nonatomic,retain) NSArray* servingTypeOptions;
@property (nonatomic,retain) NSObject* dataObject;

@end

@protocol ServingTypeVCDelegate

-(void)servingTypeVC:(ServingTypeVC*)vc didSelectServingType:(BeerCrushServingType)t setOn:(BOOL)b;

@end

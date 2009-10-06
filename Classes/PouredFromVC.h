//
//  PouredFromVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 10/5/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PouredFromVCDelegate;

typedef enum 
{
	PouredFromVCValueTypeBottle=1,
	PouredFromVCValueTypeLargeBottle,
	PouredFromVCValueTypeCan,
	PouredFromVCValueTypeDraft,
	PouredFromVCValueTypeCask
} PouredFromVCValueType;

@interface PouredFromVC : UITableViewController {
	id<PouredFromVCDelegate> delegate;
}

@property (nonatomic, assign) id<PouredFromVCDelegate> delegate;

@end

@protocol PouredFromVCDelegate

-(void)pouredFromVC:(PouredFromVC*)vc didChoosePouredFrom:(PouredFromVCValueType)value;

@end

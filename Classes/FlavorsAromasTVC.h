//
//  FlavorsAromasTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FlavorsAromasTVCDelegate <NSObject>
@optional

-(NSArray*)getCurrentFlavors;
-(void)didSelectFlavor:(NSString*)flavor;
-(void)didUnselectFlavor:(NSString*)flavor;
-(void)doneSelectingFlavors;

@end

@interface FlavorsAromasTVC : UITableViewController {
	NSDictionary* flavorsDictionary;
	
	id<FlavorsAromasTVCDelegate> delegate;
}

@property (nonatomic, retain) NSDictionary* flavorsDictionary;
@property (assign) id<FlavorsAromasTVCDelegate> delegate;

@end


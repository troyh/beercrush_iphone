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

-(void)didSelectFlavor:(NSString*)flavor;
-(void)didUnselectFlavor:(NSString*)flavor;
-(void)doneSelectingFlavors;

@end

@interface FlavorsAromasTVC : UITableViewController {
	NSMutableArray* xmlParserPath;
	NSMutableString* currentElemValue;
	NSMutableString* currentElemID;
	NSMutableArray* flavorTitles;
	NSMutableArray* flavorsList;
	
	id<FlavorsAromasTVCDelegate> delegate;
}

@property (nonatomic, retain) NSMutableArray* xmlParserPath;
@property (nonatomic, retain) NSMutableString* currentElemValue;
@property (nonatomic, retain) NSMutableString* currentElemID;
@property (nonatomic, retain) NSMutableArray* flavorTitles;
@property (nonatomic, retain) NSMutableArray* flavorsList;
@property (assign) id<FlavorsAromasTVCDelegate> delegate;

@end


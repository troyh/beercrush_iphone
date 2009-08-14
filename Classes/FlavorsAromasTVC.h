//
//  FlavorsAromasTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlavorsAromasTVC : UITableViewController {
	NSMutableArray* xmlParserPath;
	NSMutableString* currentElemValue;
	NSMutableArray* flavorTitles;
	NSMutableArray* flavorsList;
}

@property (nonatomic, retain) NSMutableArray* xmlParserPath;
@property (nonatomic, retain) NSMutableString* currentElemValue;
@property (nonatomic, retain) NSMutableArray* flavorTitles;
@property (nonatomic, retain) NSMutableArray* flavorsList;

@end

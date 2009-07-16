//
//  UserReviewsTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 7/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserReviewsTVC : UITableViewController {
	NSMutableArray* reviewsList;
	NSMutableArray* xmlParserPath;
	NSMutableString* currentElemValue;
}

@property (nonatomic,retain) NSMutableArray* reviewsList;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (nonatomic,retain) NSMutableString* currentElemValue;

@end

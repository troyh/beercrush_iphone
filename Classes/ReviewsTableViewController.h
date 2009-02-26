//
//  ReviewsTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTableViewController.h"

@interface ReviewsTableViewController : UITableViewController {
	NSString* dataid;
	ResultType datatype;
}

@property (nonatomic,retain) NSString* dataid;
@property (nonatomic) ResultType datatype;

-(id)initWithID:(NSString*)dataid dataType:(ResultType)t;

@end

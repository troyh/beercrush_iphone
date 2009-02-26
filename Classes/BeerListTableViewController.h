//
//  BeerListTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BeerListTableViewController : UITableViewController {
	NSString* breweryID;
	NSArray* beerStyleNames;
}

@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) NSArray* beerStyleNames;

-(id)initWithBreweryID:(NSString*)brewery_id;

@end

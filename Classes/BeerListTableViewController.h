//
//  BeerListTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeerTableViewController.h"
#import "ServingTypeVC.h"

@protocol BeerListTVCDelegate

-(BOOL)beerListTVCDidSelectBeer:(NSString*)beer_id;

@end


@interface BeerListTableViewController : UITableViewController <BeerTableViewControllerDelegate,SearchVCDelegate,BeerListTVCDelegate,ServingTypeVCDelegate> {
	id<BeerListTVCDelegate> delegate;
	@private
	NSString* breweryID;
	NSString* placeID;
	NSString* wishlistID;
	
	NSMutableDictionary* beerList;
	NSMutableArray* beerListAdditions;
	NSMutableArray* beerListDeletions;
	BeerTableViewController* btvc;
	BOOL setRightBarButtonItem;
}

@property (nonatomic,assign) id<BeerListTVCDelegate> delegate;
@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) NSString* placeID;
@property (nonatomic,retain) NSString* wishlistID;
@property (nonatomic,retain) NSDictionary* beerList;
@property (nonatomic,retain) NSMutableArray* beerListAdditions;
@property (nonatomic,retain) NSMutableArray* beerListDeletions;
@property (nonatomic,retain) BeerTableViewController* btvc;
@property (nonatomic,assign) BOOL setRightBarButtonItem;

-(id)initWithBreweryID:(NSString*)brewery_id;
-(void)newBeerPanel;
-(void)addBeerToMenu:(NSString*)beerID;
-(void)didSaveBeerEdits;
-(void)didCancelBeerEdits;

@end


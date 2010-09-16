//
//  BeerTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RatingControl.h"
#import "BeerCrushAppDelegate.h"
#import "StylesListTVC.h"
#import "ColorsTVC.h"
#import "AvailabilityTVC.h"
#import "EditTextVC.h"
#import "PhotoThumbnailControl.h"
#import "PhotoViewer.h"
#import "EditLineVC.h"
#import "FullBeerReviewTVC.h"

@protocol BeerTableViewControllerDelegate;

@interface BeerTableViewController : UITableViewController 
	<FullBeerReviewTVCDelegate,
	StylesListTVCDelegate,
	ColorsTVCDelegate,
	AvailabilityTVCDelegate,
	UITextViewDelegate,
	UITextFieldDelegate, 
	EditTextVCDelegate,
	PhotoViewerDelegate,
	EditLineVCDelegate> 
{
	NSString* beerID;
	NSString* breweryID;
	BeerObject* beerObj;
	UIImage* thumbnailPhoto;
	NSDictionary* originalBeerData;
	NSMutableDictionary* userReviewData;
	NSNumber* predictedRating;
	
	// UI controls
	RatingControl* userRatingControl;
	RatingControl* overallRatingControl;
	UISlider* bodySlider;
	UISlider* balanceSlider;
	UISlider* aftertasteSlider;
	UITextField* beerNameTextField;
	UITextField* abvTextField;
	UITextField* ibuTextField;
	UITextField* ogTextField;
	UITextField* fgTextField;
	UITextField* grainsTextField;
	UITextField* hopsTextField;
	
	NSMutableArray* buttons;
	UIView* dataTableView;
	
	id<BeerTableViewControllerDelegate> delegate;
}

@property (nonatomic,retain) NSString* beerID;
@property (nonatomic,retain) NSString* breweryID;
@property (nonatomic,retain) BeerObject* beerObj;
@property (nonatomic,retain) UIImage* thumbnailPhoto;
@property (nonatomic,retain) NSDictionary* originalBeerData;
@property (nonatomic,retain) NSMutableDictionary* userReviewData;
@property (nonatomic,retain) NSNumber* predictedRating;
@property (nonatomic,retain) RatingControl* userRatingControl;
@property (nonatomic,retain) RatingControl* overallRatingControl;
@property (nonatomic,retain) UISlider* bodySlider;
@property (nonatomic,retain) UISlider* balanceSlider;
@property (nonatomic,retain) UISlider* aftertasteSlider;
@property (nonatomic,retain) UITextField* beerNameTextField;
@property (nonatomic,retain) UITextField* abvTextField;
@property (nonatomic,retain) UITextField* ibuTextField;
@property (nonatomic,retain) UITextField* ogTextField;
@property (nonatomic,retain) UITextField* fgTextField;
@property (nonatomic,retain) UITextField* grainsTextField;
@property (nonatomic,retain) UITextField* hopsTextField;
@property (nonatomic,assign) NSMutableArray* buttons;
@property (nonatomic,retain) UIView* dataTableView;
@property (assign) id<BeerTableViewControllerDelegate> delegate;

-(id) initWithBeerID:(NSString*)beer_id;
-(NSObject*)navigationRestorationData;

@end

@protocol BeerTableViewControllerDelegate

-(void)didSaveBeerEdits;
-(void)didCancelBeerEdits;

@end

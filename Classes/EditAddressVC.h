//
//  EditAddressVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryListTVC.h"

@protocol EditAddressVCDelegate;

@interface EditAddressVC : UITableViewController <CountryListTVCDelegate> {
	NSMutableDictionary* addressToEdit;
	UITextField* street1;
	UITextField* street2;
	UITextField* city;
	UITextField* state;
	UITextField* zip;
	id<EditAddressVCDelegate> delegate;
}

@property (nonatomic,retain) NSMutableDictionary* addressToEdit;
@property (assign) id<EditAddressVCDelegate> delegate;
@property (nonatomic,retain) UITextField* street1;
@property (nonatomic,retain) UITextField* street2;
@property (nonatomic,retain) UITextField* city;
@property (nonatomic,retain) UITextField* state;
@property (nonatomic,retain) UITextField* zip;

@end

@protocol EditAddressVCDelegate

-(void)editAddressVC:(EditAddressVC*)editAddressVC didEditAddress:(NSDictionary*)dict;

@end

//
//  PhoneNumberEditTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _BeerCrushEditableValueType {
	kBeerCrushEditableValueTypeText,
	kBeerCrushEditableValueTypeURI,
	kBeerCrushEditableValueTypePhoneNumber,
	kBeerCrushEditableValueTypeAddress,
	kBeerCrushEditableValueTypeMultiText,
	kBeerCrushEditableValueTypeNumber,
	kBeerCrushEditableValueTypeChoice
} BeerCrushEditableValueType;

@interface PhoneNumberEditTableViewController : UITableViewController {
	NSMutableDictionary* data;
	NSString* editableValueName;
	BeerCrushEditableValueType editableValueType;
	NSArray* editableChoices;
	
	NSMutableArray* editingControls;
}

@property (nonatomic,retain) NSMutableArray* editingControls;
@property (nonatomic,retain) NSMutableDictionary* data;
@property (nonatomic,retain) NSString* editableValueName;
@property (nonatomic) BeerCrushEditableValueType editableValueType;
@property (nonatomic,retain) NSArray* editableChoices;

- (void)saveChanges:(id)sender;
- (void)cancelChanges:(id)sender;

@end

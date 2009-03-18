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
} BeerCrushEditableValueType;

@interface PhoneNumberEditTableViewController : UITableViewController {
	NSMutableDictionary* data;
	NSString* editableValueName;
	BeerCrushEditableValueType editableValueType;
	
	UIControl* editingControl;
}

@property (nonatomic,retain) UIControl* editingControl;
@property (nonatomic,retain) NSMutableDictionary* data;
@property (nonatomic,retain) NSString* editableValueName;
@property (nonatomic) BeerCrushEditableValueType editableValueType;

- (void)saveChanges:(id)sender;
- (void)cancelChanges:(id)sender;

@end

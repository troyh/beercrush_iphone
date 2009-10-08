//
//  EditLineVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/11/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditLineVCDelegate;

typedef enum {
	EditLineVCTextTypeDefault=1,
	EditLineVCTextTypeCurrency,
	EditLineVCTextTypeInteger
} EditLineVCTextType;


@interface EditLineVC : UITableViewController <UITextFieldDelegate> {
	NSUInteger tag;
	EditLineVCTextType textType;
	NSString* textToEdit;
	UITextField* textField;
	id<EditLineVCDelegate> delegate;
}

@property (assign) NSUInteger tag;
@property (nonatomic,assign) EditLineVCTextType textType;
@property (nonatomic,retain) NSString* textToEdit;
@property (nonatomic,retain) UITextField* textField;
@property (assign) id<EditLineVCDelegate> delegate;

@end

@protocol EditLineVCDelegate

-(void)editLineVC:(EditLineVC*)editLineVC didChangeText:(NSString*)text;

@end

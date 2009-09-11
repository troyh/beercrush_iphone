//
//  EditLineVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/11/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditLineVCDelegate;


@interface EditLineVC : UITableViewController {
	NSUInteger tag;
	NSString* textToEdit;
	UITextField* textField;
	id<EditLineVCDelegate> delegate;
}

@property (assign) NSUInteger tag;
@property (nonatomic,retain) NSString* textToEdit;
@property (nonatomic,retain) UITextField* textField;
@property (assign) id<EditLineVCDelegate> delegate;

@end

@protocol EditLineVCDelegate

-(void)editLineVC:(EditLineVC*)editLineVC didChangeText:(NSString*)text;

@end

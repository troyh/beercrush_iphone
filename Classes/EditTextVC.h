//
//  EditTextVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditTextVCDelegate;


@interface EditTextVC : UIViewController <UITextViewDelegate> {
	NSString* textToEdit;
	UITextView* textView;
	id<EditTextVCDelegate> delegate;
}

@property (nonatomic,retain) NSString* textToEdit;
@property (assign) id<EditTextVCDelegate> delegate;
@property (nonatomic,retain) UITextView* textView;

@end

@protocol EditTextVCDelegate

-(void)editTextVC:(id)sender didChangeText:(NSString*)text;

@end

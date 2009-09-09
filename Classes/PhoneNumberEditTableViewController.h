//
//  PhoneNumberEditTableViewController.h
//  BeerCrush
//
//  Created by Troy Hakala on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhoneNumberEditVCDelegate;

@interface PhoneNumberEditTableViewController : UITableViewController {
	NSString* phoneNumberToEdit;
	UITextField* textField;
	id<PhoneNumberEditVCDelegate> delegate;
}

@property (nonatomic,retain) NSString* phoneNumberToEdit;
@property (nonatomic,retain) UITextField* textField;
@property (assign) id<PhoneNumberEditVCDelegate> delegate;

- (id)init;
- (void)saveChanges:(id)sender;
- (void)cancelChanges:(id)sender;

@end

@protocol PhoneNumberEditVCDelegate

-(void)editPhoneNumber:(PhoneNumberEditTableViewController*)editPhoneNumber didChangePhoneNumber:(NSString*)phoneNumber;
-(void)editPhoneNumberdidCancelEdit:(PhoneNumberEditTableViewController*)editPhoneNumber;

@end

//
//  LoginVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginVCDelegate

-(void)loginVCSuccessful;
-(void)loginVCNewAccount:(NSString*)userid andPassword:(NSString*)password;
-(void)loginVCFailed;
-(void)loginVCCancelled;

@end


@interface LoginVC : UIViewController {
	id<LoginVCDelegate> delegate;
	UITextField* emailTextField;
	UITextField* passwordTextField;
}

@property (nonatomic, assign) id<LoginVCDelegate> delegate;
@property (nonatomic, retain) UITextField* emailTextField;
@property (nonatomic, retain) UITextField* passwordTextField;

@end

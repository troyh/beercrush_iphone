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
	UITextField* usernameTextField;
	UITextField* passwordTextField;
}

@property (nonatomic, assign) id<LoginVCDelegate> delegate;
@property (nonatomic, retain) UITextField* usernameTextField;
@property (nonatomic, retain) UITextField* passwordTextField;

@end

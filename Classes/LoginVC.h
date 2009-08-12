//
//  LoginVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginVC : UIViewController {
	BOOL bCreateAccount;
	UITextField* usernameTextField;
	UITextField* passwordTextField;
}

@property (nonatomic, assign) BOOL bCreateAccount;
@property (nonatomic, retain) UITextField* usernameTextField;
@property (nonatomic, retain) UITextField* passwordTextField;

@end

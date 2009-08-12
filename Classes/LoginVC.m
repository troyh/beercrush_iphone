//
//  LoginVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoginVC.h"
#import "BeerCrushAppDelegate.h"

@implementation LoginVC

@synthesize usernameTextField;
@synthesize passwordTextField;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	if (!self.isViewLoaded)
	{
		// Give the user username and password text fields
		CGRect screenRect=[[[UIApplication sharedApplication] keyWindow] frame];
		UIView* mainview=[[UIView alloc] initWithFrame:screenRect];
		self.view=mainview;

		// Username field
		const int kTextFieldWidth=200;
		const int kTextFieldHeight=30;
		const int kButtonWidth=100;
		const int kButtonHeight=30;
		usernameTextField=[[[UITextField alloc] initWithFrame:CGRectMake((screenRect.size.width-kTextFieldWidth)/2, 50, kTextFieldWidth, kTextFieldHeight)] autorelease];
		usernameTextField.borderStyle=UITextBorderStyleBezel;
		usernameTextField.adjustsFontSizeToFitWidth=YES;
		usernameTextField.textAlignment=UITextAlignmentCenter;
		usernameTextField.placeholder=@"Username";
		usernameTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
		usernameTextField.autocorrectionType=UITextAutocorrectionTypeNo;
		usernameTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		usernameTextField.enablesReturnKeyAutomatically=YES;
		usernameTextField.keyboardAppearance=UIKeyboardAppearanceDefault;
		usernameTextField.keyboardType=UIKeyboardTypeAlphabet;
		usernameTextField.returnKeyType=UIReturnKeyNext;
		usernameTextField.secureTextEntry=NO;
		[usernameTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]];

		// Password field
		passwordTextField=[[[UITextField alloc] initWithFrame:CGRectMake((screenRect.size.width-kTextFieldWidth)/2, 85, kTextFieldWidth, kTextFieldHeight)] autorelease];
		passwordTextField.borderStyle=UITextBorderStyleBezel;
		passwordTextField.textAlignment=UITextAlignmentCenter;
		passwordTextField.placeholder=@"Password";
		passwordTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
		passwordTextField.autocorrectionType=UITextAutocorrectionTypeNo;
		passwordTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		passwordTextField.enablesReturnKeyAutomatically=YES;
		passwordTextField.keyboardAppearance=UIKeyboardAppearanceDefault;
		passwordTextField.keyboardType=UIKeyboardTypeAlphabet;
		passwordTextField.returnKeyType=UIReturnKeyGo;
		passwordTextField.secureTextEntry=YES;
		[passwordTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
		
		// Login button
		UIButton* login_button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		login_button.frame=CGRectMake((screenRect.size.width-kButtonWidth)/2, 120, kButtonWidth, kButtonHeight);
		[login_button setTitle:@"Login" forState:UIControlStateNormal];
		[login_button addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];

		[self.view addSubview:usernameTextField];
		[self.view addSubview:passwordTextField];
		[self.view addSubview:login_button];
		
	}
}

-(void)loginButtonClicked
{
	// Save values into defaults (the login function will use these values)
	[[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text  forKey:@"user_id"];
	[[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text  forKey:@"password"];

	// Attempt login
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([delegate login]==NO)
	{
	}
	else
	{
		[self.view removeFromSuperview];
		BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[delegate startApp];
	}
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

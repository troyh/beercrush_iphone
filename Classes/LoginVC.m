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

@synthesize bCreateAccount;
@synthesize usernameTextField;
@synthesize passwordTextField;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		bCreateAccount=NO; // Default to no
    }
    return self;
}

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
		const int kButtonWidth=150;
		const int kButtonHeight=30;
		const int kSwitchButtonWidth=200;
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
		
		UIButton* button=nil;
		button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.frame=CGRectMake((screenRect.size.width-kButtonWidth)/2, 120, kButtonWidth, kButtonHeight);

		if (self.bCreateAccount==NO)
		{
			// Login button
			[usernameTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"]];
			[passwordTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
			[button setTitle:@"Login" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		}
		else
		{
			// Create Account button
			[button setTitle:@"Create Account" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(createAccountButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		}

		UIButton* switch_button=nil;
		switch_button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		switch_button.frame=CGRectMake((screenRect.size.width-kSwitchButtonWidth)/2, 155, kSwitchButtonWidth, kButtonHeight);
		if (bCreateAccount)
			[switch_button setTitle:@"I already have an account" forState:UIControlStateNormal];
		else
			[switch_button setTitle:@"I don't have an account" forState:UIControlStateNormal];
		[switch_button addTarget:self action:@selector(switchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:usernameTextField];
		[self.view addSubview:passwordTextField];
		[self.view addSubview:button];
		[self.view addSubview:switch_button];
	}
}

-(void)createAccountButtonClicked
{
	BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_CREATE_ACCOUNT];
	NSString* bodystr=[NSString stringWithFormat:@"userid=%@&password=%@",
					   usernameTextField.text,
					   passwordTextField.text];
	NSData* answer;
	NSHTTPURLResponse* response=[delegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:&answer];
	if ([response statusCode]==200)
	{	// Account successfully created
		[self.view removeFromSuperview];
		// TODO: make it call a specified selector action rather than always calling startApp
		BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[delegate startApp];
	}
	else
	{	// Failed to create account
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
		// TODO: make it call a specified selector action rather than always calling startApp
		BeerCrushAppDelegate* delegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[delegate startApp];
	}
}

-(void)switchButtonClicked
{
	// Toggle between create account and login
	bCreateAccount=bCreateAccount?NO:YES;
	
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

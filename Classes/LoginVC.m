//
//  LoginVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoginVC.h"
#import "BeerCrushAppDelegate.h"
#import "RegexKitLite.h"

@implementation LoginVC

@synthesize delegate;
@synthesize emailTextField;
@synthesize passwordTextField;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	if ([self isViewLoaded]==NO)
	{
		self.title=NSLocalizedString(@"Sign In",@"Login Screen Title");
		self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelLoginButtonClicked:)] autorelease];

		// Give the user username and password text fields
		CGRect screenRect=[[[UIApplication sharedApplication] keyWindow] frame];
		UIView* mainview=[[[UIView alloc] initWithFrame:screenRect] autorelease];
		mainview.backgroundColor=[UIColor whiteColor];
		self.view=mainview;

		// Username field
		const int kTextFieldWidth=200;
		const int kTextFieldHeight=30;
		const int kButtonWidth=125;
		const int kButtonHeight=40;

		emailTextField=[[[UITextField alloc] initWithFrame:CGRectMake((screenRect.size.width-kTextFieldWidth)/2, 50, kTextFieldWidth, kTextFieldHeight)] autorelease];
		emailTextField.borderStyle=UITextBorderStyleBezel;
		emailTextField.adjustsFontSizeToFitWidth=YES;
		emailTextField.textAlignment=UITextAlignmentCenter;
		emailTextField.placeholder=@"Email address";
		emailTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
		emailTextField.autocorrectionType=UITextAutocorrectionTypeNo;
		emailTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		emailTextField.enablesReturnKeyAutomatically=YES;
		emailTextField.keyboardAppearance=UIKeyboardAppearanceDefault;
		emailTextField.keyboardType=UIKeyboardTypeAlphabet;
		emailTextField.returnKeyType=UIReturnKeyNext;
		emailTextField.secureTextEntry=NO;

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
		
		UIButton* signInButton=nil;
		signInButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		signInButton.frame=CGRectMake(screenRect.size.width/2+((screenRect.size.width/2-kButtonWidth)/2), 120, kButtonWidth, kButtonHeight);

		// Sign In button
		[emailTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"email"]];
		[passwordTextField setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
		[signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
		[signInButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];

		// Create Account button
		UIButton* createAccountButton=nil;
		createAccountButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		createAccountButton.frame=CGRectMake((screenRect.size.width/2-kButtonWidth)/2, 120, kButtonWidth, kButtonHeight);
		[createAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
		[createAccountButton addTarget:self action:@selector(createAccountButtonClicked) forControlEvents:UIControlEventTouchUpInside];

		[self.view addSubview:emailTextField];
		[self.view addSubview:passwordTextField];
		[self.view addSubview:signInButton];
		[self.view addSubview:createAccountButton];
	}
}

-(void)cancelLoginButtonClicked:(id)sender
{
	[self.delegate loginVCCancelled];
}

-(void)createAccountButtonClicked
{
	UIAlertView* alert=nil;

	// Trim whitespace off username/email and password
	emailTextField.text=[emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	passwordTextField.text=[passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// Verify that email address looks like an email address. Regex from http://www.regular-expressions.info/email.html
	if ([emailTextField.text isMatchedByRegex:@"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"]==NO)
	{
		alert=[[UIAlertView alloc] initWithTitle:nil
										 message:NSLocalizedString(@"That email address does not look like an email address",@"CreateAccount: email address invalid") 
										delegate:nil 
							   cancelButtonTitle:NSLocalizedString(@"Try Again",@"CreateAccount: email address invalid OK button text") 
							   otherButtonTitles:nil];
	}
	else if ([passwordTextField.text length]==0) // Verify that the password is not blank
	{
		alert=[[UIAlertView alloc] initWithTitle:nil
										 message:NSLocalizedString(@"Your password cannot be blank",@"CreateAccount: password is blank") 
										delegate:nil 
							   cancelButtonTitle:NSLocalizedString(@"Try Again",@"CreateAccount: email address invalid OK button text") 
							   otherButtonTitles:nil];
	}
	else
	{
		
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		NSURL* url=[NSURL URLWithString:BEERCRUSH_API_URL_CREATE_ACCOUNT];
		NSString* bodystr=[NSString stringWithFormat:@"email=%@&password=%@",
						   emailTextField.text,
						   passwordTextField.text];
		NSData* answer;
		NSHTTPURLResponse* response=[appDelegate sendRequest:url usingMethod:@"POST" withData:bodystr returningData:&answer];

		DLog(@"Create account status code=%d",[response statusCode]);

		if ([response statusCode]==200)
		{	// Account successfully created
			[self.delegate loginVCNewAccount:emailTextField.text andPassword:passwordTextField.text];

		}
		else if ([response statusCode]==409) // email is already taken
		{
			alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create Account failed",@"CreateAccount: failed alert title") 
											 message:NSLocalizedString(@"That email address is already taken",@"CreateAccount: email address already exists") 
											delegate:nil 
								   cancelButtonTitle:NSLocalizedString(@"OK",@"OK Alert Button") 
								   otherButtonTitles:nil];
		}
		else // Other unidentified error
		{
			alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create Account failed",@"CreateAccount: failed alert title") 
											 message:NSLocalizedString(@"Account could not be created",@"CreateAccount: unknown error") 
											delegate:nil 
								   cancelButtonTitle:NSLocalizedString(@"OK",@"OK Alert Button") 
								   otherButtonTitles:nil];
		}
	}
	
	if (alert)
	{
		[alert show];
		[alert release];
	}
}

-(void)loginButtonClicked
{
	// Save values into defaults (the login function will use these values)
	[[NSUserDefaults standardUserDefaults] setObject:self.emailTextField.text  forKey:@"email"];
	[[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text  forKey:@"password"];

	// Attempt login
	BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([appDelegate automaticLogin]==NO)
	{
		// TODO: put up AlertView telling them it failed
		[self.delegate loginVCFailed];
	}
	else
	{
		[self.delegate loginVCSuccessful];
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

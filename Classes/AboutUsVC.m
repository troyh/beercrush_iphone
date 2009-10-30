//
//  AboutUsVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/30/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import "AboutUsVC.h"

@implementation AboutUsVC

#define MAIL_RECIPIENT_EMAIL @"feedback@beercrush.com"
#define MAIL_SUBJECT_TEXT	 @"My feedback"
#define MAIL_BODY_TEXT		 @""

-(id)init
{
    if (self = [super initWithNibName:@"AboutUsVC" bundle:nil]) {
        // Custom initialization
    }
    return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

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

-(IBAction)doneButtonClicked:(id)sender
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)sendFeedbackButtonClicked:(id)sender
{
	// TODO: Launch mail to send mail to feedback@beercrush.com
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
	
}

#pragma mark MFMailComposeViewControllerDelegate methods

/* 
 Code taken from http://jackpaternoster.com/2009/07/iphone-sdk-tip-sending-emails-from-an-app-part-2/
 */
-(void)displayComposerSheet
{
	//alloc and init the MFMailComposeViewController
	MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
	//set the delegate to the current View controller
	email.mailComposeDelegate = self;

	//Set the subject of the email
	[email setSubject:MAIL_SUBJECT_TEXT];

	//set the to: address
	NSArray *toRecipients = [NSArray arrayWithObject:MAIL_RECIPIENT_EMAIL];
	[email setToRecipients:toRecipients];

	// body text
//	NSString *emailBody = MAIL_BODY_TEXT;
//	[email setMessageBody:emailBody isHTML:NO];

	[self presentModalViewController:email animated:YES];
	[email release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void)launchMailAppOnDevice
{
	//email address string
	NSString *emailAddress = MAIL_RECIPIENT_EMAIL;
	//subject string
	NSString *subject = MAIL_SUBJECT_TEXT;
	//body string
	NSString *body = MAIL_BODY_TEXT;
	//have to percent escape the subject string to be compatible with the mailto: uri scheme
	NSString *processedSubject = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)subject, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
	//have to percent escape the body string to be compatible with the mailto: uri scheme
	NSString *processedBody = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)body, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
	//create the mailto: URL string
	NSString *mailToString = [NSString stringWithFormat:@"mailto:%@?subject=$@&body=%@", emailAddress, processedSubject, processedBody];
	//Convert NSString to NSURL
	NSURL *url = [NSURL URLWithString:mailToString];
	//Open the Mail App with the NSURL
	[[UIApplication sharedApplication] openURL:url];
}


@end

//
//  EditTextVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditTextVC.h"


@implementation EditTextVC

@synthesize textToEdit;
@synthesize delegate;
@synthesize textView;

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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title=@"Editing";

	self.view.backgroundColor=[UIColor groupTableViewBackgroundColor];

	// Create text field inside a roundedrect
	self.textView=[[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.textView.backgroundColor=[UIColor whiteColor];
	self.textView.editable=YES;
	self.textView.delegate=self;
	self.textView.font=[UIFont systemFontOfSize:14];
	[self.view addSubview:self.textView];
	[self.textView setText:self.textToEdit];
	[self.textView sizeToFit];
	
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTextButtonClicked:)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	return YES;
}

-(void)keyboardWillShow:(NSNotification*)notification
{
	// Resize the tableview so that it isn't obscured by the keyboard
	CGRect bounds=[[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
	CGPoint center=[[[notification userInfo] objectForKey:UIKeyboardCenterEndUserInfoKey] CGPointValue];
	
	CGRect keyboardFrame=CGRectMake(round(center.x - bounds.size.width/2.0), round(center.y - bounds.size.height/2.0), bounds.size.width, bounds.size.height);
	CGRect tableViewFrame=[self.textView.window convertRect:self.textView.frame fromView:self.textView.superview];
	
	CGRect intersectionFrame=CGRectIntersection(tableViewFrame, keyboardFrame);
	
	UIEdgeInsets insets=UIEdgeInsetsMake(0, 0, intersectionFrame.size.height, 0);
	
	self.textView.frame=CGRectMake(0, 0, 320, intersectionFrame.size.height);
	[self.textView setContentInset:insets];
	[self.textView setScrollIndicatorInsets:insets];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
	// Resize the tableview back to normal
	[self.textView setContentInset:UIEdgeInsetsZero];
	[self.textView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

-(void)saveTextButtonClicked:(id)sender
{
	[self.delegate editTextVC:self didChangeText:self.textView.text];
}





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

	[self.textView release];
	[self.textToEdit release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}


@end

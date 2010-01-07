//
//  BigTextVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 1/7/10.
//  Copyright 2010 Optional Corporation. All rights reserved.
//

#import "BigTextVC.h"


@implementation BigTextVC

@synthesize textToDisplay;

-(id)init 
{
	return [self initWithNibName:nil bundle:nil];
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	if ([self isViewLoaded]==NO)
	{
		UITextView* view=[[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
		view.text=self.textToDisplay;
		[view setFont:[UIFont systemFontOfSize:14.0]];
		self.view=view;
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
	[self.textToDisplay release];
    [super dealloc];
}


@end

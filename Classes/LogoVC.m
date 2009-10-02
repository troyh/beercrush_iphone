//
//  LogoVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 10/1/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import "LogoVC.h"
#import "AboutUsVC.h"

@implementation LogoVC

@synthesize myNC;

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

-(IBAction)infoButtonClicked:(id)sender
{
	AboutUsVC* vc=[[[AboutUsVC alloc] init] autorelease];
	vc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
	[self.myNC presentModalViewController:vc animated:YES];
}


@end

//
//  UserProfileTVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 8/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UserProfileTVC.h"
#import "BeerCrushAppDelegate.h"


@implementation UserProfileTVC

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.title=NSLocalizedString(@"My Profile",@"Title for My Profile screen");
    }
    return self;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		default:
			break;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch (indexPath.section) 
	{
		case 0:
		{
			switch (indexPath.row) 
			{
				case 0:
					break;
				default:
					break;
			}
			break;
		}
		case 1:
		{
			switch (indexPath.row) 
			{
				case 0: // Email field
				{
					[cell.textLabel setText:NSLocalizedString(@"email",@"Email label for Profile screen")];
					NSString* s=[[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
					if (s)
						[cell.detailTextLabel setText:s];
					break;
				}
				case 1: // Password field
				{
					[cell.textLabel setText:NSLocalizedString(@"password",@"Password label for Profile screen")];
					NSString* s=[[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
					if (s)
						[cell.detailTextLabel setText:s];
					break;
				}
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	switch (indexPath.section) {
		case 0:
			break;
		case 1:
		{
			switch (indexPath.row) {
				case 0: // Email
				case 1: // Password
				{
					// Put up login screen so they can edit these
					BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
					[appDelegate askUserForCredentialsWithDelegate:self];
					break;
				}
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)dealloc {
    [super dealloc];
}

#pragma mark LoginVCDelegate methods

-(void)loginVCSuccessful
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[self.tableView reloadData];
}

-(void)loginVCNewAccount:(NSString*)email andPassword:(NSString*)password
{
	[self.tabBarController.selectedViewController dismissModalViewControllerAnimated:YES];
	
	// Update email and password field
	[[NSUserDefaults standardUserDefaults] setValue:email forKey:@"email"];
	[[NSUserDefaults standardUserDefaults] setValue:password forKey:@"password"];
	[self.tableView reloadData];
}

-(void)loginVCFailed
{
}

-(void)loginVCCancelled
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	return;
//	UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cancelled",@"Login cancelled alert title") 
//												   message:NSLocalizedString(@"I can't show you your Profile if you aren't logged in or have no account",@"Login cancelled alert message") 
//												  delegate:nil 
//										 cancelButtonTitle:NSLocalizedString(@"OK",@"Login cancelled cancel button title") 
//										 otherButtonTitles:nil] autorelease];
//	[alert show];
//
//	// Switch the user to another tab, but not this one
//	for (NSUInteger i=0; i < [self.navigationController.tabBarController.viewControllers count]; ++i) {
//		if (i != self.navigationController.tabBarController.selectedIndex)
//		{
//			self.navigationController.tabBarController.selectedIndex=i;
//			return; // Get out of here!
//		}
//	}
//	
//	// Crap, we have only one tab?!?
}


@end


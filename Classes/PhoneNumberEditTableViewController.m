//
//  PhoneNumberEditTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PhoneNumberEditTableViewController.h"


@implementation PhoneNumberEditTableViewController

@synthesize editingControl;
@synthesize data;
@synthesize editableValueName;
@synthesize editableValueType;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChanges:)]];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges:)]];

}

- (void)saveChanges:(id)sender
{
	[self.editingControl resignFirstResponder];
	
	// Report the new value back to the editable item
	switch (editableValueType)
	{
		case kBeerCrushEditableValueTypeURI:
		case kBeerCrushEditableValueTypePhoneNumber:
		case kBeerCrushEditableValueTypeText:
		{
			UITextField* fld=(UITextField*)editingControl;
			[self.data setObject:fld.text forKey:self.editableValueName];
			break;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelChanges:(id)sender
{
	[self.editingControl resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	// Show keyboard
	[self.editingControl becomeFirstResponder];
}

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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch (editableValueType)
	{
		case kBeerCrushEditableValueTypeURI:
		case kBeerCrushEditableValueTypePhoneNumber:
		case kBeerCrushEditableValueTypeText:
		{
			CGRect f=cell.frame;
			f.size.width-=20;
			f.origin.x+=10;
			UITextField* fld=[[UITextField alloc] initWithFrame:f];

			if ([[self.data objectForKey:self.editableValueName] isKindOfClass:[NSString class]])
				fld.text=[self.data objectForKey:self.editableValueName];
			else
				fld.text=@"";
			fld.font=[UIFont systemFontOfSize: 20.0];
			fld.textAlignment=UITextAlignmentCenter;
			fld.clearButtonMode=UITextFieldViewModeWhileEditing;
			fld.adjustsFontSizeToFitWidth=YES;
			
			if (editableValueType==kBeerCrushEditableValueTypeURI)
				fld.keyboardType=UIKeyboardTypeURL;
			else if (editableValueType==kBeerCrushEditableValueTypePhoneNumber)
				fld.keyboardType=UIKeyboardTypePhonePad;
			else if (editableValueType==kBeerCrushEditableValueTypeText)
				fld.keyboardType=UIKeyboardTypeDefault;
			
			fld.clearButtonMode=UITextFieldViewModeWhileEditing;
			fld.adjustsFontSizeToFitWidth=YES;

			self.editingControl=fld;
			break;
		}
	}
	
	[cell addSubview:editingControl];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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


@end


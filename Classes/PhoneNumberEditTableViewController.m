//
//  PhoneNumberEditTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PhoneNumberEditTableViewController.h"


@implementation PhoneNumberEditTableViewController

@synthesize editingControls;
@synthesize data;
@synthesize editableValueName;
@synthesize editableValueType;
@synthesize editableChoices;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
	
	self.editingControls=[[NSMutableArray alloc] initWithCapacity:5];
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChanges:)]];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges:)]];

}

- (void)saveChanges:(id)sender
{
	for (NSUInteger i=0; i<[self.editingControls count]; ++i) {
		[[self.editingControls objectAtIndex:i] resignFirstResponder];
	}
	
	// Report the new value back to the editable item
	switch (editableValueType)
	{
		case kBeerCrushEditableValueTypeURI:
		case kBeerCrushEditableValueTypePhoneNumber:
		case kBeerCrushEditableValueTypeText:
		{
			UITextField* fld=(UITextField*)[self.editingControls objectAtIndex:0]; // Should just be 1
			[self.data setObject:fld.text forKey:self.editableValueName];
			break;
		}
		case kBeerCrushEditableValueTypeAddress:
		{
			// Get the value from each cell's editing control
			NSMutableDictionary* addr=[self.data objectForKey:self.editableValueName];
			for (NSUInteger i=0; i<[self.editingControls count]; ++i) {
				UIControl* ctl=[self.editingControls objectAtIndex:i];
				if ([ctl isKindOfClass:[UITextField class]])
				{
					UITextField* txtfld=(UITextField*)ctl;
					[addr setObject:txtfld.text forKey:@"street"];
				}
			}
			break;
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelChanges:(id)sender
{
	for (NSUInteger i=0; i<[self.editingControls count]; ++i) {
		[[self.editingControls objectAtIndex:i] resignFirstResponder];
	}

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
	UIControl* ctl=[self.editingControls objectAtIndex:0];
	[ctl becomeFirstResponder];
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
	if (editableValueType==kBeerCrushEditableValueTypeAddress)
		return 4;
	else
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
//			f.size.height-=5;
			f.origin.x+=10;
//			f.origin.y+=5;
			UITextField* fld=[[UITextField alloc] initWithFrame:f];

			if ([[self.data objectForKey:self.editableValueName] isKindOfClass:[NSString class]])
				fld.text=[self.data objectForKey:self.editableValueName];
			else
				fld.text=@"";
			fld.font=[UIFont systemFontOfSize: 40.0];
			fld.textAlignment=UITextAlignmentCenter;
			fld.clearButtonMode=UITextFieldViewModeWhileEditing;
			fld.adjustsFontSizeToFitWidth=YES;
			
			if (editableValueType==kBeerCrushEditableValueTypeURI)
				fld.keyboardType=UIKeyboardTypeURL;
			else if (editableValueType==kBeerCrushEditableValueTypePhoneNumber)
				fld.keyboardType=UIKeyboardTypePhonePad;
			else if (editableValueType==kBeerCrushEditableValueTypeText)
				fld.keyboardType=UIKeyboardTypeDefault;
			
			[cell addSubview:fld];
			[self.editingControls addObject:fld];
			break;
		}
		case kBeerCrushEditableValueTypeMultiText:
		{
			CGRect f=cell.frame;
			f.size.width-=20;
			f.origin.x+=10;
			UITextView* fld=[[UITextView alloc] initWithFrame:f];
			
			if ([[self.data objectForKey:self.editableValueName] isKindOfClass:[NSString class]])
				fld.text=[self.data objectForKey:self.editableValueName];
			else
				fld.text=@"";
			fld.font=[UIFont systemFontOfSize: 14.0];
//			fld.textAlignment=UITextAlignmentLeft;
//			fld.clearButtonMode=UITextFieldViewModeWhileEditing;
//			fld.adjustsFontSizeToFitWidth=YES;
			
//			fld.keyboardType=UIKeyboardTypeDefault;
			
			[cell addSubview:fld];
			[self.editingControls addObject:fld];
			break;
		}
		case kBeerCrushEditableValueTypeAddress:
		{
			BOOL bOnStreet=NO;
			NSString* addr_field;
			switch (indexPath.row)
			{
				case 0: // Street
					addr_field=@"street";
					bOnStreet=YES;
					break;
				case 1: // City
					addr_field=@"city";
					break;
				case 2: // State
					addr_field=@"state";
					break;
				case 3: // Zip
					addr_field=@"zip";
					break;
				default:
					// Shouldn't happen
					return nil;
					break;
			}
			
			CGRect f=cell.frame;
			f.size.width-=20;
			f.origin.x+=10;
			UITextField* fld=[[UITextField alloc] initWithFrame:f];
			
			NSMutableDictionary* addr=[self.data objectForKey:self.editableValueName];
			if ([[addr objectForKey:addr_field] isKindOfClass:[NSString class]])
				fld.text=[addr objectForKey:addr_field];
			else
				fld.text=@"";
			fld.font=[UIFont systemFontOfSize:40.0];
			fld.textAlignment=UITextAlignmentCenter;
			fld.clearButtonMode=UITextFieldViewModeWhileEditing;
			fld.adjustsFontSizeToFitWidth=YES;
			
			if (indexPath.row==3) // Zip
				fld.keyboardType=UIKeyboardTypeNumberPad;
			else
				fld.keyboardType=UIKeyboardTypeDefault;
			
			[cell addSubview:fld];
			if (bOnStreet) // Make sure Street is the first item in the array so it becomes first responder in viewDidAppear()
				[self.editingControls insertObject:fld atIndex:0];
			else
				[self.editingControls addObject:fld];
			break;
		}
		case kBeerCrushEditableValueTypeNumber:
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
			
			fld.keyboardType=UIKeyboardTypeNumberPad;
			
			[cell addSubview:fld];
			[self.editingControls addObject:fld];
			break;
		}
		case kBeerCrushEditableValueTypeChoice:
		{
			break;
		}
		default:
			// Shouldn't happen
			return nil;
			break;
	}
	

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


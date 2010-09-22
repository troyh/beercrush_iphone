//
//  NumberDialPicker.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/21/10.
//  Copyright 2010 Optional Corporation. All rights reserved.
//

#import "NumberDialPicker.h"


@implementation NumberDialPicker

@synthesize min;
@synthesize max;
@synthesize value;
@synthesize decimalPositions;
@synthesize numberOfComponents;
@synthesize tag;
@synthesize delegate;

-(id)initWithMinumValue:(float)minval maximumValue:(float)maxval decimalPositions:(NSUInteger)d
{
	self.min=minval;
	self.max=maxval;
	self.decimalPositions=d;
	
	//self.numberOfComponents=(d?2:1); // Start with 1 or 2 and work up from there
	float range=abs(self.max - self.min);
	if (range == 0) 
		self.numberOfComponents=0;
	else if (range < 100)
		self.numberOfComponents=1;
	else
		self.numberOfComponents=(unsigned int)log10(range) + 1; // a component per digit

	self.numberOfComponents+=d;
	
	return self;
}

//-(id)initWithNumberOfDigits:(NSUInteger)n andNumberOfDecimalDigits:(NSUInteger)d
//{
//	self.numberOfDigits=n;
//	return self;
//}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	if ([self isViewLoaded]==NO)
	{
		UIPickerView* view=[[[UIPickerView alloc] initWithFrame:CGRectZero] autorelease];
		view.delegate=self;
		view.dataSource=self;
		view.showsSelectionIndicator=YES;
//		[view selectRow:0 inComponent:0 animated:NO];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	unsigned int dld=self.numberOfComponents - self.decimalPositions;
	if (component == dld)
		return [NSString stringWithFormat:@".%d",row];
	return [NSString stringWithFormat:@"%d",row];
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//	
//}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 60.0 - (self.numberOfComponents * 10.0);
}

#pragma mark UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	return self.numberOfComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	unsigned int dld=self.numberOfComponents - self.decimalPositions;
	if (component < dld) {
		if (dld==1) {
			return abs(self.max - self.min) + 1;
		}
		return 10;
	}
	
	// How many components after the decimal?
	unsigned int dad=self.numberOfComponents - dld;
	if (dad==1)
		return (int)pow(10,self.decimalPositions);
	return 10;
}

@end

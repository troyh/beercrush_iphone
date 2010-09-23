//
//  NumberDialPicker.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/21/10.
//  Copyright 2010 Optional Corporation. All rights reserved.
//

#import "NumberDialPicker.h"
#import "BeerCrushAppDelegate.h"

@implementation NumberDialPicker

@synthesize min;
@synthesize max;
@synthesize value;
@synthesize decimalPositions;
@synthesize numberOfComponentsForInteger;
@synthesize numberOfComponentsForNonInteger;
@synthesize tag;
@synthesize delegate;

-(id)initWithMinumValue:(float)minval maximumValue:(float)maxval decimalPositions:(NSUInteger)d
{
	self.min=minval;
	self.max=maxval;
	self.decimalPositions=d;
	
	float range=abs((int)self.max - (int)self.min);
	if (range < 100)
		self.numberOfComponentsForInteger=1;
	else
		self.numberOfComponentsForInteger=(unsigned int)log10(range) + 1; // a component per digit

	self.numberOfComponentsForNonInteger=d;
	
	return self;
}

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
		
		[self setComponentsToValue];
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

-(int)lowestValueInComponent:(NSInteger)n
{
	if (n < self.numberOfComponentsForInteger) {
		if (self.numberOfComponentsForInteger==1) {
			return (int)self.min;
		}
		return ((int)self.min % (int)pow(10,self.numberOfComponentsForInteger - n)) / pow(10,self.numberOfComponentsForInteger - n - 1);
	}
	else {
		return (int)((int)roundf((self.min - (int)self.min) * pow(10,n - self.numberOfComponentsForInteger + 1)) % 10);
	}
}

-(float)getValueOfComponents {
	float currentValue=0;
	UIPickerView* picker=(UIPickerView*)self.view;
	// Verify that the value is within the min & max values and adjust, if necessary
	for (unsigned int i=0; i < (self.numberOfComponentsForInteger + self.numberOfComponentsForNonInteger); ++i) {
		NSInteger lowest=[self lowestValueInComponent:i];
		NSInteger n=[picker selectedRowInComponent:i];
		if (i < self.numberOfComponentsForInteger) {
			currentValue+=(lowest+n) * pow(10,self.numberOfComponentsForInteger - i - 1);
		}
		else {
			currentValue+=(lowest+n) / pow(10,i - self.numberOfComponentsForInteger + 1);
		}
	}
	return currentValue;
}

-(void)setComponentsToValue {
	if (self.value < self.min) {
		// Fix it
		self.value=self.min;
	}
	else if (self.max < self.value) {
		// Fix it
		self.value=self.max;
	}
	
	UIPickerView* picker=(UIPickerView*)self.view;
	int row;
	for (unsigned int i=0; i < (self.numberOfComponentsForInteger + self.numberOfComponentsForNonInteger); ++i) {
		if (i < self.numberOfComponentsForInteger) {
			if (self.numberOfComponentsForInteger==1)
				row=(int)self.value - [self lowestValueInComponent:i];
			else
				row=(((int)self.value % (int)pow(10,self.numberOfComponentsForInteger - i)) / pow(10,self.numberOfComponentsForInteger - i - 1)) - [self lowestValueInComponent:i];
		}
		else {
			row=((int)roundf(((self.value - (int)self.value) * pow(10,i - self.numberOfComponentsForInteger + 1))) % 10) - [self lowestValueInComponent:i];
		}
		
		[picker selectRow:row inComponent:i animated:YES];
	}
}

#pragma mark UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	self.value=[self getValueOfComponents];
	[self setComponentsToValue];
	[self.delegate numberDialPicker:self didChangeValue:self.value];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	DLog(@"rowHeightForComponent %d:%f",component,pickerView.frame.size.height / 7);
	return pickerView.frame.size.height / 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (component < self.numberOfComponentsForInteger) {
		return [NSString stringWithFormat:@"%d",((int)self.min)+row];
	}
	else {
		if (component == self.numberOfComponentsForInteger)
			return [NSString stringWithFormat:@".%d",row]; // TODO: use locale's decimal point (i.e., commas are used in Europe)
		return [NSString stringWithFormat:@"%d",row];
	}
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//	
//}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if (component < self.numberOfComponentsForInteger) {
		if (self.numberOfComponentsForInteger == 1) {
			int range=abs((int)self.max - (int)self.min);
			return MAX(30.0,((unsigned int)log10(range) + 1) * 30.0);
		}
		return 40.0;
	}
	return 40.0;
//	return (pickerView.frame.size.width - 10) / ((self.numberOfComponentsForInteger + self.numberOfComponentsForNonInteger));
}

#pragma mark UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	return self.numberOfComponentsForInteger + self.numberOfComponentsForNonInteger;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component < self.numberOfComponentsForInteger) {
		if (self.numberOfComponentsForInteger==1)
			return abs((int)self.max - (int)self.min) + 1;
		return 10;
	}
	else {
		if (self.numberOfComponentsForNonInteger==1 && ((int)self.max-(int)self.min)==1)
			return MIN(10,((self.max-(int)self.max)-(self.min-(int)self.min)) * 10);
		return 10;
	}
}

@end

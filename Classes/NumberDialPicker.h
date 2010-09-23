//
//  NumberDialPicker.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/21/10.
//  Copyright 2010 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumberDialPickerDelegate;

@interface NumberDialPicker : UIViewController
	<UIPickerViewDelegate,UIPickerViewDataSource>
{
	float min;
	float max;
	float value;
	NSUInteger decimalPositions;
	NSUInteger numberOfComponentsForInteger;
	NSUInteger numberOfComponentsForNonInteger;
	NSUInteger tag;
	id<NumberDialPickerDelegate> delegate;
}

@property (assign) float min;
@property (assign) float max;
@property (assign) float value;
@property (assign) NSUInteger decimalPositions;
@property (assign) NSUInteger numberOfComponentsForInteger;
@property (assign) NSUInteger numberOfComponentsForNonInteger;
@property (assign) NSUInteger tag;
@property (assign) id<NumberDialPickerDelegate> delegate;

-(id)initWithMinumValue:(float)minval maximumValue:(float)maxval decimalPositions:(NSUInteger)d;
//-(id)initWithNumberOfDigits:(NSUInteger)n andNumberOfDecimalDigits:(NSUInteger)d;
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
//-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView;
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

@protocol NumberDialPickerDelegate

@end

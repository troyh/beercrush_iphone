//
//  DatePickerVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 10/5/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerVCDelegate;


@interface DatePickerVC : UIViewController {
	UIDatePicker* datePicker;
	id<DatePickerVCDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UIDatePicker* datePicker;
@property (nonatomic, assign) id delegate;

-(void)doneButtonClicked;

@end

@protocol DatePickerVCDelegate

-(void)datePickerVC:(DatePickerVC*)datePickerVC didChooseDate:(NSDate*)date;

@end

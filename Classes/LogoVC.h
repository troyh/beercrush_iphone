//
//  LogoVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 10/1/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogoVC : UIViewController {
	UINavigationController* myNC;
}

@property (nonatomic, retain) UINavigationController* myNC;

-(IBAction)infoButtonClicked:(id)sender;

@end

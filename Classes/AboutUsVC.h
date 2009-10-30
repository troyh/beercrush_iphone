//
//  AboutUsVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/30/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface AboutUsVC : UIViewController <MFMailComposeViewControllerDelegate> {

}

-(id)init;

-(IBAction)doneButtonClicked:(id)sender;
-(IBAction)sendFeedbackButtonClicked:(id)sender;

-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

@end

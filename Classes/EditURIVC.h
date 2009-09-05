//
//  EditURIVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditURIVCDelegate;

@interface EditURIVC : UITableViewController {
	NSString* uriToEdit;
	id<EditURIVCDelegate> delegate;
@private
	UITextField* uriTextField;
}

@property (nonatomic,retain) NSString* uriToEdit;
@property (assign) id<EditURIVCDelegate> delegate;
@property (nonatomic,retain) UITextField* uriTextField;

@end

@protocol EditURIVCDelegate

-(void)editURIVC:(EditURIVC*)editURIVC didEditURI:(NSString*)uri;

@end
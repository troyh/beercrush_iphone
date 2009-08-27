//
//  StylesTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 8/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StylesListTVCDelegate;

@interface StylesListTVC : UITableViewController {
	NSDictionary* stylesDictionary;
	NSString* selectedStyleID;
	id<StylesListTVCDelegate> delegate;
}

@property (nonatomic,retain) NSDictionary* stylesDictionary;
@property (nonatomic,retain) NSString* selectedStyleID;
@property (assign) id<StylesListTVCDelegate> delegate;

@end

@protocol StylesListTVCDelegate

-(void)stylesTVC:(StylesListTVC*)tvc didSelectStyle:(NSString*)styleid;

@end


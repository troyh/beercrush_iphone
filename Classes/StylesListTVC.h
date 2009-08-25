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
	NSMutableString* currentStyleNum;
	NSMutableString* currentElemValue;
	NSMutableArray* xmlParserPath;
	
	id<StylesListTVCDelegate> delegate;
}

@property (nonatomic,retain) NSDictionary* stylesDictionary;
@property (nonatomic,retain) NSMutableString* currentStyleNum;
@property (nonatomic,retain) NSMutableString* currentElemValue;
@property (nonatomic,retain) NSMutableArray* xmlParserPath;
@property (assign) id<StylesListTVCDelegate> delegate;

@end

@protocol StylesListTVCDelegate

-(void)stylesTVC:(StylesListTVC*)tvc didSelectStyle:(NSString*)styleid;

@end


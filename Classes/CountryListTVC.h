//
//  CountryListTVC.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryListTVCDelegate;

@interface CountryListTVC : UITableViewController {
	NSMutableArray* countryList;
	id<CountryListTVCDelegate> delegate;
}

@property (nonatomic,retain) NSMutableArray* countryList;
@property (assign) id<CountryListTVCDelegate> delegate;

-(id)init;

@end

@protocol CountryListTVCDelegate

-(void)countryList:(CountryListTVC*)countryList didSelectCountry:(NSString*)countryName;

@end
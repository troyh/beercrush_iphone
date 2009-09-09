//
//  PhotoViewer.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoViewer : UIViewController <UIScrollViewDelegate> {
	NSArray* photoNamesList;
	NSMutableArray* imageList;
	UIScrollView* scrollView;
	NSUInteger currentPhotoNumber;
}

@property (nonatomic,retain) NSArray* photoNamesList;
@property (nonatomic,retain) NSMutableArray* imageList;
@property (nonatomic,retain) UIScrollView* scrollView;
@property (assign) NSUInteger currentPhotoNumber;

-(id)initWithPhotoList:(NSArray*)photoList;
-(void)loadPhoto:(NSUInteger)photoNumber;

@end

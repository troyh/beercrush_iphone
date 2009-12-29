//
//  PhotoViewer.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoViewerDelegate;

@interface PhotoViewer : UIViewController 
		<UIScrollViewDelegate,
		UIActionSheetDelegate,
		UIImagePickerControllerDelegate,
		UINavigationControllerDelegate> 
{
	NSDictionary* photoSet;
	NSMutableArray* imageList;
	UIScrollView* scrollView;
	NSUInteger currentPhotoNumber;
	id<PhotoViewerDelegate> delegate;
}

@property (nonatomic,retain) NSDictionary* photoSet;
@property (nonatomic,retain) NSMutableArray* imageList;
@property (nonatomic,retain) UIScrollView* scrollView;
@property (assign) NSUInteger currentPhotoNumber;
@property (assign) id<PhotoViewerDelegate> delegate;

-(id)initWithPhotoSet:(NSDictionary*)photoSet;
-(void)loadPhoto:(NSUInteger)photoNumber;

@end

@protocol PhotoViewerDelegate

-(void)photoViewer:(PhotoViewer*)photoViewer didSelectPhotoToUpload:(UIImage*)photo;

@end


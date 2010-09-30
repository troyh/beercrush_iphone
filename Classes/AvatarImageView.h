//
//  AvatarImageView.h
//  BeerCrush
//
//  Created by Troy Hakala on 9/29/10.
//  Copyright 2010 Optional Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AvatarImageView : UIImageView {
	NSURL* avatarURL;
}

@property (nonatomic,retain) NSURL* avatarURL;

-(void)avatarURLFromString:(NSString*)url;

@end

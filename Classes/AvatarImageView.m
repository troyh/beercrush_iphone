//
//  AvatarImageView.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/29/10.
//  Copyright 2010 Optional Corporation. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "AvatarImageView.h"


@implementation AvatarImageView

@synthesize avatarURL;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.image=[UIImage imageNamed:@"avatar_default.png"];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)avatarURLFromString:(NSString*)url
{
	if (url!=nil && [url length]) {
		self.avatarURL=[NSURL URLWithString:url];
		BeerCrushAppDelegate* appDelegate=(BeerCrushAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate performAsyncOperationWithTarget:self selector:@selector(loadAvatar) object:nil requiresUserCredentials:NO activityHUDText:nil];
	}
	else {
		self.avatarURL=nil;
	}
}

-(void)loadAvatar
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	UIImage* img=[UIImage imageWithData:[NSData dataWithContentsOfURL:self.avatarURL]];
	[self performSelectorOnMainThread:@selector(displayAvatar:) withObject:img waitUntilDone:NO];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}

-(void)displayAvatar:(UIImage*)img
{
	self.image=img;
}

- (void)dealloc {
	[self.avatarURL release];
    [super dealloc];
}


@end

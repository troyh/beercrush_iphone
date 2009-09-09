//
//  PhotoViewer.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewer.h"


@implementation PhotoViewer

@synthesize photoNamesList;
@synthesize imageList;
@synthesize scrollView;
@synthesize currentPhotoNumber;

-(id)initWithPhotoList:(NSArray*)photoList
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        // Custom initialization
		self.title=@"Photos";
		
		self.photoNamesList=photoList;
		self.imageList=[NSMutableArray arrayWithCapacity:[self.photoNamesList count]];
		for (NSUInteger i=0; i < [self.photoNamesList count]; ++i) {
			[self.imageList addObject:[NSNull null]];
		}
    }
    return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.scrollView=[[[UIScrollView alloc] initWithFrame:self.view.frame] autorelease];
	self.scrollView.backgroundColor=[UIColor blackColor];
	self.scrollView.contentSize=CGSizeMake(scrollView.frame.size.width*[self.photoNamesList count], scrollView.frame.size.height);
	self.scrollView.pagingEnabled=YES;
	self.scrollView.delegate=self;
	
	self.view=self.scrollView;
	
	// Add UIPageControl
//	UIPageControl* pageControl=[[[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 40)] autorelease];
//	pageControl.numberOfPages=[self.photoNamesList count];
//	[self.view addSubview:pageControl];
	
	[self loadPhoto:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentPhotoNumber = page;
	
	[self loadPhoto:self.currentPhotoNumber-1];
	[self loadPhoto:self.currentPhotoNumber];
	[self loadPhoto:self.currentPhotoNumber+1];
}

-(void)loadPhoto:(NSUInteger)photoNumber
{
	if (photoNumber<0)
		return;
	if (photoNumber>=[self.photoNamesList count])
		return;
	
	if ([self.imageList objectAtIndex:photoNumber]==[NSNull null])
	{
		// Load the image into the view
		[self.imageList replaceObjectAtIndex:photoNumber withObject:[UIImage imageNamed:[self.photoNamesList objectAtIndex:photoNumber]]];
		UIImageView* photo=[[[UIImageView alloc] initWithImage:[self.imageList objectAtIndex:photoNumber]] autorelease];
		
		
		CGRect f=CGRectMake((self.view.frame.size.width*photoNumber)+(self.view.frame.size.width-MIN(photo.image.size.width,self.view.frame.size.width))/2, 
							(self.view.frame.size.height-MIN(photo.image.size.height,self.view.frame.size.height))/2,
							photo.image.size.width, 
							photo.image.size.height);
		
		photo.frame=f;
		[self.view addSubview:photo];
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self.photoNamesList release];
	[self.imageList release];
	[self.scrollView release];
	
    [super dealloc];
}


@end

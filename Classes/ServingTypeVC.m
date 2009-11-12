//
//  ServingTypeVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 11/10/09.
//  Copyright 2009 Optional Corporation. All rights reserved.
//

#import "ServingTypeVC.h"


@implementation ServingTypeVC

@synthesize delegate;
@synthesize selectedType;
@synthesize servingTypeOptions;
@synthesize dataObject;

-(id)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.servingTypeOptions=[[NSArray alloc] initWithObjects:
								 [[[NSArray alloc] initWithObjects:@"Tap",[NSNumber numberWithInt:BeerCrushServingTypeTap],@"draft.png",nil] autorelease],
								 [[[NSArray alloc] initWithObjects:@"Cask",[NSNumber numberWithInt:BeerCrushServingTypeCask],@"cask.png",nil] autorelease],
								 [[[NSArray alloc] initWithObjects:@"Bottle (12 fl. oz./355ml)",[NSNumber numberWithInt:BeerCrushServingTypeBottle355],@"bottle12.png",nil] autorelease],
								 [[[NSArray alloc] initWithObjects:@"Bottle (22 fl. oz./650ml)",[NSNumber numberWithInt:BeerCrushServingTypeBottle650],@"bottle22.png",nil] autorelease],
								 [[[NSArray alloc] initWithObjects:@"Can",[NSNumber numberWithInt:BeerCrushServingTypeCan],@"can.png",nil] autorelease],
								 nil];
		
		self.title=NSLocalizedString(@"Served",@"Title for Serving Type view controller");
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.servingTypeOptions count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSArray* opt=[self.servingTypeOptions objectAtIndex:indexPath.row];
	[cell.textLabel setText:[opt objectAtIndex:0]];
	cell.imageView.image=[UIImage imageNamed:[opt objectAtIndex:2]];
	
	if (self.selectedType & [[opt objectAtIndex:1] intValue])
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType=UITableViewCellAccessoryNone;
		
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NSArray* opt=[self.servingTypeOptions objectAtIndex:indexPath.row];
	// Toggle the bit
	BeerCrushServingType t=[[opt objectAtIndex:1] intValue];
	self.selectedType^=t;
		
	// Toggle the checkmark
	UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
	if (self.selectedType & t)
	{
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
		[self.delegate servingTypeVC:self didSelectServingType:t setOn:YES];
	}
	else
	{
		cell.accessoryType=UITableViewCellAccessoryNone;
		[self.delegate servingTypeVC:self didSelectServingType:t setOn:NO];
	}
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end


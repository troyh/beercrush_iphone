//
//  EditAddressVC.m
//  BeerCrush
//
//  Created by Troy Hakala on 9/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditAddressVC.h"


@implementation EditAddressVC

@synthesize addressToEdit;
@synthesize delegate;
@synthesize street1;
@synthesize street2;
@synthesize city;
@synthesize state;
@synthesize zip;

-(id)init 
{
	if (self=[super initWithStyle:UITableViewStyleGrouped])
	{
		self.title=@"Edit Address";
		
		street1=[[UITextField alloc] initWithFrame:CGRectMake(5, 10, 290, 30)];
		street1.font=[UIFont systemFontOfSize:16];
		street1.placeholder=@"Street";
		
		street2=[[UITextField alloc] initWithFrame:CGRectMake(5, 10, 290, 30)];
		street2.placeholder=@"Street";
		street2.font=[UIFont systemFontOfSize:16];

		city=[[UITextField alloc] initWithFrame:CGRectMake(5, 10, 150, 30)];
		city.placeholder=@"City";
		city.font=[UIFont systemFontOfSize:16];

		state=[[UITextField alloc] initWithFrame:CGRectMake(160, 10, 30, 30)];
		state.placeholder=@"State";
		state.font=[UIFont systemFontOfSize:16];

		zip=[[UITextField alloc] initWithFrame:CGRectMake(200, 10, 100, 30)];
		zip.placeholder=@"Zip Code";
		zip.font=[UIFont systemFontOfSize:16];
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

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)] autorelease];
	
	[street1 setText:[self.addressToEdit objectForKey:@"street"]];
	[city setText:[self.addressToEdit objectForKey:@"city"]];
	[state setText:[self.addressToEdit objectForKey:@"state"]];
	[zip setText:[self.addressToEdit objectForKey:@"zip"]];
	
}

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
    return 4;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    switch (indexPath.row) {
		case 0:
			[cell.contentView addSubview:self.street1];
			break;
		case 1:
			[cell.contentView addSubview:self.street2];
			break;
		case 2:
			[cell.contentView addSubview:self.city];
			[cell.contentView addSubview:self.state];
			[cell.contentView addSubview:self.zip];
			break;
		case 3:
			[cell.textLabel setText:[self.addressToEdit objectForKey:@"country"]];
			break;
		default:
			break;
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.row==3)
	{
		CountryListTVC* vc=[[[CountryListTVC alloc] init] autorelease];
		vc.delegate=self;
		[self.navigationController pushViewController:vc animated:YES];
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

#pragma mark BarButtonSystemItem action method

-(void)doneButtonClicked:(id)sender
{
	// Take data from edit controls
	[self.addressToEdit setObject:self.street1.text forKey:@"street"];
	[self.addressToEdit setObject:self.city.text forKey:@"city"];
	[self.addressToEdit setObject:self.state.text forKey:@"state"];
	[self.addressToEdit setObject:self.zip.text forKey:@"zip"];
	
	[self.delegate editAddressVC:self didEditAddress:self.addressToEdit];
}

#pragma mark CountryListTVCDelegate methods

-(void)countryList:(CountryListTVC*)countryList didSelectCountry:(NSString*)countryName
{
	[self.addressToEdit setObject:countryName forKey:@"country"];
	[self.tableView reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}



- (void)dealloc {
	[self.addressToEdit release];
	[self.street1 release];
	[self.street2 release];
	[self.city release];
	[self.state release];
	[self.zip release];

    [super dealloc];
}


@end


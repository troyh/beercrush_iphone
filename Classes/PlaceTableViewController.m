//
//  BreweryTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BeerCrushAppDelegate.h"
#import "PlaceTableViewController.h"
#import "ReviewsTableViewController.h"
#import "BeerListTableViewController.h"
#import "PhoneNumberEditTableViewController.h"


@implementation PlaceTableViewController

@synthesize placeID;
@synthesize placeObject;
@synthesize app;
@synthesize appdel;
@synthesize currentElemValue;
@synthesize xmlPostResponse;

-(id) initWithPlaceID:(NSString*)place_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d
{
	self.placeID=place_id;
	self.app=a;
	self.appdel=d;
	
	self.title=@"Place";
	
	[super initWithStyle:UITableViewStyleGrouped];
	
	placeObject=[[PlaceObject alloc] init];
	
	// Retrieve XML doc from server
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:BEERCRUSH_API_URL_GET_PLACE_DOC, placeID ]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	
	return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	if (editing==YES)
	{
		self.title=@"Editing Place";
	}
	else
	{
		// Save data to server
		NSString* bodystr=[[NSString alloc] initWithFormat:
									@"place_id=%@&"
									"address/city=%@&"
									"address/state=%@&"
									"address/street=%@&"
									"address/zip=%@&"
									"name=%@&"			
									"phone=%@&"
									"uri=%@",
									self.placeID,
									[[self.placeObject.data objectForKey:@"address"] objectForKey:@"city"],
									[[self.placeObject.data objectForKey:@"address"] objectForKey:@"state"],
									[[self.placeObject.data objectForKey:@"address"] objectForKey:@"street"],
									[[self.placeObject.data objectForKey:@"address"] objectForKey:@"zip"],
									[self.placeObject.data objectForKey:@"name"],
									[self.placeObject.data objectForKey:@"phone"],
									[self.placeObject.data objectForKey:@"uri"]];
		
		NSLog(@"POST data:%@",bodystr);
		NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];
		
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_EDIT_PLACE_DOC]
																cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:60.0];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest setHTTPBody:body];
		[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
		
		// create the connection with the request and start loading the data
		NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		
		if (theConnection) {
			// Create the NSMutableData that will hold
			// the received data
			// receivedData is declared as a method instance elsewhere
			xmlPostResponse=[[NSMutableData data] retain];
		} else {
			// TODO: inform the user that the download could not be made
		}	
		
		self.title=@"Place";
	}
}


//- (void)editPlace:(id)sender
//{
////	UIBarButtonItem* button=(UIBarButtonItem*)sender;
////	button.style=UIBarButtonItemStyleDone;
//	self.editButtonItem.style=UIBarButtonItemStyleDone;
//	self.title=@"Editing Place";
//	[self.tableView setEditing:(self.tableView.editing==YES?NO:YES) animated:YES];
//}

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
 
// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	 self.navigationItem.rightBarButtonItem = self.editButtonItem;
//	 SEL oldsel=self.navigationItem.rightBarButtonItem.action;
//	 self.navigationItem.rightBarButtonItem.action=@selector(editPlace:);
//	 UINavigationController* nav=(UINavigationController*)self.parentViewController;
//	 [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPlace)]];

 }


 - (void)viewWillAppear:(BOOL)animated {
	 [super viewWillAppear:animated];
	 [self.tableView reloadData]; // Reload data because we may come back from an editing view controller
 }

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
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
			break;
		case 1:
			return 3;
			break;
		default:
			break;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	tableView.allowsSelectionDuringEditing=YES;

    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0:
			switch (indexPath.row)
			{
			case 0:
				cell.text=[placeObject.data valueForKey:@"name"];
				cell.font=[UIFont boldSystemFontOfSize:20];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
			{
				NSArray* ratings=[NSArray arrayWithObjects:@" 1 ",@" 2 ",@" 3 ",@" 4 ",@" 5 ",nil];
				UISegmentedControl* ratingctl=[[UISegmentedControl alloc] initWithItems:ratings];
				[cell.contentView addSubview:ratingctl];
				
				[ratingctl addTarget:self action:@selector(ratingButtonTapped:event:) forControlEvents:UIControlEventValueChanged];
				break;
			}
			case 2:
				cell.text=@"Ratings & Reviews";
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 3:
				cell.text=@"List of Beers";
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				break;
			default:
				break;
			}
			break;
		case 1:
			switch (indexPath.row)
			{
			case 0:
				cell.text=[placeObject.data valueForKey:@"uri"];
				cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
				cell.textAlignment=UITextAlignmentCenter;
				break;
			case 1:
			{
				NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
					
				cell.text=[NSString stringWithFormat:@"%@, %@ %@ %@",
						[addr objectForKey:@"street"],
						[addr objectForKey:@"city"],
						[addr objectForKey:@"state"],
						[addr objectForKey:@"zip"]];
				cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				cell.textAlignment=UITextAlignmentCenter;
				break;
			}
			case 2:
				cell.text=[placeObject.data valueForKey:@"phone"];
				cell.font=[UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				cell.hidesAccessoryWhenEditing=NO;
				cell.textAlignment=UITextAlignmentCenter;
				break;
			default:
				break;
			}
	}
	
	
    return cell;
}

-(void)ratingButtonTapped:(id)sender event:(id)event
{
	UISegmentedControl* segctl=(UISegmentedControl*)sender;
	NSInteger rating=segctl.selectedSegmentIndex;
	
	// Send the review to the site
	
	NSString* bodystr=[[NSString alloc] initWithFormat:@"rating=%u&place_id=%@", rating+1, placeID];
	NSData* body=[NSData dataWithBytes:[bodystr UTF8String] length:[bodystr length]];
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:BEERCRUSH_API_URL_POST_PLACE_REVIEW]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:60.0];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody:body];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// create the connection with the request and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		xmlPostResponse=[[NSMutableData data] retain];
	} else {
		// TODO: inform the user that the download could not be made
	}	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == 0 && indexPath.row == 0) // Name is the 1st row in the 1st section
	{
		if (self.tableView.editing==YES)
		{
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=placeObject.data;
			pnetvc.editableValueName=@"name";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeText;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
	}
	else if (indexPath.section == 0 && indexPath.row == 2) // Reviews is the 2nd row in the 1st section
	{
		if (self.tableView.editing==YES)
		{
			// Do nothing
		}
		else
		{
			ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.placeID dataType:Place];
			[self.navigationController pushViewController: rtvc animated:YES];
			[rtvc release];
		}
	}
	else if (indexPath.section == 0 && indexPath.row == 3) // List of beers is the 3rd row in the 1st section
	{
		if (self.tableView.editing==YES)
		{
			// Do nothing
		}
		else
		{
			BeerListTableViewController* bltvc=[[BeerListTableViewController alloc] initWithBreweryID:self.placeID andApp:self.app];
			[self.navigationController pushViewController: bltvc animated:YES];
			[bltvc release];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 0) // Web site cell
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit URL
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=placeObject.data;
			pnetvc.editableValueName=@"uri";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeURI;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
			[app openURL:[[NSURL alloc] initWithString: [placeObject.data valueForKey:@"uri" ]]];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 1) // Address cell
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit address
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.data=placeObject.data;
			pnetvc.editableValueName=@"address";
			pnetvc.editableValueType=kBeerCrushEditableValueTypeAddress;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
			NSMutableDictionary* addr=[placeObject.data valueForKey:@"address"];
			
			[app openURL:[[NSURL alloc] initWithString: [NSString stringWithFormat:@"http://maps.google.com/maps?g=%@, %@ %@ %@",
														 [addr valueForKey:@"street"],
														 [addr valueForKey:@"city"],
														 [addr valueForKey:@"state"],
														 [addr valueForKey:@"zip"]]]];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 2) // Phone number cell
	{
		if (self.tableView.editing==YES)
		{
			// Go to view to edit phone number
			PhoneNumberEditTableViewController* pnetvc=[[PhoneNumberEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
			pnetvc.editableValueName=@"phone";
			pnetvc.data=placeObject.data;
			pnetvc.editableValueType=kBeerCrushEditableValueTypePhoneNumber;
			[self.navigationController pushViewController:pnetvc animated:YES];
			[pnetvc release];
		}
		else
		{
			[app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [placeObject.data valueForKey:@"phone"] ]]];
		}
	}
}

// The accessory view is on the right side of each cell. We'll use a "disclosure" indicator in editing mode,
// to indicate to the user that selecting the row will navigate to a new view where details can be edited.
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
    return (self.editing) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
	 switch (indexPath.section) 
	 {
		 case 0:
			 switch (indexPath.row)
		 {
			 case 0:
				 break;
			 case 1:
				 break;
			 case 2:
				 return NO;
				 break;
			 case 3:
				 return NO;
				 break;
			 default:
				 break;
		 }
			 break;
		 case 1:
			 switch (indexPath.row)
		 {
			 case 0:
				 break;
			 case 1:
				 break;
			 case 2:
//				 return NO;
				 break;
			 default:
				 break;
		 }
	 }
	 
	 return YES;
 }



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

// NSXMLParser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	// Clear any old data
	self.currentElemValue=nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"name"] ||
	    [elementName isEqualToString:@"street"] ||
	    [elementName isEqualToString:@"city"] ||
	    [elementName isEqualToString:@"state"] ||
	    [elementName isEqualToString:@"zip"] ||
	    [elementName isEqualToString:@"country"] ||
	    [elementName isEqualToString:@"uri"] ||
	    [elementName isEqualToString:@"phone"]
		)
	{
		self.currentElemValue=[NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"name"])
			[placeObject.data setObject:currentElemValue forKey:@"name"];
		else if ([elementName isEqualToString:@"street"])
		{
			NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
			[addr setObject:currentElemValue forKey:@"street"];
		}
		else if ([elementName isEqualToString:@"city"])
		{
			NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
			[addr setObject:currentElemValue forKey:@"city"];
		}
		else if ([elementName isEqualToString:@"state"])
		{
			NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
			[addr setObject:currentElemValue forKey:@"state"];
		}
		else if ([elementName isEqualToString:@"zip"])
		{
			NSMutableDictionary* addr=[placeObject.data objectForKey:@"address"];
			[addr setObject:currentElemValue forKey:@"zip"];
		}
		else if ([elementName isEqualToString:@"uri"])
			[placeObject.data setObject:currentElemValue forKey:@"uri"];
		else if ([elementName isEqualToString:@"phone"])
			[placeObject.data setObject:currentElemValue forKey:@"phone"];
		
		self.currentElemValue=nil;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.currentElemValue)
	{
		[self.currentElemValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}

// NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [xmlPostResponse setLength:0];
	
	NSHTTPURLResponse* httprsp=(NSHTTPURLResponse*)response;
	NSInteger n=httprsp.statusCode;
	
	if (n==401)
	{
		NSLog(@"Need to login...");
		[appdel login];
		// TODO: once logged in, re-try the HTTP request
	}
	else
		NSLog(@"Status code:%u",n);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [xmlPostResponse appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
	
    // receivedData is declared as a method instance elsewhere
    [xmlPostResponse release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"PlaceTableViewController:connectionDidFinishLoading Succeeded! Received %d bytes of data",[xmlPostResponse length]);
	NSLog(@"Response doc:%s",(char*)[xmlPostResponse mutableBytes]);
	
    // release the connection, and the data object
    [connection release];
    [xmlPostResponse release];
}


@end


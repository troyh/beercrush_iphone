//
//  BeerTableViewController.m
//  BeerCrush
//
//  Created by Troy Hakala on 2/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import "BeerTableViewController.h"
#import "ReviewsTableViewController.h"

@implementation BeerTableViewController

@synthesize beerID;
@synthesize app;
@synthesize appdel;
@synthesize beerObj;
@synthesize currentElemValue;
@synthesize xmlParseDepth;

-(id) initWithBeerID:(NSString*)beer_id app:(UIApplication*)a appDelegate:(BeerCrushAppDelegate*)d
{
	self.beerID=beer_id;
	self.app=a;
	self.appdel=d;

	self.beerObj=[BeerObject alloc];
	self.title=@"Beer";
	
	[super initWithStyle:UITableViewStyleGrouped];
	
	// Retrieve XML doc for this beer
	NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"http://dev:81/xml/beer/%@.xml", beerID ]];
	NSXMLParser* parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser parse];
	
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
			return 3;
			break;
		case 1:
			return 2;
			break;
		default:
			break;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
			{
				CGSize sz=[beerObj.description sizeWithFont:[UIFont systemFontOfSize: [UIFont smallSystemFontSize]] constrainedToSize:CGSizeMake(280.f, 500.0f) lineBreakMode:UILineBreakModeWordWrap];
				return sz.height+20.0f;
				break;
			}
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
			default:
				break;
			}
	}
	return 44.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: If we don't have the data yet, request it from the server
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	switch (indexPath.section) 
	{
		case 0:
			switch (indexPath.row)
		{
			case 0:
				cell.text=beerObj.name;
				cell.font=[UIFont boldSystemFontOfSize:20];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
				cell.text=@"Rating & Reviews";
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				break;
			case 2:
			{
//				cell.text=beerObj.description;
				CGRect contentRect=CGRectMake(10, 10, 0, 0);
				UILabel* textView=[[UILabel alloc] initWithFrame:contentRect];
				textView.text=beerObj.description;
				
				contentRect.size=[textView.text sizeWithFont:[UIFont systemFontOfSize: [UIFont smallSystemFontSize]] constrainedToSize:CGSizeMake(280.f, 500.0f)];
				textView.frame=contentRect;
				
				textView.numberOfLines=0;
				textView.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
				textView.lineBreakMode=UILineBreakModeWordWrap;
				[textView sizeToFit];

				cell.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				cell.lineBreakMode=UILineBreakModeWordWrap;
				
				[cell.contentView addSubview:textView];
				[cell.contentView sizeToFit];
				[textView release];
				break;
			}
			default:
				break;
		}
			break;
		case 1:
			switch (indexPath.row)
		{
			case 0:
				cell.text=beerObj.style;
				cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			case 1:
				if (beerObj.ibu)
					cell.text=[[NSString alloc] initWithFormat:@"%u%% ABV %u IBUs", beerObj.abv, beerObj.ibu];
				else
					cell.text=[[NSString alloc] initWithFormat:@"%u%% ABV", beerObj.abv];
				
				cell.font=[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				break;
			default:
				break;
		}
	}
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.section == 0 && indexPath.row == 1) 
	{
		ReviewsTableViewController*	rtvc=[[ReviewsTableViewController alloc] initWithID:self.beerID dataType:Beer];
		[self.navigationController pushViewController: rtvc animated:YES];
		[rtvc release];
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
	++xmlParseDepth;
	
	if ([elementName isEqualToString:@"beer"])
	{
		NSString* s=[attributeDict valueForKey:@"abv"];
		beerObj.abv=s.intValue;
//		[s release];
		s=[attributeDict valueForKey:@"ibu"];
		beerObj.ibu=s.intValue;
//		[s release];
	}
	else if ([elementName isEqualToString:@"name"])
	{
		if (xmlParseDepth==2)
			self.currentElemValue=[NSMutableString string];
	}
	else if ([elementName isEqualToString:@"description"])
	{
		if (xmlParseDepth==2)
			self.currentElemValue=[NSMutableString string];
	}
	else if ([elementName isEqualToString:@"style"])
	{
		if (xmlParseDepth==3)
			self.currentElemValue=[NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	--xmlParseDepth;
	
	if (self.currentElemValue)
	{
		if ([elementName isEqualToString:@"name"])
		{
			beerObj.name=currentElemValue;
		}
		else if ([elementName isEqualToString:@"description"])
		{
			beerObj.description=currentElemValue;
		}
		else if ([elementName isEqualToString:@"style"])
		{
			if ([beerObj.style length] == 0) // Only take the 1st style
				beerObj.style=currentElemValue;
		}
		
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


@end


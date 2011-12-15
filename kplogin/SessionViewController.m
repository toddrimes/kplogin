//
//  ViewController.m
//  kplogin
//
//  Created by TODD RIMES on 12/6/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import "SessionViewController.h"
#import "AFXMLRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "AFXMLRequestOperation.h"
#import "AFKarmapointsClient.h"
#import "KPEvent.h"

AFKarmapointsClient *sharedClient = nil;
bool loggedIn = false;

@implementation SessionViewController

@synthesize username, password, eventPicker, receivedData, sessid, eventArray, pickedEvent, currentElement, currentEvent;

-(id) init {
    self = [super init];
    self.eventArray = nil;
    return self;
}

- (IBAction) loginButtonTapped
{
    NSLog(@"You tapped LOGIN!");
    if (!sharedClient) {
        sharedClient = [AFKarmapointsClient new];
    }
    
    NSNumber *uid = [sharedClient loginWithUser:username.text pass:password.text];
    NSNumber *tester = [NSNumber numberWithInt:0];
    if([uid isEqualToNumber:tester]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: @"An error occured.  Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        loggedIn = true;
        // tell the rootview controller to push on the event picker view
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You are logged in.  To logout, quit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void) loadEvents {
    eventArray = [[NSMutableArray alloc] init];
    /* Operation Queue init (autorelease) */
    NSOperationQueue *queue = [NSOperationQueue new];
    
    NSMutableURLRequest *eventsRequest = [sharedClient requestWithMethod:@"GET" path:@"/rest/views/view_mobile_coordinator_events" parameters:nil];
    
    AFXMLRequestOperation *eventOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:eventsRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        XMLParser.delegate = (id)self;
        [XMLParser parse];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
        NSLog(@"Didn't get any events.   Bummer.");
    }];
    
    NSBlockOperation *updatePickerOperation = 
    [NSBlockOperation blockOperationWithBlock:^{
        [self showEventSelector];
    }];
    
    /* Add the operation to the queue */
    [updatePickerOperation addDependency:eventOperation];
    [queue addOperation:eventOperation];
    [queue addOperation:updatePickerOperation];
    [queue waitUntilAllOperationsAreFinished];
}

- (void) showEventSelector
{
    eventPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 244, 320, 216)];
    eventPicker.delegate = self;
    eventPicker.showsSelectionIndicator = YES;
    [self.view addSubview:eventPicker];
}

- (IBAction) eventRowPicked
{
}

- (IBAction) logoutButtonTapped
{
    NSLog(@"You tapped LOGOUT!");

    if (!sharedClient) {
        sharedClient = [AFKarmapointsClient new];
    }
    [sharedClient logout];
}


-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
} 

#pragma mark - Connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // cast the response to NSHTTPURLResponse so we can look for 404 etc
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([httpResponse statusCode] >= 400) {
        // do error handling here
        NSLog(@"remote url returned error %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
    } else {
        // start recieving data
        NSLog(@"response code is %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);

        NSDictionary *headers = [[NSDictionary alloc] init ];
        headers = [httpResponse allHeaderFields];
        
        for(NSString *key in [headers allKeys]) {
            NSLog(@"%@",[headers objectForKey:key]);
        }
        
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        {
            NSLog(@"name: '%@'\n",   [cookie name]);
            NSLog(@"value: '%@'\n",  [cookie value]);
            NSLog(@"domain: '%@'\n", [cookie domain]);
            NSLog(@"path: '%@'\n",   [cookie path]);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:receivedData];
    parser.delegate = (id)self;
    [parser parse];
    
    // release the connection, and the data object
    connection = nil;
    receivedData = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger mycount = [self.eventArray count];
    return mycount;
}

- (NSString *)pickerView:(UIPickerView *)picker titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *thisTitle = [[self.eventArray objectAtIndex:row] title];
    return thisTitle;
}

#pragma mark - 
#pragma mark UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    NSLog(@"You picked: %@",[[self.eventArray objectAtIndex:row] title]);

}

// TODO: set a cookie with selected event nid and call back to AppDelegate or RootView Controller to push scan/chekin view onto stack
// FIXME: the picker should only bee refreshed if it is already displayed
// ???: What is this?
// !!!: This is too wrong!

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    // The first button (or cancel button)
    if (buttonIndex == 0 && loggedIn) {
        [self loadEvents];
        [self showEventSelector];
    }
}

#pragma mark -
#pragma mark - NXSMLParserDelegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    self->currentParsedCharacterData = [NSMutableString stringWithString:@""];
    self.currentElement = elementName;
    if([elementName isEqualToString:@"item"]) {
        self.currentEvent = [[KPEvent alloc] init];
    }
    NSLog(@"***START element %@",self.currentElement);
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([elementName isEqualToString:@"nid"]){
        self.currentEvent.nid = self->currentParsedCharacterData;
    }
    
    if([elementName isEqualToString:@"node_data_field_start_datetime_field_start_datetime_value"]){
        self.currentEvent.startDateTime = [self->currentParsedCharacterData substringToIndex:10];
    }
    
    if([elementName isEqualToString:@"node_title"]){
        self.currentEvent.title = self->currentParsedCharacterData;
    }
    
    if([elementName isEqualToString:@"item"]){
        [self.eventArray addObject:self.currentEvent];    }
    NSLog(@"END OF element %@***",elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self->currentParsedCharacterData appendString:string];
}


@end

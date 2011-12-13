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
#import "AFKarmapointsClient.h"

AFKarmapointsClient *sharedClient = nil;

@implementation SessionViewController

@synthesize username, password, webResponse, receivedData, sessid;

- (IBAction) loginButtonTapped
{
    NSLog(@"You tapped LOGIN!");
    if (!sharedClient) {
        sharedClient = [AFKarmapointsClient new];
    }
    
    NSNumber *uid = [sharedClient loginWithUser:username.text pass:password.text];
    NSNumber *tester = [NSNumber numberWithInt:0];
    if([uid isEqualToNumber:tester]) {
        webResponse.text = @"An error occured.  Please try again.";
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You are logged in.  To logout, quit." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        // tell the rootview controller to push on the event picker view
        NSArray *events = [sharedClient getCoordinatorEvents];
        [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@ card at index %d", obj, idx);  
        }];
    }
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

@end

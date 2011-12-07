//
//  ViewController.m
//  kplogin
//
//  Created by TODD RIMES on 12/6/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPClient.h"

@implementation ViewController

@synthesize username, password, webResponse, receivedData, kpClient;

- (IBAction) loginButtonTapped
{
    NSLog(@"You tapped it!");
    
    if ( [username.text length] > 0 && [password.text length] > 0  ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *url = [NSString stringWithFormat:
                         @"http://www.karmapoints.org/rest/system/connect"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] 
                                        init];
        
        [request setURL:[NSURL URLWithString:url]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"name=%@&pass=%@", 
                           [defaults stringForKey:@"username"], 
                           password.text] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];        
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        /*
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:@"300" forHTTPHeaderField:@"Keep-Alive"];
         */
        [request setHTTPShouldHandleCookies:YES];
        /*
         $curl = curl_init($request_url);
         curl_setopt($curl, CURLOPT_HTTPHEADER, array('Accept: application/json')); // Accept JSON response
         curl_setopt($curl, CURLOPT_POST, 1); // Do a regular HTTP POST
         curl_setopt($curl, CURLOPT_POSTFIELDS, $user_data); // Set POST data
         curl_setopt($curl, CURLOPT_HEADER, FALSE);  // Ask to not return Header
         curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
         curl_setopt($curl, CURLOPT_FAILONERROR, TRUE);
         */
        
        [request setTimeoutInterval:10.0];
        
        NSDictionary *headers = [[NSDictionary alloc] init ];
        headers = [request allHTTPHeaderFields];
        
        for(NSString *key in [headers allKeys]) {
            NSLog(@"%@",[headers objectForKey:key]);
        }
        
        NSLog([NSString stringWithFormat:@"|%@|", [request HTTPBody]]);
        
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];

        
// [self getNewMessages];
    }
    
    password.text = @"";
}
              
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

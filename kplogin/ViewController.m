//
//  ViewController.m
//  kplogin
//
//  Created by TODD RIMES on 12/6/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import "ViewController.h"
#import "AFXMLRequestOperation.h"
#import "AFHTTPRequestOperation.h"

@implementation ViewController

@synthesize username, password, webResponse, receivedData, sessid, currentElement;

- (IBAction) loginButtonTapped
{
    NSLog(@"You tapped it!");
    
    if ( [username.text length] > 0 && [password.text length] > 0  ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *url = [NSString stringWithFormat:@"http://www.karmapoints.org/rest/system/connect"];
        
        NSMutableURLRequest *sessionRequest = [[NSMutableURLRequest alloc] init];
        
        [sessionRequest setURL:[NSURL URLWithString:url]];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"name=%@&pass=%@", 
                           [defaults stringForKey:@"username"], 
                           password.text] dataUsingEncoding:NSUTF8StringEncoding]];
        [sessionRequest setHTTPBody:body];        
        [sessionRequest setHTTPMethod:@"POST"];
        [sessionRequest setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [sessionRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [sessionRequest setHTTPShouldHandleCookies:YES];        
        [sessionRequest setTimeoutInterval:10.0];
        
        NSDictionary *headers = [[NSDictionary alloc] init ];
        headers = [sessionRequest allHTTPHeaderFields];
        
        for(NSString *key in [headers allKeys]) {
            NSLog(@"%@",[headers objectForKey:key]);
        }
        
        NSLog([NSString stringWithFormat:@"%@", [sessionRequest HTTPBody]]);
         
        // NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        receivedData = [NSMutableData data];
        
        AFXMLRequestOperation *sessionCall = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:sessionRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
            XMLParser.delegate = self;
            [XMLParser parse];
        } failure:nil];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:sessionCall];
        //
        
        NSBlockOperation *loginBlockOperation = 
        [NSBlockOperation blockOperationWithBlock:^{
            NSMutableURLRequest *loginRequest = [[NSMutableURLRequest alloc] 
                                                 initWithURL:[NSURL URLWithString:@"http://www.karmapoints.org/rest/user/login"]];
            NSMutableData *loginBody = [NSMutableData data];
            NSLog(@"sessid is%@",self.sessid);
            
            NSLog(@"username is%@", username.text);
            
            NSLog(@"password is%@", password.text);
            [loginBody setData:[[NSString stringWithFormat:@"sessid=%@&username=%@&password=%@", 
                                 self.sessid,
                                 username.text, 
                                 password.text] dataUsingEncoding:NSUTF8StringEncoding]];
            [loginRequest setHTTPBody:loginBody];        
            [loginRequest setHTTPMethod:@"POST"];
            [loginRequest setValue:[NSString stringWithFormat:@"%d",[loginBody length] ] forHTTPHeaderField:@"Content-Length"];
            [loginRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [loginRequest setHTTPShouldHandleCookies:YES];        
            [loginRequest setTimeoutInterval:10.0];
            /*
            AFHTTPRequestOperation *loginCall = [[AFHTTPRequestOperation alloc] initWithRequest:loginRequest];
            loginCall.completionBlock = ^ {
                if ([loginCall hasAcceptableStatusCode]) {
                    NSLog(@"Friend Request Sent");
                } else {
                    NSLog(@"[Error]: (%@ %@) %@", [loginCall.request HTTPMethod], [[loginCall.request URL] relativePath], loginCall.error);
                }
            };
            [queue addOperation: loginCall];
            */
            
            NSDictionary *headers = [[NSDictionary alloc] init ];
            headers = [loginRequest allHTTPHeaderFields];
            
            for(NSString *key in [headers allKeys]) {
                NSLog(@"%@ %@",key,[headers objectForKey:key]);
            }
            
            NSLog([NSString stringWithFormat:@"%@", [loginRequest HTTPBody]]);
        
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *urlData = [NSURLConnection sendSynchronousRequest:loginRequest returningResponse:&response error:&error];
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:urlData];
            parser.delegate = self;
            [parser parse];
        }];
        
        [loginBlockOperation addDependency:sessionCall];
        [queue addOperation:loginBlockOperation];

        //
    }
}

- (IBAction) logoutButtonTapped
{
    NSLog(@"Sad to see you go!");
    NSMutableURLRequest *logoutRequest = [[NSMutableURLRequest alloc]
                                         initWithURL:[NSURL URLWithString:@"http://www.karmapoints.org/logout"]];
    [logoutRequest setHTTPMethod:@"GET"];
    [logoutRequest setHTTPShouldHandleCookies:YES];        
    [logoutRequest setTimeoutInterval:10.0];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:logoutRequest returningResponse:&response error:&error];
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
    parser.delegate = self;
    _Bool *result = parser.parse;
    
    // release the connection, and the data object
    connection = nil;
    receivedData = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - NXSMLParserDelegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    [currentParsedCharacterData setString:@""];
    currentElement = elementName;
    NSLog(@"found element %@",currentElement);
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [currentParsedCharacterData setString:@""];
    currentElement = elementName;
    NSLog(@"***END OF element %@",currentElement);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([currentElement isEqualToString:@"sessid"]) {
        if ([currentElement isEqualToString:@"sessid"]) {
            self.sessid = [NSString stringWithString:string];
            NSString *logLeader = @"Just set session id to ";
            NSString *logMessage  = [logLeader stringByAppendingString:self.sessid];
            logMessage  = [logMessage stringByAppendingString:@"\n"];
            NSLog(@"%@",logMessage);
            NSString *oldMessage = self.webResponse.text;
            NSString *newMessage = [oldMessage stringByAppendingString:logMessage];
            [webResponse performSelectorOnMainThread:@selector(setText:) withObject:newMessage waitUntilDone:YES];
        }
    }
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

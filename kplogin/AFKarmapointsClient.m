//
//  AFKarmapointsClient.m
//  kplogin
//
//  Created by TODD RIMES on 12/9/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import "AFKarmapointsClient.h"
#import "AFXMLRequestOperation.h"

@implementation AFKarmapointsClient

@synthesize currentElement, result, sessid, userid, currentParsedCharacterData, eventArray, currentEvent;

-(id)init {
    buildingEvent = false;
    gettingEvents = false;
    currentParsedCharacterData = [[NSMutableString alloc] init];
    sessid = [[NSString alloc] init];
    sessid = @"";
    userid = [[NSString alloc] init];
    userid = @"";
    eventArray = [[NSMutableArray alloc] init];
    return [super initWithBaseURL:[NSURL URLWithString:@"http://www.karmapoints.org"]];
}

-(NSNumber *) loginWithUser:(NSString *)user pass:(NSString *)pass
{
    NSMutableURLRequest *sessionRequest = [self requestWithMethod:@"POST" path:@"/rest/system/connect" parameters:nil];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"name=%@&pass=%@", user, pass] dataUsingEncoding:NSUTF8StringEncoding]];
    [sessionRequest setHTTPBody:body];
    [sessionRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [sessionRequest setHTTPShouldHandleCookies:YES];        
    [sessionRequest setTimeoutInterval:10.0];
    
    NSDictionary *headers = [[NSDictionary alloc] init ];
    headers = [sessionRequest allHTTPHeaderFields];
    
    for(NSString *key in [headers allKeys]) {
        NSLog(@"%@",[headers objectForKey:key]);
    }
        
    // NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    AFXMLRequestOperation *sessionOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:sessionRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        XMLParser.delegate = (id)self;
        [XMLParser parse];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
        NSLog(@"Didn't get a session id.   Bummer.");
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:sessionOperation];
    //
    
    NSBlockOperation *loginBlockOperation = 
    [NSBlockOperation blockOperationWithBlock:^{
        NSMutableURLRequest *loginRequest = [[NSMutableURLRequest alloc] 
                                             initWithURL:[NSURL URLWithString:@"http://www.karmapoints.org/rest/user/login"]];
        NSMutableData *loginBody = [NSMutableData data];
        NSLog(@"sessid is%@",self.sessid);
        
        NSLog(@"username is%@", user);
        
        NSLog(@"password is%@", pass);
        [loginBody setData:[[NSString stringWithFormat:@"sessid=%@&username=%@&password=%@", 
                             self.sessid,
                             user, 
                             pass] dataUsingEncoding:NSUTF8StringEncoding]];
        [loginRequest setHTTPBody:loginBody];        
        [loginRequest setHTTPMethod:@"POST"];
        [loginRequest setValue:[NSString stringWithFormat:@"%d",[loginBody length] ] forHTTPHeaderField:@"Content-Length"];
        [loginRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [loginRequest setHTTPShouldHandleCookies:YES];        
        [loginRequest setTimeoutInterval:10.0];
        
        NSDictionary *headers = [[NSDictionary alloc] init ];
        headers = [loginRequest allHTTPHeaderFields];
        
        for(NSString *key in [headers allKeys]) {
            NSLog(@"%@ %@",key,[headers objectForKey:key]);
        }
        
        NSLog(@"%@", [loginRequest HTTPBody]);
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *urlData = [NSURLConnection sendSynchronousRequest:loginRequest returningResponse:&response error:&error];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:urlData];
        parser.delegate = (id)self;
        [parser parse];
    }];
    
    [loginBlockOperation addDependency:sessionOperation];
    [queue addOperation:loginBlockOperation];

    [queue waitUntilAllOperationsAreFinished];    
    if (self.userid!=@"" && [self.userid intValue]!=0) {
        return [[NSNumber alloc] initWithInteger:[self.userid integerValue]];
    } else {
        return [[NSNumber alloc] initWithInt:0];
    }
}
     
-(void) logout
{
    [self getPath:@"/logout" parameters:nil success:nil failure:nil];
    NSLog(@"Logged out");
}

-(NSMutableArray *) getCoordinatorEvents {
    NSMutableURLRequest *eventRequest = [self requestWithMethod:@"GET" path:@"/rest/views/view_mobile_coordinator_events" parameters:nil];

    AFXMLRequestOperation *eventOperation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:eventRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        XMLParser.delegate = (id)self;
        if ([self.userid intValue]>0) {
         [XMLParser parse];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParse) {
        NSLog(@"Didn't get a session id.   Bummer.");
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:eventOperation];
    [queue waitUntilAllOperationsAreFinished];
    return self.eventArray;
}

#pragma mark - NXSMLParserDelegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    self.currentParsedCharacterData = [NSMutableString stringWithString:@""];
    self.currentElement = elementName;
    if(gettingEvents && [elementName isEqualToString:@"item"]) {
        buildingEvent = true;
        self.currentEvent = [[KPEvent alloc] init];
    }
    NSLog(@"***START element %@",self.currentElement);
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (gettingEvents) {
        if(buildingEvent) {
            if([elementName isEqualToString:@"nid"]){
                self.currentEvent.nid = self.currentParsedCharacterData;
            }
            
            if([elementName isEqualToString:@"node_data_field_start_datetime_field_start_datetime_value"]){
                self.currentEvent.startDateTime = [self.currentParsedCharacterData substringToIndex:10];
            }
            
            if([elementName isEqualToString:@"node_title"]){
                self.currentEvent.title = self.currentParsedCharacterData;
            }
            
            if([elementName isEqualToString:@"item"]){
                [self.eventArray addObject:self.currentEvent];
                buildingEvent = false;
            }
        }   
    }
    NSLog(@"END OF element %@***",elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentParsedCharacterData appendString:string];
    if ([self.currentElement isEqualToString:@"sessid"]) {
        self.sessid = [NSString stringWithString:string];
        NSString *logLeader = @"Just set session id to ";
        NSString *logMessage  = [logLeader stringByAppendingString:self.sessid];
        logMessage  = [logMessage stringByAppendingString:@"\n"];
        NSLog(@"%@",logMessage);
    }
    
    if ([currentElement isEqualToString:@"uid"]) {
        self.userid = [NSString stringWithString:string];
        NSString *logLeader = @"Just set userid to ";
        NSString *logMessage  = [logLeader stringByAppendingString:self.userid];
        logMessage  = [logMessage stringByAppendingString:@"\n"];
        NSLog(@"%@",logMessage);
    }
}

@end

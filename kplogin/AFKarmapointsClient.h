//
//  AFKarmapointsClient.h
//  kplogin
//
//  Created by TODD RIMES on 12/9/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "KPEvent.h"

@interface AFKarmapointsClient : AFHTTPClient
{
    NSString *sessid;
    NSString *userid;
    NSMutableArray  *eventArray;
    NSMutableString *currentParsedCharacterData;
    KPEvent *currentEvent;
    
    bool buildingEvent;
    bool gettingEvents;
}

@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *sessid;
@property (nonatomic, retain) NSString *userid;
@property (nonatomic, retain) NSMutableArray  *eventArray;
@property (nonatomic, retain) KPEvent  *currentEvent;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

-(NSNumber *) loginWithUser:(NSString *)user pass:(NSString *)pass;
-(NSArray  *) getCoordinatorEvents;
-(void) logout;

@end

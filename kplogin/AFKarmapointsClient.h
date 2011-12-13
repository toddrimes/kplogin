//
//  AFKarmapointsClient.h
//  kplogin
//
//  Created by TODD RIMES on 12/9/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface AFKarmapointsClient : AFHTTPClient
{
    NSString *sessid;
    NSString *userid;
    NSMutableString *currentParsedCharacterData;
}

@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSString *result;
@property (nonatomic, retain) NSString *sessid;
@property (nonatomic, retain) NSString *userid;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;


-(NSString *) loginWithUser:(NSString *)user pass:(NSString *)pass;
-(void) logout;

@end

//
//  KPEvent.h
//  kplogin
//
//  Created by TODD RIMES on 12/13/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPEvent : NSObject
{
    NSString *startDateTime;
    NSString *title;
    NSString *nid;
}
@property (nonatomic, retain) NSString *startDateTime;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *nid;

@end
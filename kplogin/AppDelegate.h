//
//  AppDelegate.h
//  kplogin
//
//  Created by TODD RIMES on 12/6/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString *eventTitle;
}

@property (nonatomic, retain) NSString *eventTitle;
@property (strong, nonatomic) UIWindow *window;

@end

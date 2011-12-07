//
//  ViewController.h
//  kplogin
//
//  Created by TODD RIMES on 12/6/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"

@interface ViewController : UIViewController
{
    UITextField *username;
    UITextField *password;
    UITextView *webResponse;
}
@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextView *webResponse;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) AFHTTPClient *kpClient;
- (IBAction) loginButtonTapped;

@end

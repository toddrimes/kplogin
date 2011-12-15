//
//  ViewController.h
//  kplogin
//
//  Created by TODD RIMES on 12/6/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "KPEvent.h"

@interface SessionViewController : UIViewController <NSXMLParserDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>
{
    UITextField *username;
    UITextField *password;
    UIPickerView *eventPicker;
    NSString *sessid;
    NSString *currentElement;
    NSMutableArray *eventArray;
    KPEvent *pickedEvent;
    CGRect *pickerRect;
    KPEvent *currentEvent;
    
@private
    NSMutableString *currentParsedCharacterData;
}

@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIPickerView *eventPicker;
@property (nonatomic, retain) NSString *sessid;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *eventArray;
@property (nonatomic, retain) KPEvent *pickedEvent;

@property (nonatomic, retain) KPEvent *currentEvent;

-(IBAction) loginButtonTapped;
-(IBAction) logoutButtonTapped;
-(IBAction) eventRowPicked;
-(void) showEventSelector;
-(IBAction)textFieldReturn:(id)sender;

@end

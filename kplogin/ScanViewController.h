//
//  ViewController.h
//  kpreader
//
//  Created by TODD RIMES on 12/2/11.
//  Copyright (c) 2011 Rimes Media. All rights reserved.
//

#import <UIKit/UIKit.h>
// ADD: import barcode reader APIs
#import "ZBarSDK.h"

@interface ScanViewController : UIViewController <ZBarReaderDelegate>
{
    UIImageView *resultImage;
    UIWebView *resultText;
    UILabel *eventTitle;
}
@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UIWebView *resultText;
@property (nonatomic, retain) IBOutlet UILabel *eventTitle;
- (IBAction) scanButtonTapped;
@end

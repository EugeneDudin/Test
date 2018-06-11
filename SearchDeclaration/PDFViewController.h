//
//  PDFViewController.h
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFViewController : UIViewController<UIWebViewDelegate> {
    UIActivityIndicatorView *activityIndicatorView;
}

@property NSString *titleName;
@property NSString *pdfURL;
@property (weak, nonatomic) IBOutlet UIWebView *webViewNew;

@end

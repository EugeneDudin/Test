//
//  PDFViewController.m
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "PDFViewController.h"

@interface PDFViewController ()

@end

@implementation PDFViewController

@synthesize pdfURL, titleName, webViewNew;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    webViewNew.delegate = self;
    [self.navigationController setNavigationBarHidden: NO];
    [self.navigationController.navigationBar.topItem setTitle: titleName];
    [self setupWebViewWhithURL: pdfURL];
    [self setupActivitiIndicator];
}

-(void)setupWebViewWhithURL:(NSString *) url {
    [webViewNew loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)setupActivitiIndicator{
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    activityIndicatorView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    activityIndicatorView.center = self.view.center;
    
    [self.view addSubview: activityIndicatorView];
    [activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicatorView stopAnimating];
    [activityIndicatorView hidesWhenStopped];
}

@end

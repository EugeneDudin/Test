//
//  TableViewCell.m
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "TableViewCell.h"
#import "PDFViewController.h"

@interface TableViewCell ()

@end

@implementation TableViewCell

@synthesize delegate;
@synthesize pdfURL;
@synthesize dID;
@synthesize comment;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)showPDF:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PDFViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"pdf"];
    controller.titleName = [_fullName text];
    controller.pdfURL = pdfURL;
    
    [self.delegate loadPDFScreen:controller];
}

- (IBAction)addToFavorite:(id)sender {
    [_favorite setImage:[UIImage imageNamed:@"icons8-star-filled-50.png"] forState:UIControlStateNormal];
    [_favorite setEnabled:NO];
    [self.delegate addToFavorite:[_fullName text] position:[_positionWork text] placeOfWork:[_placeOfWork text] linkPDF:pdfURL dID:dID];
}

@end

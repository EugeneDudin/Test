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

@synthesize pdfURL;
@synthesize delegate;
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [_save setHidden:YES];
    [_save setEnabled:YES];
    [_commentTF endEditing:YES];
    [_commentTF setHidden:YES];
    [comment setHidden:NO];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length <= 0) {
        [_save setEnabled:NO];
    } else {
        [_save setEnabled:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_commentTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_commentTF endEditing:YES];
    return YES;
}

- (IBAction)addToFavorite:(id)sender {
    [_save setHidden:NO];
    [_save setEnabled:NO];
    _commentTF.delegate = self;
    [_favorite setImage:[UIImage imageNamed:@"icons8-star-filled-50.png"] forState:UIControlStateNormal];
    [_commentTF setHidden:NO];
    [_commentTF becomeFirstResponder];
    
}

- (void)updateComment {
    [_save setHidden:NO];
    _commentTF.delegate = self;
    
    [_commentTF setHidden:NO];
    [_commentTF becomeFirstResponder];
    _commentTF.text = comment.text;
    [comment setHidden:YES];
}

- (IBAction)save:(id)sender {
    if (_commentTF.text.length > 0) {
        
        [_commentTF endEditing:YES];
        [_commentTF setHidden:YES];
        [comment setHidden:NO];
        comment.text = _commentTF.text;
        if (comment.text.length != 0) {
            // UPDATE
            [self.delegate updateComment:_commentTF.text];
        } else {
            // ADD
            NSLog(@"ADD");
            [self.delegate addToFavorite:[_fullName text] position:[_positionWork text] placeOfWork:[_placeOfWork text] linkPDF:pdfURL comment:_commentTF.text];
        }
        [_save setHidden:YES];
    } else {
        [_save setEnabled:NO];
    }
}

@end

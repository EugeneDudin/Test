//
//  TableViewCell.h
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cellActionProtocol <NSObject>
-(void)loadPDFScreen:(UIViewController *)controller;
-(void)updateComment:(NSString *)comment;
-(void)addToFavorite:(NSString *)fullName position:(NSString *)position placeOfWork:(NSString *)placeOfWork linkPDF:(NSString *)linkPDF comment:(NSString *)comment;
@end

@interface TableViewCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *favorite;
@property (nonatomic, retain) id<cellActionProtocol> delegate;
@property NSString *pdfURL;

@property (weak, nonatomic) IBOutlet UITextField *commentTF;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *placeOfWork;
@property (weak, nonatomic) IBOutlet UILabel *positionWork;
@property (weak, nonatomic) IBOutlet UIButton *pdfButton;
@property (weak, nonatomic) IBOutlet UIButton *save;

- (void)updateComment;
- (IBAction)showPDF:(id)sender;
- (IBAction)addToFavorite:(id)sender;
- (IBAction)save:(id)sender;


@end

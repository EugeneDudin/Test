//
//  TableViewCell.h
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellActionDelegate <NSObject>
-(void)loadPDFScreen:(UIViewController *)controller;
-(void)addToFavorite:(NSString *)fullName position:(NSString *)position placeOfWork:(NSString *)placeOfWork linkPDF:(NSString *)linkPDF personID:(NSString *)personID;
-(void)removeFromFavoriteByID:(NSString *)personID name:(NSString *)name;
@end

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *favorite;
@property (nonatomic, weak) id<CellActionDelegate> delegate;

@property NSString *pdfURL;
@property NSString *personID;
@property BOOL isFavorite;

@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *placeOfWork;
@property (weak, nonatomic) IBOutlet UILabel *positionWork;
@property (weak, nonatomic) IBOutlet UIButton *pdfButton;


- (IBAction)showPDF:(id)sender;
- (IBAction)addToFavorite:(id)sender;


@end

//
//  FavoriteTableViewController.m
//  SearchDeclaration
//
//  Created by Jenya on 10.06.18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "FavoriteTableViewController.h"
#import "AppDelegate.h"
#import "TableViewCell.h"
#import "ManagedCoreData.h"
#import "Alert.h"

@interface FavoriteTableViewController ()<UITextFieldDelegate, CellActionDelegate>

@end

@implementation FavoriteTableViewController

@synthesize commentTF, editCellIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    _managedCoreData = [[ManagedCoreData alloc] init];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar.topItem setTitle: @"Favorite"];

    self.favoriteDB = [_managedCoreData getData];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoriteDB.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSManagedObject *favorite = [_favoriteDB objectAtIndex:indexPath.row];

    if ([[favorite valueForKey:@"linkPDF"] isEqual:@"-"]) {
        [cell.pdfButton setEnabled:NO];
    } else {
        cell.pdfURL = [favorite valueForKey:@"linkPDF"];
    }
    cell.fullName.text = [favorite valueForKey:@"fullName"];
    cell.placeOfWork.text = [favorite valueForKey:@"placeOfWork"];
    cell.positionWork.text = [favorite valueForKey:@"position"];
    cell.comment.text = [favorite valueForKey:@"comment"];
    
    cell.delegate = self;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (![_managedCoreData deleteDataForIndex:indexPath.row]) {
                [Alert showAlertMessage:@"не вдалося" title:@"Помилка"];
        }
        [commentTF removeFromSuperview];
        [self.favoriteDB removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [commentTF removeFromSuperview];
    editCellIndexPath = indexPath;
    TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    commentTF = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    commentTF.text = cell.comment.text;
    [commentTF setReturnKeyType:UIReturnKeyDone];
    [commentTF setBorderStyle:UITextBorderStyleNone];
    commentTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    commentTF.leftView = paddingView;
    
    commentTF.placeholder = @"Додати коментар";
    commentTF.backgroundColor = [UIColor whiteColor];
    commentTF.layer.cornerRadius = 15.0;
    commentTF.layer.borderWidth = 2.0;
    commentTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    commentTF.layer.masksToBounds = YES;
    [commentTF becomeFirstResponder];
    
    commentTF.delegate = self;
    
    [self.view addSubview:commentTF];
}

-(void)loadPDFScreen:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    TableViewCell *cell = [self.tableView cellForRowAtIndexPath:editCellIndexPath];
    cell.comment.text = commentTF.text;
    [commentTF removeFromSuperview];
    
    ManagedCoreData *managedCoreData = [[ManagedCoreData alloc] init];
    [managedCoreData updateDataAtIndex:editCellIndexPath.row newValue:cell.comment.text forKey:@"comment"];
    
    return YES;
}

-(void)updateComment:(NSString *)comment {
    if (![_managedCoreData updateDataAtIndex:[[self.tableView indexPathForSelectedRow] row] newValue:comment forKey:@"comment"]) {
        [Alert showAlertMessage:@"Оновлення не вдалося" title:@"Помилка"];
    }
}

@end

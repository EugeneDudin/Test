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
#import "Person.h"

@interface FavoriteTableViewController ()<UITextFieldDelegate, CellActionDelegate, AlertDelegate>

@end

@implementation FavoriteTableViewController

@synthesize editCellIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    _managedCoreData = [[ManagedCoreData alloc] init];
    _alert = [Alert new];
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
            [self presentViewController:[_alert showAlertMessage:@"Hе вдалося" title:@"Помилка"] animated:YES completion:nil];
        }
        [self.favoriteDB removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _alert.delegate = self;
    editCellIndexPath = indexPath;
    TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    Person *person = [[Person alloc] initPersonFullName:cell.fullName.text position:cell.positionWork.text placeOfWork:cell.placeOfWork.text linkPDF:cell.pdfURL personID:cell.personID];
    [self presentViewController:[_alert showAlertComment:person message:cell.fullName.text title:@"Pедагувати" comment:cell.comment.text] animated:YES completion:nil];
}

-(void)loadPDFScreen:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)savePerson:(Person *)person {
    TableViewCell *cell = [self.tableView cellForRowAtIndexPath:editCellIndexPath];
    cell.comment.text = person.comment;
    ManagedCoreData *managedCoreData = [[ManagedCoreData alloc] init];
    if (![managedCoreData updateDataAtIndex:editCellIndexPath.row newValue:cell.comment.text forKey:@"comment"]) {
        [self presentViewController:[_alert showAlertMessage:@"не вдалося" title:@"Помилка"] animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

-(void)updateComment:(NSString *)comment {
    if (![_managedCoreData updateDataAtIndex:[[self.tableView indexPathForSelectedRow] row] newValue:comment forKey:@"comment"]) {
        [self presentViewController:[_alert showAlertMessage:@"Оновлення не вдалося" title:@"Помилка"] animated:YES completion:nil];
    }
}

@end

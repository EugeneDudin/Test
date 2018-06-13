//
//  FindTableViewController.m
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "FindTableViewController.h"
#import "TableViewCell.h"
#import "WebService.h"
#import "ManagedCoreData.h"
#import "Alert.h"

@interface FindTableViewController ()<CellActionDelegate> {
    NSMutableDictionary *saveArray;
    NSMutableArray *name;
    NSMutableArray *linkPDF;
    NSMutableArray *placeOfWork;
    NSMutableArray *position;
    NSMutableArray *dID;
    bool isText;
    int totalItems;
    int page;
}
@end

@implementation FindTableViewController

@synthesize activityIndicatorView, commentTF;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar.delegate = self;
    _searchBar.frame = CGRectMake(0, 40, 200, 50);
    isText = false;
    page = 1;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar.topItem setTitle: @"Search"];
    [self.tableView reloadData];
    _managedCoreData = [[ManagedCoreData alloc] init];
    self.favoriteDB = [_managedCoreData getData];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        isText = true;
    } else {
        isText = false;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [name removeAllObjects];
    [linkPDF removeAllObjects];
    [position removeAllObjects];
    [placeOfWork removeAllObjects];
    [self.tableView reloadData];
    if (isText) {
        page = 1;
        totalItems = 0;
        [self getJSONData: searchBar.text];
        [self.view endEditing:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return name.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.dID = [dID objectAtIndex:indexPath.row];
    
    [cell.favorite setEnabled:YES];
    [cell.favorite setImage:[UIImage imageNamed:@"icons8-star-50.png"] forState:UIControlStateNormal];
    for (NSString * coreID in [_favoriteDB valueForKey:@"id"]) {
        if ([coreID isEqualToString:[dID objectAtIndex:indexPath.row]]) {
            [cell.favorite setImage:[UIImage imageNamed:@"icons8-star-filled-50.png"] forState:UIControlStateNormal];
            [cell.favorite setEnabled:NO];
        }
    }
    
    if ([[linkPDF objectAtIndex:indexPath.row] isEqual:@"-"]) {
        [cell.pdfButton setEnabled:NO];
    } else {
        cell.pdfURL = [linkPDF objectAtIndex: indexPath.row];
    }
    
    cell.fullName.text = [name objectAtIndex:indexPath.row];
    cell.placeOfWork.text = [position objectAtIndex:indexPath.row];
    cell.positionWork.text = [placeOfWork objectAtIndex:indexPath.row];;
    
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        if (totalItems != name.count) {
            page += 1;
            [self getJSONData:_searchBar.text];
        }
    }
}

-(void)reloadTableView {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)loadPDFScreen:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)addToFavorite:(NSString *)fullName position:(NSString *)position placeOfWork:(NSString *)placeOfWork linkPDF:(NSString *)linkPDF dID:(NSString *)dID {
    [self.tableView setUserInteractionEnabled:NO];
    
    saveArray = [[NSMutableDictionary alloc]init];
    [saveArray setValue:fullName forKey:@"fullName"];
    [saveArray setValue:position forKey:@"position"];
    [saveArray setValue:placeOfWork forKey:@"placeOfWork"];
    [saveArray setValue:linkPDF forKey:@"linkPDF"];
    [saveArray setValue:dID forKey:@"id"];
    
    commentTF = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [commentTF removeFromSuperview];
    [saveArray setValue:textField.text forKey:@"comment"];
    [commentTF endEditing:YES];
    ManagedCoreData *managedCoreData = [[ManagedCoreData alloc] init];
    if(![managedCoreData addData:saveArray]) {
        [Alert showAlertMessage:@"Додати не вдалося" title:@"Помилка"];
    }
    [self.tableView setUserInteractionEnabled:YES];
    return YES;
}

- (void)getJSONData:(NSString *)premeter {
    [self startActivityIndicator];
    [WebService executeQuery:@"https://public-api.nazk.gov.ua/v1/declaration/?q=" premeter:[NSString stringWithFormat:@"%@", premeter] page:page withblock:^(NSData *data, NSError *error) {
        if (error == nil) {
            [self parseJSON:data];
        } else {
            [self presentViewController:[Alert showAlertMessage:error.localizedDescription title:@"Помилка"] animated:YES completion:nil];
        }
        [self reloadTableView];
        [self stopActivityIndicator];
    }];
}

-(void)parseJSON:(NSData *) jsonData {
    NSError *jsonError;
    NSDictionary *parsedJSONArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    
    if (parsedJSONArray.count > 0) {
        NSString *error =  [parsedJSONArray objectForKey:@"error"];
        NSString *message = [parsedJSONArray objectForKey:@"message"];
        
        if (!totalItems) {
            NSDictionary *item = [parsedJSONArray objectForKey:@"page"];
            totalItems = [[item objectForKey:@"totalItems"] intValue];
        }
        if (error) {
            if (!name || name.count == 0 || name.count !=  totalItems) {
                [self presentViewController:[Alert showAlertMessage:message title:@"Помилка"] animated:YES completion:nil];
            }
            [self stopActivityIndicator];
            return;
        }
        
        NSDictionary *dict1 = [parsedJSONArray objectForKey:@"items"];
        
        if (dict1 == nil && name.count == totalItems) {
            return;
        } else if (dict1 == nil) {
            [self presentViewController:[Alert showAlertMessage:@"" title:@"Помилка"] animated:YES completion:nil];
        } else {
            if (page == 1) {
                self->name = [NSMutableArray new];
                self->linkPDF = [NSMutableArray new];
                self->placeOfWork = [NSMutableArray new];
                self->position = [NSMutableArray new];
                self->dID = [NSMutableArray new];
            }
            for (NSDictionary * dict in dict1) {
                NSString *name = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"lastname"], [dict objectForKey:@"firstname"]];
                NSString *linkPDF = [dict objectForKey:@"linkPDF"];
                NSString *placeOfWork = [dict objectForKey:@"placeOfWork"];
                NSString *position = [dict objectForKey:@"position"];
                NSString *ID = [dict objectForKey:@"id"];
                
                [self->dID addObject:ID];
                [self->name addObject: name ];
                [self->placeOfWork addObject: placeOfWork];
                
                if (linkPDF == nil) {
                    [self->linkPDF addObject: @"-"];
                } else {
                    [self->linkPDF addObject: linkPDF];
                }
                
                if (position == nil) {
                    [self->position addObject: @"нi"];
                } else {
                    [self->position addObject: position];
                }
            }
        }
        
    }
}

-(void)startActivityIndicator {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = CGPointMake( [UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    [self.activityIndicatorView startAnimating];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview: activityIndicatorView];
}

- (void)stopActivityIndicator {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [activityIndicatorView stopAnimating];
    });
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}



@end





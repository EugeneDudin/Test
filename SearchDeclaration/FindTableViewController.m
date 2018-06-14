//
//  FindTableViewController.m
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "FindTableViewController.h"
#import "TableViewCell.h"
#import "Person.h"
#import "WebService.h"
#import "ManagedCoreData.h"


@interface FindTableViewController ()<CellActionDelegate> {
    Person *personToSave;
    NSMutableArray *persons;
    bool isText;
    int totalItems;
    int page;
}
@end

@implementation FindTableViewController

@synthesize activityIndicatorView, commentTF;

- (void)viewDidLoad {
    [super viewDidLoad];
    _alert = [[Alert new] init];
    
    _searchBar.delegate = self;
    _searchBar.frame = CGRectMake(0, 40, 200, 50);
    isText = false;
    page = 1;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)viewWillAppear:(BOOL)animated {
    persons = [[NSMutableArray alloc] init];
    [self.navigationController.navigationBar.topItem setTitle: @"Search"];
    
    _managedCoreData = [[ManagedCoreData alloc] init];
    _favoriteID = [[NSMutableArray alloc] init];
    [_favoriteID removeAllObjects];
    
    NSMutableArray *favoriteArray = [[NSMutableArray alloc] init];
    favoriteArray = [_managedCoreData getData];
    for (NSString *favorites in [favoriteArray valueForKey:@"id"]) {
        [_favoriteID addObject:favorites];
        
    }
    
    [self refresh];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        isText = true;
    } else {
        isText = false;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (isText) {
        page = 1;
        totalItems = 0;
        [self refresh];
        [self.view endEditing:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Person *person = [[Person alloc] init];
    if (persons.count >= indexPath.row) {
        person = [persons objectAtIndex:indexPath.row];
    } else {
        return cell;
    }
    cell.personID = person.personID;
    cell.isFavorite = person.isFavorite;
    
    if (person.isFavorite) {
        [cell.favorite setImage:[UIImage imageNamed:@"icons8-star-filled-50.png"] forState:UIControlStateNormal];
    } else {
        [cell.favorite setImage:[UIImage imageNamed:@"icons8-star-50.png"] forState:UIControlStateNormal];
    }
    
    if ([person.linkPDF isEqual:@"-"]) {
        [cell.pdfButton setEnabled:NO];
    } else {
        cell.pdfURL = person.linkPDF;
    }
    
    cell.fullName.text = person.fullName;
    cell.placeOfWork.text = person.placeOfWork;
    cell.positionWork.text = person.positionWork;
    
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        if (totalItems != persons.count) {
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

-(void)addToFavorite:(NSString *)fullName position:(NSString *)position placeOfWork:(NSString *)placeOfWork linkPDF:(NSString *)linkPDF personID:(NSString *)personID {
    personToSave = [[Person alloc] initPersonFullName:fullName position:position placeOfWork:placeOfWork linkPDF:linkPDF  personID:personID];
    
    [self presentViewController:[_alert showAlertComment:personToSave message:fullName title:@"Додати" comment:@""] animated:YES completion:nil];
    _alert.delegate = self;
}

-(void)removeFromFavoriteByID:(NSString *)personID name:(NSString *)name {
    [self presentViewController:[_alert showAlertDelete:personID message:name title:@"Bидалити"] animated:YES completion:nil];
    _alert.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (void)getJSONData:(NSString *)premeter {
    [self startActivityIndicator];
    [WebService executeQuery:@"https://public-api.nazk.gov.ua/v1/declaration/?q=" premeter:[NSString stringWithFormat:@"%@", premeter] page:page withblock:^(NSData *data, NSError *error) {
        if (error == nil) {
            [self parseJSON:data];
        } else {
            [self presentViewController:[_alert showAlertMessage:error.localizedDescription title:@"Помилка"] animated:YES completion:nil];
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
            if (!persons || persons.count == 0 || persons.count !=  totalItems) {
                [self presentViewController:[_alert showAlertMessage:message title:@"Помилка"] animated:YES completion:nil];
            }
            [self stopActivityIndicator];
            return;
        }
        
        NSDictionary *dict1 = [parsedJSONArray objectForKey:@"items"];
        
        if (dict1 == nil && persons.count == totalItems) {
            return;
        } else if (dict1 == nil) {
            [self presentViewController:[_alert showAlertMessage:@"" title:@"Помилка"] animated:YES completion:nil];
        } else {
            for (NSDictionary * dict in dict1) {
                Person *person = [[Person alloc] initPersonFullName:[NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"lastname"], [dict objectForKey:@"firstname"]]
                                                           position:[dict objectForKey:@"position"] placeOfWork:[dict objectForKey:@"placeOfWork"]
                                                            linkPDF:[dict objectForKey:@"linkPDF"] personID:[dict objectForKey:@"id"]];
                [persons addObject:person];
                
                for (NSString *coreID in _favoriteID) {
                    if ([coreID isEqualToString:person.personID]) {
                        [person setFavorite:YES];
                    }
                }
            }
        }
    } else {
        [self presentViewController:[_alert showAlertRefresh:@"Спробувати ще раз?" title:@"Помилка! Забагато запитів"] animated:YES completion:nil];
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
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        UIView *subViewArray = appDelegate.window;
        for (id obj in subViewArray.subviews)
        {
            if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
                [obj removeFromSuperview];
            }
        }
    });
}

- (void)savePerson:(Person *)person {
    [personToSave setComment:person.comment];
    ManagedCoreData *managedCoreData = [[ManagedCoreData alloc] init];
    if(![managedCoreData addData:[personToSave getPersonDictionary]]) {
        [self presentViewController:[_alert showAlertMessage:@"Hе вдалося" title:@"Помилка"] animated:YES completion:nil];
    }
    [_favoriteID addObject:personToSave.personID];
    
    for (int i = 0; i <= persons.count-1; i++) {
        if ([[[persons objectAtIndex:i] personID] isEqualToString:personToSave.personID]) {
            [[persons objectAtIndex:i] setIsFavorite:YES];
        }
    }
    [self refresh];
}

- (void)deletePersonByID:(NSString *)personID {
    if (![_managedCoreData removeDataByID:personID]) {
        [self presentViewController:[_alert showAlertMessage:@"Hе вдалося" title:@"Помилка"] animated:YES completion:nil];
    }
    if ([_favoriteID containsObject:personID]) {
        [persons removeAllObjects];
        [_favoriteID removeObject:personID];
        [self getJSONData:_searchBar.text];
    }
}

- (void)refresh {
    if (_searchBar.text.length > 0) {
        [persons removeAllObjects];
        [self getJSONData:_searchBar.text];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [_searchBar endEditing:YES];
    
}


@end





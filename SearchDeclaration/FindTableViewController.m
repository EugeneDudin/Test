//
//  FindTableViewController.m
//  FindDec
//
//  Created by Jenya on 10/8/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "FindTableViewController.h"
#import "TableViewCell.h"

@interface FindTableViewController () {
    NSMutableArray *name;
    NSMutableArray *linkPDF;
    NSMutableArray *placeOfWork;
    NSMutableArray *position;
    bool isText;
}

@end

@implementation NSString (URLEncoding)
- (nullable NSString *)stringByAddingPercentEncodingForRFC3986 {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [self
            stringByAddingPercentEncodingWithAllowedCharacters:
            allowed];
}
@end

@implementation FindTableViewController
@synthesize favoritbd, activityIndicatorView;

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar.delegate = self;
    isText = false;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // [self.view endEditing:NO];
    // [_searchBar becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar.topItem setTitle: @"Search"];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return name.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    if ([[linkPDF objectAtIndex:indexPath.row] isEqual:@"-"]) {
        [cell.pdfButton setEnabled:NO];
    } else {
        cell.pdfURL = [linkPDF objectAtIndex: indexPath.row];
    }
    cell.fullName.text = [name objectAtIndex:indexPath.row];
    cell.placeOfWork.text = [position objectAtIndex:indexPath.row];
    cell.positionWork.text = [placeOfWork objectAtIndex:indexPath.row];;
    
    return cell;
}

-(void)loadPDFScreen:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)addToFavorite:(NSString *)fullName position:(NSString *)position placeOfWork:(NSString *)placeOfWork linkPDF:(NSString *)linkPDF comment:(NSString *)comment {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *addToFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:context];
    
    [addToFavorite setValue:fullName forKey:@"fullName"];
    [addToFavorite setValue:placeOfWork forKey:@"placeOfWork"];
    [addToFavorite setValue:linkPDF forKey:@"linkPDF"];
    [addToFavorite setValue:position forKey:@"position"];
    [addToFavorite setValue:comment forKey:@"comment"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
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
    
    if (isText) {
        NSString *query = searchBar.text;
        NSString *encoded = [query stringByAddingPercentEncodingForRFC3986];
        NSString *targetUrl = [NSString stringWithFormat:@"https://public-api.nazk.gov.ua/v1/declaration/?q=%@", encoded];
        
        [self getJSONData: targetUrl];
        [self.view endEditing:YES];
    }
}

-(void)getJSONData:(NSString *)url {
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = CGPointMake( [UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    [self.activityIndicatorView startAnimating];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview: activityIndicatorView];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: url]];
    
    NSURLSessionDataTask *task = [[self getURLSession] dataTaskWithRequest:request completionHandler:^( NSData *data, NSURLResponse *response, NSError *error )
                                  {
                                      if (data == nil) {
                                          if (error != nil) {
                                              [self showAlert:@"Помилка" message:error.localizedDescription];
                                              dispatch_sync(dispatch_get_main_queue(), ^{
                                                  if (name.count > 0) {
                                                      [name removeAllObjects];
                                                      [linkPDF removeAllObjects];
                                                      [placeOfWork removeAllObjects];
                                                      [position removeAllObjects];
                                                  }
                                                  
                                                  [self.tableView reloadData];
                                                  [activityIndicatorView stopAnimating];
                                                  
                                              });
                                          } else {
                                              [self showAlert:@"Помилка" message: @""];
                                          }
                                      } else {
                                          [self parseJSON:data];
                                      }
                                  }];
    [task resume];
}

-(void)parseJSON:(NSData *) jsonData {
    NSError *jsonError;
    NSDictionary *parsedJSONArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    
    NSLog(@"parsedJSONArray %@", parsedJSONArray );
    if (parsedJSONArray.count > 0) {
        NSString *error =  [parsedJSONArray objectForKey:@"error"];
        NSString *message = [parsedJSONArray objectForKey:@"message"];
        if (error) {
            [self showAlert:@"Помилка" message:message];
        }
        
        NSDictionary *dict1 = [parsedJSONArray objectForKey:@"items"];
        NSLog(@"DICT %@", dict1);
        if (dict1 == nil) {
            [self showAlert:@"Помилка" message:@""];
        } else {
            self->name = [NSMutableArray new];
            self->linkPDF = [NSMutableArray new];
            self->placeOfWork = [NSMutableArray new];
            self->position = [NSMutableArray new];
            
            for (NSDictionary * dict in dict1) {
                
                
                NSString *name = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"lastname"], [dict objectForKey:@"firstname"]];
                NSString *linkPDF = [dict objectForKey:@"linkPDF"];
                NSString *placeOfWork = [dict objectForKey:@"placeOfWork"];
                NSString *position = [dict objectForKey:@"position"];
                
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
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [activityIndicatorView stopAnimating];
            });
        }
        
    } else {
        NSLog(@"error");
        [self showAlert:@"Помилка" message:@""];
    }
    
}

- ( NSURLSession * )getURLSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken,
                  ^{
                      NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                      session = [NSURLSession sessionWithConfiguration:configuration];
                  } );
    
    return session;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end




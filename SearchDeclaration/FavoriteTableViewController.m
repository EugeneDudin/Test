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

@interface FavoriteTableViewController ()

@end

@implementation FavoriteTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar.topItem setTitle: @"Favorite"];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Favorite"];
    self.favoriteDB = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}

- (NSManagedObjectContext *)managedObjectContext
{
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
    return self.favoriteDB.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSManagedObject *favorite = [_favoriteDB objectAtIndex:indexPath.row];
    cell.delegate = self;
    
    if ([[favorite valueForKey:@"linkPDF"] isEqual:@"-"]) {
        [cell.pdfButton setEnabled:NO];
    } else {
        cell.pdfURL = [favorite valueForKey:@"linkPDF"];
    }
    cell.fullName.text = [favorite valueForKey:@"fullName"];
    cell.placeOfWork.text = [favorite valueForKey:@"placeOfWork"];
    cell.positionWork.text = [favorite valueForKey:@"position"];
    cell.comment.text = [favorite valueForKey:@"comment"];
    
    
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [context deleteObject:[self.favoriteDB objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.favoriteDB removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)loadPDFScreen:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)updateComment:(NSString *)comment {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *selectedData = [self.favoriteDB objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
    
    if (selectedData) {
        [selectedData setValue:comment forKey:@"comment"];
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell updateComment];
}


@end

//
//  Alert.h
//  SearchDeclaration
//
//  Created by Jenya on 6/12/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@protocol AlertDelegate <NSObject>
- (void)savePerson:(Person *)person;
- (void)deletePersonByID:(NSString *)personID;
- (void)refresh;
@end

@interface Alert : NSObject

@property (nonatomic, weak) id<AlertDelegate> delegate;

- (UIAlertController *)showAlertMessage:(NSString *)message title:(NSString *)title;
- (UIAlertController *)showAlertComment:(Person *)person message:(NSString *)message title:(NSString *)title comment:(NSString *)comment;
- (UIAlertController *)showAlertDelete:(NSString *)personID message:(NSString *)message title:(NSString *)title;
- (UIAlertController *)showAlertRefresh:(NSString *)message title:(NSString *)title;

@end

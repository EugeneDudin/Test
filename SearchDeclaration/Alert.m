//
//  Alert.m
//  SearchDeclaration
//
//  Created by Jenya on 6/12/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "Alert.h"

@implementation Alert

+ (UIAlertController *)showAlertMessage:(NSString *)message title:(NSString *)title; {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    return alert;
}
@end

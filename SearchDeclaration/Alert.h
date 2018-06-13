//
//  Alert.h
//  SearchDeclaration
//
//  Created by Jenya on 6/12/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Alert : NSObject

+ (UIAlertController *)showAlertMessage:(NSString *)message title:(NSString *)title;

@end

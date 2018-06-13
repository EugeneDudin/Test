//
//  WebService.h
//  SearchDeclaration
//
//  Created by Jenya on 6/12/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebService : NSObject
+ (void)executeQuery:(NSString *)url premeter:(NSString *)premeter page:(int)page withblock:(void(^)(NSData *, NSError*))block;
@end

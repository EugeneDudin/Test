//
//  WebService.m
//  SearchDeclaration
//
//  Created by Jenya on 6/12/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "WebService.h"

@implementation WebService

+ (void)executeQuery:(NSString *)url premeter:(NSString *)premeter page:(int)page withblock:(void(^)(NSData *, NSError*))block {
    
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    NSString * parm = [[[NSString alloc] initWithString:premeter] stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@&page=%i", url, parm, page]]];
    
    
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken,
                  ^{
                      NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                      session = [NSURLSession sessionWithConfiguration:configuration];
                  } );
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^( NSData *data, NSURLResponse *response, NSError *error ) {
        if (data!=nil) {
            NSLog(@"Response %@", data);
            block(data,error);
        } else {
            NSLog(@"error");
            block(nil,error);
        }
    }];
    [task resume];
}

@end

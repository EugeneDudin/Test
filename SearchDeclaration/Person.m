//
//  Person.m
//  SearchDeclaration
//
//  Created by Jenya on 6/13/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import "Person.h"

@implementation Person

-(id)initPersonFullName:(NSString *)fullName position:(NSString *)position placeOfWork:(NSString *)placeOfWork linkPDF:(NSString *)linkPDF personID:(NSString *)personID {
    self = [super init];
    if (self) {
        if (position == nil) {
            _positionWork = @"нi";
        } else {
            _positionWork = position;
        }
        _fullName = fullName;
        _placeOfWork = placeOfWork;
        _linkPDF = linkPDF;
        _personID = personID;
    }
    return self;
}

-(NSMutableDictionary *)getPersonDictionary {
    NSMutableDictionary *person = [[NSMutableDictionary alloc] init];
    [person setValue:_fullName forKey:@"fullName"];
    [person setValue:_positionWork forKey:@"position"];
    [person setValue:_placeOfWork forKey:@"placeOfWork"];
    [person setValue:_linkPDF forKey:@"linkPDF"];
    [person setValue:_personID forKey:@"id"];
    [person setValue:_comment forKey:@"comment"];
    
    return person;
}

-(void)setFavorite:(BOOL)swich {
    _isFavorite = swich;
}

-(void)setComment:(NSString *)comment {
    _comment = comment;
}

@end

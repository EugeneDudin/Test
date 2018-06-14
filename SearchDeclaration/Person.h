//
//  Person.h
//  SearchDeclaration
//
//  Created by Jenya on 6/13/18.
//  Copyright © 2018 Jenya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *linkPDF;
@property (nonatomic, strong) NSString *placeOfWork;
@property (nonatomic, strong) NSString *positionWork;
@property (nonatomic, strong) NSString *personID;

@property (nonatomic, strong) NSString *comment;


-(id)initPersonFullName:(NSString *)fullName position:(NSString *)position placeOfWork:(NSString *)placeOfWork linkPDF:(NSString *)linkPDF personID:(NSString *)personID;

-(NSMutableDictionary *)getPersonDictionary;
-(void)setFavorite:(BOOL)swich;
-(void)setComment:(NSString *)comment;

@end

//
//  DYSaveHMUserTool.h
//  数据库
//
//  Created by 丁益 on 16/4/7.
//  Copyright © 2016年 jinjin. All rights reserved.
//  将HMUser对象保存到数据库的业务类

#import <Foundation/Foundation.h>
#import "DataBaseSqlTool.h"
#import "HMUser.h"
#import "Singleton.h"

@interface DYSaveHMUserTool : NSObject

//SingletonH(DYSaveHMUserTool)

+ (BOOL)addTableListWithAttributeName:(NSString *)attributeName baseType:(BasicTypes)baseType;

+ (BOOL)updateWithSetValue:(NSString*)setValue updateWhere:(NSString*)updateWhere;

+ (BOOL)deleteWithHMUserDeleteWhere:(NSString *)deleteWhere;

+ (BOOL)saveWithHMUser:(HMUser*)user;

+ (void)readWithHMUserFindWhere:(NSString*) findWhere success:(void(^)(NSMutableArray *userArray))success failure:(void(^)())failure;

+ (void)readWithHMUserAgeFindWhere:(NSString *)findWhere success:(void (^)(NSMutableArray* userArray))success failure:(void (^)())failure;

+ (void)readWithHMUserNameFindWhere:(NSString *)findWhere success:(void (^)(NSMutableArray* userArray))success failure:(void (^)())failure;

@end

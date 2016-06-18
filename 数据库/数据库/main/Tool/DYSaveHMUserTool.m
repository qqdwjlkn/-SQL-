//
//  DYSaveHMUserTool.m
//  数据库
//
//  Created by 丁益 on 16/4/7.
//  Copyright © 2016年 jinjin. All rights reserved.
//  

#import "DYSaveHMUserTool.h"


#import "MJExtension.h"
@implementation DYSaveHMUserTool

//SingletonM(DYSaveHMUserTool)


+ (BOOL)addTableListWithAttributeName:(NSString *)attributeName baseType:(BasicTypes)baseType {
    
    BOOL flg = [DataBaseSqlTool addTableListWithTableName:@"t__MYUser" attributeName:attributeName baseType: baseType];

    return flg;
}

+ (BOOL)saveWithHMUser:(HMUser *)user{

//    @"CREATE TABLE IF NOT EXISTS t_home_status (id integer PRIMARY KEY AUTOINCREMENT, access_token text NOT NULL, status_idstr text NOT NULL, status_dict blob NOT NULL);"
    [DataBaseSqlTool createWithTableName:@"t__MYUser" sqlStatement:@"name text NOT NULL, age integer NOT NULL, sex text NOT NULL"];
    
//  @"insert into tableName(数据表) (name,age) values ('lisi','28')"
    NSString *sqlStatement = [NSString stringWithFormat:@"(name,age,sex) values ('%@','%d','%@')",user.name,user.age,user.sex];
    [DataBaseSqlTool insertWithTableName:@"t__MYUser" sqlStatement:sqlStatement];
    return YES;
}

+ (BOOL)deleteWithHMUserDeleteWhere:(NSString *)deleteWhere {

    BOOL flg = [DataBaseSqlTool deleteWithTableName:@"t__MYUser" deleteWhere:deleteWhere];
    
    return flg;
}

+ (BOOL)updateWithSetValue:(NSString*)setValue updateWhere:(NSString*)updateWhere{

    BOOL flg = [DataBaseSqlTool updateWithTableName:@"t__MYUser" setValue:setValue updateWhere:updateWhere];
    
    return flg;
}


+ (void)readWithHMUserFindWhere:(NSString *)findWhere success:(void (^)(NSMutableArray* userArray))success failure:(void (^)())failure{

    BOOL flg = [DataBaseSqlTool selectWithTableName:@"t__MYUser" findTable:@"user" findWhere:findWhere resultClass:[HMUser class] findResultBlock:^(NSMutableArray *reslut) {
        if (success) {
            success(reslut);
        }
    }];
    if (!flg) {
        if (failure) {
            failure();
        }
    }
}

+ (void)readWithHMUserAgeFindWhere:(NSString *)findWhere success:(void (^)(NSMutableArray* userArray))success failure:(void (^)())failure{
    
    BOOL flg = [DataBaseSqlTool selectSingleDoubleWithTableName:@"t_HMUser" findTable:@"age" findWhere:findWhere indResultBlock:^(NSMutableArray *reslut) {
        if (success) {
            success(reslut);
        }
        
    }];
                
    if (!flg) {
        if (failure) {
            failure();
        }
    }
}

+ (void)readWithHMUserNameFindWhere:(NSString *)findWhere success:(void (^)(NSMutableArray* userArray))success failure:(void (^)())failure{
    BOOL flg = [DataBaseSqlTool selectSingleCharWithTableName:@"t_HMUser" findTable:@"name" findWhere:findWhere indResultBlock:^(NSMutableArray *reslut) {
        if (success) {
            success(reslut);
        }
    }];
    
    if (!flg) {
        if (failure) {
            failure();
        }
    }
}



@end

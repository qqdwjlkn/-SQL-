//
//  DataBaseSqlTool.h
//  数据库
//
//  Created by 丁益 on 16/4/7.
//  Copyright © 2016年 jinjin. All rights reserved.
//  SQL语句封装

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "Singleton.h"


typedef enum{
    BasicTypesChar   = 1,
    BasicTypesInt    = 2,
    BasicTypesDouble = 3,
    BasicTypesBlob   = 4
} BasicTypes;

@interface DataBaseSqlTool : NSObject

SingletonH(DataBaseSqlTool)

+ (BOOL)deleteTable:(NSString *)tableName;

+ (BOOL)eraseTable:(NSString *)tableName;

+ (BOOL)isTableOK:(NSString *)tableName;

+ (BOOL)addTableListWithTableName:(NSString *)tableName attributeName:(NSString *)attributeName baseType:(BasicTypes)baseType;

+ (BOOL)createWithTableName:(NSString *)tableName sqlStatement:(NSString*)sqlStatement;

+ (BOOL)insertWithTableName:(NSString *)tableName sqlStatement:(NSString*)sqlStatement;

+ (BOOL)deleteWithTableName:(NSString *)tableName deleteWhere:(NSString *)deleteWhere;

+ (BOOL)updateWithTableName:(NSString *)tableName setValue:(NSString*)setValue updateWhere:(NSString *)updateWhere;

+ (BOOL)selectWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere resultClass:(Class)resultClass findResultBlock:(void(^)(NSMutableArray *reslut))findResultBlock;

+ (BOOL)selectSingleDoubleWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void(^)(NSMutableArray *reslut))findResultBlock;

+ (BOOL)selectSingleIntWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock;

+ (BOOL)selectSingleCharWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock;



/** 调用者传进来的数据库*/
@property (nonatomic ,strong) FMDatabase *inputDB;

- (BOOL)deleteTable:(NSString *)tableName;

- (BOOL)eraseTable:(NSString *)tableName;

- (BOOL)isTableOK:(NSString *)tableName;

- (BOOL)addTableListWithTableName:(NSString *)tableName attributeName:(NSString *)attributeName baseType:(BasicTypes)baseType;

- (BOOL)createWithTableName:(NSString *)tableName sqlStatement:(NSString*)sqlStatement;

- (BOOL)insertWithTableName:(NSString *)tableName sqlStatement:(NSString*)sqlStatement;

- (BOOL)deleteWithTableName:(NSString *)tableName deleteWhere:(NSString *)deleteWhere;

- (BOOL)updateWithTableName:(NSString *)tableName setValue:(NSString*)setValue updateWhere:(NSString *)updateWhere;

- (BOOL)selectWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere resultClass:(Class)resultClass findResultBlock:(void(^)(NSMutableArray *reslut))findResultBlock;

- (BOOL)selectSingleDoubleWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void(^)(NSMutableArray *reslut))findResultBlock;

- (BOOL)selectSingleIntWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock;

- (BOOL)selectSingleCharWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock;
@end

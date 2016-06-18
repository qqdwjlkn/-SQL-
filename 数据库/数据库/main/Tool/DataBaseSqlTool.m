//
//  DataBaseSqlTool.m
//  数据库
//
//  Created by 丁益 on 16/4/7.
//  Copyright © 2016年 jinjin. All rights reserved.
//

#import "DataBaseSqlTool.h"
#import "FMDB.h"
#import "MJExtension.h"

@interface DataBaseSqlTool()

@end

@implementation DataBaseSqlTool

SingletonM(DataBaseSqlTool);

/** 数据库实例 */
static FMDatabase *_db;

+ (BOOL)openDatabase
{
    //create SQLite3 file.
    // 1.获得数据库文件的路径
   /* NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];*/
    NSString *filePath = @"/Users/dingyi/Desktop/DataBase.sqlite";//[doc stringByAppendingPathComponent:@"DataBase.sqlite"];
    DYLog(@"数据库路径 --------%@",filePath);
    /*NSString *userDirectory = [doc stringByAppendingPathComponent:<#添加子目录路径#>];
     NSFileManager *fileManage = [NSFileManager defaultManager];
     if (![fileManage createDirectoryAtPath:userDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
     DYLog(@"[error:] create database group.");
     return result;
     }
     filePath = [userDirectory stringByAppendingPathComponent:@"DataBase.sqlite"];*/
    
    _db = [FMDatabase databaseWithPath:filePath];
    if (![_db open]) {
        [_db close];
        NSAssert(0, @"Failed to open database");
        return NO;
    }
    return YES;
}

+ (BOOL)closeDatabase
{
    if ([_db close]) {
        return  YES;
    }
    DYLog(@"关闭数据库失败!");
    return NO;
}

/**
 *  创建表格
 *
 *  @param tableName 数据表名称
 *  @param sqlStatement  表格属性(SQL语句)
 *
 *  @return 创建表格是否成功
 *  sql语句例子:@"CREATE TABLE IF NOT EXISTS t_home_status (id integer PRIMARY KEY AUTOINCREMENT, access_token text NOT NULL, status_idstr text NOT NULL, status_dict blob NOT NULL);"
 */
+ (BOOL)createWithTableName:(NSString *)tableName sqlStatement:(NSString *)sqlStatement{
    if (![self openDatabase]) return NO;
    // 增加列表
    /*//add column locationInfo.
     NSString *alterStr = [NSString stringWithFormat:@"alter table %@ add column locationInfo text",tableName];
     if (![_db executeUpdate:alterStr]) {
     DYLog(@"Error add locationInfo to table: %@", [_db lastErrorMessage]);
     }*/
    
    //create table if not exists
    NSString *createSQL =[NSString stringWithFormat:@"create table if not exists %@ (%@);",tableName,sqlStatement];
    if (![_db executeUpdate:createSQL]) {
        [self closeDatabase];
        DYLog(@"Error creating table: %@", [_db lastErrorMessage]);
        return NO;
    }

    [self closeDatabase];
    return YES;
}

/**
 *  删除表
 *
 *  @param tableName 数据表名称
 *
 *  @return 删除表是否成功
 */
+ (BOOL) deleteTable:(NSString *)tableName
{
    if (![self openDatabase]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        DYLog(@"Delete table error!");
        [self closeDatabase];
        return NO;
    }
    [self closeDatabase];
    return YES;
}

/**
 *  清除表 (清空表中的内容)
 *
 *  @param tableName 数据表名称
 *
 *  @return 清除表是否成功
 */
+ (BOOL) eraseTable:(NSString *)tableName
{
    if (![self openDatabase]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        DYLog(@"Erase table error!");
        [self closeDatabase];
        return NO;
    }
    [self closeDatabase];
    return YES;
}

/**
 *  判断是否存在表
 *
 *  @param tableName 数据表名称
 *
 *  @return 返回值大于0 表示表存在  返回值等于0表示没有表存在
 */
+ (BOOL)isTableOK:(NSString *)tableName
{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = '%@'",tableName];
    FMResultSet *rs = [_db executeQuery:query];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        DYLog(@"isTableOK %ld", (long)count);
        
        [self closeDatabase];
        if (0 == count){
            return NO;
        }else {
            return YES;
        }
    }
    [self closeDatabase];
    return NO;
}

/**
 *  给现有的表上添加字段
 *
 *  @param tableName     表名称
 *  @param attributeName 字段名称
 *  @param baseType      字段类型
 *
 *  @return 给表添加字段是否成功
 */
+ (BOOL)addTableListWithTableName:(NSString *)tableName attributeName:(NSString *)attributeName baseType:(BasicTypes)baseType {
    if (![self openDatabase]) return NO;
    
    NSString *alterStr = nil;
    // 增加列表
    //add column locationInfo.
    switch (baseType) {
        case BasicTypesChar:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ text",tableName,attributeName];
            break;
            
        case BasicTypesInt:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ integer",tableName,attributeName];
            break;
            
        case BasicTypesDouble:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ real",tableName,attributeName];
            break;
            
        case BasicTypesBlob:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ blob",tableName,attributeName];
            break;
            
        default:
            break;
    }
    if (![_db executeUpdate:alterStr]) {
        [self closeDatabase];
        DYLog(@"Error add locationInfo to table: %@", [_db lastErrorMessage]);
        return NO;
    }
    [self closeDatabase];
    return YES;
}

/**
 *  插入数据
 *
 *  @param tableName 数据表名称
 *  @param sqlStatement  插入的属性和值(SQL语句)
 *
 *  @return 插入数据是否成功
 *  sql语句例子:@"insert into tableName(数据表) (name,age) values ('lisi','28')"
 */
+ (BOOL)insertWithTableName:(NSString *)tableName sqlStatement:(NSString *)sqlStatement{

    if (![self openDatabase]) return NO;
    BOOL result = YES;
    NSString *query = [NSString stringWithFormat:@"insert into %@ %@;",tableName,sqlStatement];
    
    if (![_db executeUpdate:query]) {
        DYLog(@"Erorr updating table!: %@", [_db lastErrorMessage]);
        [self closeDatabase];
        result = NO;
    }
    return result;
}

/**
 *  删除数据
 *
 *  @param tableName 数据表名称
 *  @param deleteWhere  删除条件(SQL语句)
 *
 *  @return 删除数据是否成功
 *  sql语句例子:@"delete from tableName(数据表) where name='lisi'";
 */
+ (BOOL)deleteWithTableName:(NSString *)tableName deleteWhere:(NSString *)deleteWhere{

    if (![self openDatabase]) return NO;
    NSString *query = [NSString stringWithFormat:@"delete from %@ where %@",tableName,deleteWhere];
    if (![_db executeUpdate:query]) {
        DYLog(@"[error:] clean");
        [self closeDatabase];
        return NO;
    }
    [self closeDatabase];
    return YES;
}

/**
 *  更新数据
 *
 *  @param tableName    数据表名称
 *  @param setValue     更新数据(SQL语句)
 *  @param updateWhere  更新数据条件
 *
 *  @return 跟新数据是否成功
 *  sql语句例子:@"update tableName(数据表) set age='23' where name='lisi'";
 */
+ (BOOL)updateWithTableName:(NSString *)tableName setValue:(NSString*)setValue updateWhere:(NSString *)updateWhere;{
    
    if (![self openDatabase]) return NO;
    NSString *update = [NSString stringWithFormat:@"update %@ set %@ where %@",tableName, setValue,updateWhere];
    if (![_db executeUpdate:update]) {
        DYLog(@"Erorr updating table!: %@", [_db lastErrorMessage]);
        [self closeDatabase];
        return  NO;
    }
    [self closeDatabase];
    return YES;
}

#pragma  mark -查找数据库接口
/**
 *  查找数据
 *
 *  @param tableName       数据表名称
 *  @param findTable       需要查找的属性  该值为* 表示查找表格中所有属性
 *  @param findWhere       设置查询条件
 *  @param resultClass     查询返回的类名
 *  @param findResultBlock 查询结果
 *
 *  @return 查找数据是否成功
 *  查询分精确查询和模糊查询详细见http://blog.163.com/ding_123com/blog/static/211752221201542942837616/
 *  SQLite基础知识参考资料 http://pan.baidu.com/s/1c1Choac
 *  SQLite编码知识参考资料 http://pan.baidu.com/s/1jHYVBXs
 *  sql语句例子:@"select msg from tableName(数据表) where username='dy1' order by time desc  limit 1"
 */
+ (BOOL)selectWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere resultClass:(Class)resultClass findResultBlock:(void (^)(NSMutableArray*))findResultBlock{

    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];

    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [_db executeQuery:query];
    while([set next]) {
        char *data = (char *)[set UTF8StringForColumnIndex:0];
        if (data != nil) {
            NSString *info = [NSString stringWithUTF8String:data];
            DYLog(@"--------%@-------",info);
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[info dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            
            id result = [resultClass objectWithKeyValues:dict];
            [array addObject:result];
        }
    }

    if (findResultBlock) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}

/*
 * 使用说明 只适用查找单个的属性为double类型的值
 * 属性说明同上
 */
+ (BOOL)selectSingleDoubleWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [_db executeQuery:query];
    while([set next]) {
        double doubleValue = [set doubleForColumnIndex:0];
        [array addObject:@(doubleValue)];
    }
    
    if ((findResultBlock)&&(array.count > 0)) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}

/*
 * 使用说明 只适用查找单个的属性为int类型的值
 * 属性说明同上
 */
+ (BOOL)selectSingleIntWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [_db executeQuery:query];
    while([set next]) {
        int intValue = [set intForColumnIndex:0];
        [array addObject:@(intValue)];
    }
    
    if ((findResultBlock)&&(array.count > 0)) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}

/*
 * 使用说明 只适用查找单个的属性为字符串的类型的值
 * 属性说明同上
 */
+ (BOOL)selectSingleCharWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [_db executeQuery:query];
    while([set next]) {
        char *CString = (char *)[set UTF8StringForColumnIndex:0];
        NSString *OCstring = [NSString stringWithUTF8String:CString];//[NSString stringWithFormat:@"%s",CString];
        [array addObject:OCstring];
    }
    
    if ((findResultBlock)&&(array.count > 0)) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}


#pragma mark -需要外面传进来数据库

- (BOOL)openDatabase
{
    //create SQLite3 file.
    
    //    self.inputDB = [FMDatabase databaseWithPath:self.dbFilePath];
    // 数据库由调用者传输进来
    if (self.inputDB == nil) return NO;
    
    if (![self.inputDB open]) {
        [self.inputDB close];
        NSAssert(0, @"Failed to open database");
        return NO;
    }
    return YES;
}

- (BOOL)closeDatabase
{
    if ([self.inputDB close]) {
        return  YES;
    }
    DYLog(@"关闭数据库失败!");
    return NO;
}

/**
 *  创建表格
 *
 *  @param tableName 数据表名称
 *  @param sqlStatement  表格属性(SQL语句)
 *
 *  @return 创建表格是否成功
 *  sql语句例子:@"CREATE TABLE IF NOT EXISTS t_home_status (id integer PRIMARY KEY AUTOINCREMENT, access_token text NOT NULL, status_idstr text NOT NULL, status_dict blob NOT NULL);"
 */
- (BOOL)createWithTableName:(NSString *)tableName sqlStatement:(NSString *)sqlStatement{
    if (![self openDatabase]) return NO;
    // 增加列表
    /*//add column locationInfo.
     NSString *alterStr = [NSString stringWithFormat:@"alter table %@ add column locationInfo text",tableName];
     if (![self.inputDB executeUpdate:alterStr]) {
     DYLog(@"Error add locationInfo to table: %@", [self.inputDB lastErrorMessage]);
     }*/
    
    //create table if not exists
    NSString *createSQL =[NSString stringWithFormat:@"create table if not exists %@ (%@);",tableName,sqlStatement];
    if (![self.inputDB executeUpdate:createSQL]) {
        [self closeDatabase];
        DYLog(@"Error creating table: %@", [self.inputDB lastErrorMessage]);
        return NO;
    }
    [self closeDatabase];
    return YES;
}

/**
 *  删除表
 *
 *  @param tableName 数据表名称
 *
 *  @return 删除表是否成功
 */
- (BOOL) deleteTable:(NSString *)tableName
{
    if (![self openDatabase]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![self.inputDB executeUpdate:sqlstr])
    {
        DYLog(@"Delete table error!");
        [self closeDatabase];
        return NO;
    }
    [self closeDatabase];
    return YES;
}

/**
 *  清除表 (清空表中的内容)
 *
 *  @param tableName 数据表名称
 *
 *  @return 清除表是否成功
 */
- (BOOL) eraseTable:(NSString *)tableName
{
    if (![self openDatabase]) return NO;
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![self.inputDB executeUpdate:sqlstr])
    {
        DYLog(@"Erase table error!");
        [self closeDatabase];
        return NO;
    }
    [self closeDatabase];
    return YES;
}

/**
 *  判断是否存在表
 *
 *  @param tableName 数据表名称
 *
 *  @return 返回有值表示存在该表，返回0不存在该表
 */
- (BOOL)isTableOK:(NSString *)tableName
{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = '%@'",tableName];
    FMResultSet *rs = [self.inputDB executeQuery:query];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        DYLog(@"isTableOK %ld", (long)count);
        
        [self closeDatabase];
        if (0 == count){
            return NO;
        }else {
            return YES;
        }
    }
    [self closeDatabase];
    return NO;
}

/**
 *  给现有的表上添加字段
 *
 *  @param tableName     表名称
 *  @param attributeName 字段名称
 *  @param baseType      字段类型
 *
 *  @return 给表添加字段是否成功
 */
- (BOOL)addTableListWithTableName:(NSString *)tableName attributeName:(NSString *)attributeName baseType:(BasicTypes)baseType {
    if (![self openDatabase]) return NO;
    
    NSString *alterStr = nil;
    // 增加列表
    //add column locationInfo.
    switch (baseType) {
        case BasicTypesChar:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ text",tableName,attributeName];
            break;
            
        case BasicTypesInt:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ integer",tableName,attributeName];
            break;
            
        case BasicTypesDouble:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ real",tableName,attributeName];
            break;
            
        case BasicTypesBlob:
            alterStr = [NSString stringWithFormat:@"alter table %@ add column %@ blob",tableName,attributeName];
            break;
            
        default:
            break;
    }
    if (![self.inputDB executeUpdate:alterStr]) {
        [self closeDatabase];
        DYLog(@"Error add locationInfo to table: %@", [self.inputDB lastErrorMessage]);
        return NO;
    }
    [self closeDatabase];
    return YES;
}


/**
 *  插入数据
 *
 *  @param tableName 数据表名称
 *  @param sqlStatement  插入的属性和值(SQL语句)
 *
 *  @return 插入数据是否成功
 *  sql语句例子:@"insert into tableName(数据表) (name,age) values ('lisi','28')"
 */
- (BOOL)insertWithTableName:(NSString *)tableName sqlStatement:(NSString *)sqlStatement{
    if (![self openDatabase]) return NO;
    BOOL result = YES;
    NSString *query = [NSString stringWithFormat:@"insert into %@ %@;",tableName,sqlStatement];
    
    if (![self.inputDB executeUpdate:query]) {
        DYLog(@"Erorr updating table!: %@", [self.inputDB lastErrorMessage]);
        result = NO;
    }
    [self closeDatabase];
    return result;
}

/**
 *  删除数据
 *
 *  @param tableName 数据表名称
 *  @param deleteWhere  删除条件(SQL语句)
 *
 *  @return 删除数据是否成功
 *  sql语句例子:@"delete from tableName(数据表) where name='lisi'";
 */
- (BOOL)deleteWithTableName:(NSString *)tableName deleteWhere:(NSString *)deleteWhere{
    
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"delete from %@ where %@",tableName,deleteWhere];
    if (![self.inputDB executeUpdate:query]) {
        DYLog(@"[error:] clean");
        [self closeDatabase];
        return NO;
    }
    [self closeDatabase];
    DYLog(@"clean too old data in shareTable success.");
    return YES;
}

/**
 *  更新数据
 *
 *  @param tableName    数据表名称
 *  @param setValue     更新数据(SQL语句)
 *  @param updateWhere  更新数据条件
 *
 *  @return 跟新数据是否成功
 *  sql语句例子:@"update tableName(数据表) set age='23' where name='lisi'";
 */
- (BOOL)updateWithTableName:(NSString *)tableName setValue:(NSString*)setValue updateWhere:(NSString *)updateWhere;{
    
    if (![self openDatabase]) return NO;
    
    NSString *update = [NSString stringWithFormat:@"update %@ set %@ where %@",tableName, setValue,updateWhere];
    if (![self.inputDB executeUpdate:update]) {
        DYLog(@"Erorr updating table!: %@", [self.inputDB lastErrorMessage]);
        [self closeDatabase];
        return  NO;
    }
    [self closeDatabase];
    return YES;
}

#pragma  mark -查找数据库接口
/**
 *  查找数据
 *
 *  @param tableName       数据表名称
 *  @param findTable       需要查找的属性  该值为* 表示查找表格中所有属性
 *  @param findWhere       设置查询条件
 *  @param resultClass     查询返回的类名
 *  @param findResultBlock 查询结果
 *
 *  @return 查找数据是否成功
 *  查询分精确查询和模糊查询详细见http://blog.163.com/ding_123com/blog/static/211752221201542942837616/
 *  SQLite基础知识参考资料 http://pan.baidu.com/s/1c1Choac
 *  SQLite编码知识参考资料 http://pan.baidu.com/s/1jHYVBXs
 *  sql语句例子:@"select msg from tableName(数据表) where username='dy1' order by time desc  limit 1"
 */
- (BOOL)selectWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere resultClass:(Class)resultClass findResultBlock:(void (^)(NSMutableArray*))findResultBlock{
    
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [self.inputDB executeQuery:query];
    while([set next]) {
        char *data = (char *)[set UTF8StringForColumnIndex:0];
        if (data != nil) {
            NSString *info = [NSString stringWithUTF8String:data];
            DYLog(@"--------%@-------",info);
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[info dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            
            id result = [resultClass objectWithKeyValues:dict];
            [array addObject:result];
        }
    }
    
    if (findResultBlock) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}

/*
 * 使用说明 只适用查找单个的属性为double类型的值
 * 属性说明同上
 */
- (BOOL)selectSingleDoubleWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [self.inputDB executeQuery:query];
    while([set next]) {
        double doubleValue = [set doubleForColumnIndex:0];
        [array addObject:@(doubleValue)];
    }
    
    if ((findResultBlock)&&(array.count > 0)) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}

/*
 * 使用说明 只适用查找单个的属性为int类型的值
 * 属性说明同上
 */
- (BOOL)selectSingleIntWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [self.inputDB executeQuery:query];
    while([set next]) {
        int intValue = [set intForColumnIndex:0];
        [array addObject:@(intValue)];
    }
    
    if ((findResultBlock)&&(array.count > 0)) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}

/*
 * 使用说明 只适用查找单个的属性为字符串的类型的值
 * 属性说明同上
 */
- (BOOL)selectSingleCharWithTableName:(NSString *)tableName findTable:(NSString *)findTable findWhere:(NSString *)findWhere indResultBlock:(void (^)(NSMutableArray *))findResultBlock{
    if (![self openDatabase]) return NO;
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where %@",findTable,tableName,findWhere];
    
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *set = [self.inputDB executeQuery:query];
    while([set next]) {
        char *CString = (char *)[set UTF8StringForColumnIndex:0];
        NSString *OCstring = [NSString stringWithUTF8String:CString];//[NSString stringWithFormat:@"%s",CString];
        [array addObject:OCstring];
    }
    
    if ((findResultBlock)&&(array.count > 0)) {
        findResultBlock(array);
    }
    [self closeDatabase];
    return YES;
}
@end

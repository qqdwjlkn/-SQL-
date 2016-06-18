//
//  ViewController.m
//  数据库
//
//  Created by 丁益 on 16/4/6.
//  Copyright © 2016年 jinjin. All rights reserved.
//

#import "ViewController.h"
#import "HMUser.h"
#import "MJExtension.h"
#import "DYSaveHMUserTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self operationHMUserTable];
    
}

/**
 * 操作HMUserTable  不需要传入数据库  
 */
- (void)operationHMUserTable{
    HMUser *user = [[HMUser alloc]init];
    user.name = @"小七1";
    user.age = 18;
    user.sex = @"女";
    
    // 给表插入一列数据
    [DYSaveHMUserTool addTableListWithAttributeName:@"double" baseType:BasicTypesDouble];
    [DYSaveHMUserTool addTableListWithAttributeName:@"blob" baseType:BasicTypesBlob];
    //插入数据
    [DYSaveHMUserTool saveWithHMUser:user];
    
    //删除数据
    [DYSaveHMUserTool deleteWithHMUserDeleteWhere:@"age=10"];
    
    //更新数据
    [DYSaveHMUserTool updateWithSetValue:@"age=28" updateWhere:@"name='lisi'"];
    
    //查找数据
    [DYSaveHMUserTool readWithHMUserFindWhere:@"age<20" success:^(NSMutableArray *userArray) {
        DYLog(@"%@",userArray);
    } failure:^{
        DYLog(@"读取数据失败");
    }];
    
    [DYSaveHMUserTool readWithHMUserAgeFindWhere:@"age<20" success:^(NSMutableArray *userArray) {
        DYLog(@"%@",userArray);
    } failure:^{
        DYLog(@"读取数据失败");
    }];
    
    [DYSaveHMUserTool readWithHMUserNameFindWhere:@"age<20 order by age desc  limit 3" success:^(NSMutableArray *userArray) {
        DYLog(@"%@",userArray);
    } failure:^{
        DYLog(@"读取数据失败");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  HMUser.h
//
//  Created by apple on 14-7-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//  用户模型

#import <Foundation/Foundation.h>

@interface HMUser : NSObject
/** string 	友好显示名称 */
@property (nonatomic, copy) NSString *name;



@property (nonatomic, assign) int age;



@property (nonatomic, copy) NSString *sex;
@end

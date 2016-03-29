//
//  YXTabTitleView.h
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/25.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXTabTitleView : UIView

-(instancetype)initWithTitleArray:(NSArray *)titleArray;

-(void)setItemSelected: (NSInteger)column;

/**
 *  定义点击的block
 *
 *  @param NSInteger 点击column数
 */
typedef void (^YXTabTitleClickBlock)(NSInteger);

@property (nonatomic, strong) YXTabTitleClickBlock titleClickBlock;

@end

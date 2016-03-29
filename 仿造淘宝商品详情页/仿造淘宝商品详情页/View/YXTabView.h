//
//  YXTabView.h
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/25.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXTabView : UIView

/*
@[@{
@"title":@"图文介绍",
@"view":@"PicAndTextIntroduceView",
@"data":@"图文介绍的数据",
@"position":@0
},@{
@"title":@"商品详情",
@"view":@"ItemDetailView",
@"data":@"商品详情的数据",
@"position":@1
},@{
@"title":@"评价(273)",
@"view":@"CommentView",
@"data":@"评价的数据",
@"position":@2
}];
 */
-(instancetype)initWithTabConfigArray:(NSArray *)tabConfigArray;//tab页配置数组

@end

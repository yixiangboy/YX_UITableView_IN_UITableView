//
//  YXTabItemBaseView.h
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/29.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXTabItemBaseView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, strong) NSDictionary *info;

-(void)renderUIWithInfo:(NSDictionary *)info;

@end

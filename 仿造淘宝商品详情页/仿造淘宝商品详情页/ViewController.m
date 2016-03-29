//
//  ViewController.m
//  仿造淘宝商品详情页
//
//  Created by yixiang on 16/3/23.
//  Copyright © 2016年 yixiang. All rights reserved.
//

#import "ViewController.h"
#import "YXIgnoreHeaderTouchAndRecognizeSimultaneousTableView.h"
#import "YXTabView.h"
#import "YX.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) YXIgnoreHeaderTouchAndRecognizeSimultaneousTableView *tableView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@property (nonatomic, assign) BOOL canScroll;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
}

-(void)initUI{
    [self initPicView];
    _tableView = [[YXIgnoreHeaderTouchAndRecognizeSimultaneousTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kBottomBarHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 250)];
    headView.backgroundColor = [UIColor clearColor];
    _tableView.tableHeaderView = headView;
    
    [self initTopView];
    [self initBottomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];
}

-(void)acceptMsg : (NSNotification *)notification{
    //NSLog(@"%@",notification);
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initPicView{
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame))];
    picView.image = [UIImage imageNamed:@"item.jpg"];
    picView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
    [picView addGestureRecognizer:tapGesture];
    [self.view addSubview:picView];
}

-(void)clickImage:(UITapGestureRecognizer *)gesture{
    NSLog(@"点击图片操作");
}

-(void)initTopView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kTopBarHeight)];
    topView.backgroundColor = [UIColor orangeColor];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:topView.bounds];
    textLabel.text = @"顶部BAR";
    textLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:textLabel];
    [self.view addSubview:topView];
}

-(void)initBottomView{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-kBottomBarHeight, CGRectGetWidth(self.view.frame), kBottomBarHeight)];
    bottomView.backgroundColor = [UIColor orangeColor];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:bottomView.bounds];
    textLabel.text = @"底部BAR";
    textLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:textLabel];
    [self.view addSubview:bottomView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    CGFloat height = 0.;
    if (section==0) {
        height = 160.;
    }else if(section==1){
        height = 60.;
    }else if(section==2){
        height = CGRectGetHeight(self.view.frame)-kBottomBarHeight-kTopBarHeight;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger section  = indexPath.section;

    if (section==0) {
        UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.view.frame), 20)];
        [cell.contentView addSubview:textlabel];
        textlabel.text = @"价格区";
        textlabel.textAlignment = NSTextAlignmentCenter;
    }else if(section==1){
        UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 20)];
        [cell.contentView addSubview:textlabel];
        textlabel.text = @"sku区";
        textlabel.textAlignment = NSTextAlignmentCenter;
    }else if(section==2){
        NSArray *tabConfigArray = @[@{
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
        YXTabView *tabView = [[YXTabView alloc] initWithTabConfigArray:tabConfigArray];
        [cell.contentView addSubview:tabView];
    }
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat tabOffsetY = [_tableView rectForSection:2].origin.y-kTopBarHeight;
    CGFloat offsetY = scrollView.contentOffset.y;
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    if (offsetY>=tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            //NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
        }
    }
}

@end

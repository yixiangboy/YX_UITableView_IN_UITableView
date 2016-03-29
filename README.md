#UITableview嵌套UITableView案例实践（仿淘宝商品详情页实现）

##一、案例演示

IOS中提供的UITableView功能非常强大，section提供分组，cell提供显示，几乎可以应付绝大部分场景。最近想模仿旧版的淘宝的商品详情页（最新的淘宝详情页商品详情和图文详情是两个页面）写一个Demo，后来发现单纯使用UITableView来布局是比较困难的。因为旧版的淘宝详情页中，最外层的View肯定是一个UITableView，但是内层的Tab中，图文介绍、商品详情和评价三个Tab对应的内容非常丰富，如果你把这三块内容放在一个section中的话，将导致数据组织非常困难，并且UI的灵活度也大大降低。所以最后准备尝试使用UITableView嵌套UITableView的方式来组织UI，最外层是一个UITableView，三个Tab其实是一个横向ScrollView,这个ScrollView里面包含三个UITableView。并且Tab中的内容采用动态可配置话的方式生成（下面详解）。实现的效果如下：

![仿造淘宝详情页](http://img.my.csdn.net/uploads/201603/29/1459239785_4388.gif)

##二、项目详解

###2.1、大体思路

使内层的UITableView（TAB栏里面）和外层的UITableView同时响应用户的手势滑动事件。当用户从页面顶端从下往上滑动到TAB栏的过程中，使外层的UITableView跟随用户手势滑动，内层的UITableView不跟随手势滑动。当用户继续往上滑动的时候，让外层的UITableView不跟随手势滑动，让内层的UITableView跟随手势滑动。反之从下往上滑动也一样。

如上图所示，外层的section0为价格区，可以自定义。section1为sku区，也可以自定义。section2为TAB区域，该区域采用Runtime反射机制，动态配置完成。

###2.2、具体实现

####2.2.1、YXIgnoreHeaderTouchTableView

我们顶部的图片其实是覆盖在外层UITableView的tableHeaderView的下面，我们把tableHeaderView设置为透明。这样实现是为了方便我们在滑动的时候，动态的改变图片的宽高，实现列表头部能够动态拉伸的效果。但是我们对于UITableView不做处理的时候，该图片是无法响应点击事件的，因为被tableHeaderView提前消费了。所以我们要不让tableHeaderView不响应点击事件。我们在YXIgnoreHeaderTouchTableView的实现文件中重写以下方法。

```objective-c
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
if (self.tableHeaderView && CGRectContainsPoint(self.tableHeaderView.frame, point)) {
return NO;
}
return [super pointInside:point withEvent:event];
}
```

####2.2.2、 YXIgnoreHeaderTouchAndRecognizeSimultaneousTableView

该文件继承于YXIgnoreHeaderTouchTableView，除此之外，主要是为了让外层的UITableView能够显示外层UITableView的滑动事件。我们需要实现以下代理方法。

```objective-c
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
return YES;
}
```

####2.2.3、YXTabView

该文件是TAB区域主文件，显示的标题的内容都是通过以下字典动态生成。

```ob
if(section==2){
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
```

title：TAB每个Item的标题。

view：TAB每个Item的内容。

data：TAB每个Item内容渲染需要的数据。

position：TAB的位置。从0开始。

该TAB其实是有YXTabTitleView（标题栏）和一个横向的ScrollView（内层多个UITableView的容器）构成。内层多个UITableView通过以上配置文件动态生成。如下如示：

```objective-c
for (int i=0; i<tabConfigArray.count; i++) {
NSDictionary *info = tabConfigArray[i];
NSString *clazzName = info[@"view"];
Class clazz = NSClassFromString(clazzName);
YXTabItemBaseView *itemBaseView = [[clazz alloc] init];
[itemBaseView renderUIWithInfo:tabConfigArray[i]];
[_tabContentView addSubview:itemBaseView];
}
```

####2.2.4、YXTabItemBaseView

该文件是内层UITableView都应该继承的BaseView，在该View中我们设置了内层UITableView具体在什么时机不响应用户滑动事件，什么时机应该响应用户滑动事件，什么时间通知外层UITableView响应滑动事件等等功能。

```objective-c
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
if (!self.canScroll) {
[scrollView setContentOffset:CGPointZero];
}
CGFloat offsetY = scrollView.contentOffset.y;
if (offsetY<0) {
[[NSNotificationCenter defaultCenter] postNotificationName:kLeaveTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
[scrollView setContentOffset:CGPointZero];
self.canScroll = NO;
self.tableView.showsVerticalScrollIndicator = NO;
}
}
```

####2.2.5、PicAndTextIntroduceView、ItemDetailView、CommentView

这三个文件都继承于YXTabItemBaseView，但是在该文件中我们只需要注意UI的渲染就可以了。响应事件的管理都在YXTabItemBaseView做好了。

就拿PicAndTextIntroduceView.m来看,基本上都是UI代码:

```
@implementation PicAndTextIntroduceView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
return 50.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
static NSString *cellId = @"cellId";
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
if (!cell) {
cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
}
cell.textLabel.text = self.info[@"data"];
return cell;
}

@end
```

####2.2.6、内外层滑动事件的响应和传递

外层UITableView在初始化的时候 需要监听一个NSNotification，该通知是内层UITableView传递给外层的，传递时机为从上往下活动，当TAB栏取消置顶的时候。通知外层UITableView可以开始滚动了。

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];

-(void)acceptMsg : (NSNotification *)notification{
//NSLog(@"%@",notification);
NSDictionary *userInfo = notification.userInfo;
NSString *canScroll = userInfo[@"canScroll"];
if ([canScroll isEqualToString:@"1"]) {
_canScroll = YES;
}
}
```

在scrollViewDidScroll方法中，需要实时监控外层UItableView的滑动时机。也要在适当时机发送NSNotification给内层UItableView，通知内层UITableView是否可以滑动。

```objective-c
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
```

##三、完整源码下载地址

github下载地址：[https://github.com/yixiangboy/YX_UITableView_IN_UITableView](https://github.com/yixiangboy/YX_UITableView_IN_UITableView)

##四、联系方式

微博：[新浪微博](http://weibo.com/5612984599/profile?topnav=1&wvr=6)

博客：[http://blog.csdn.net/yixiangboy](http://blog.csdn.net/yixiangboy)

github:[https://github.com/yixiangboy](https://github.com/yixiangboy)
















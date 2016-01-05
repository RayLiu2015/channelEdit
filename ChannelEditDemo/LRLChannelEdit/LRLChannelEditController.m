//
//  LRLChannelEditController.m
//  V1_Circle
//
//  Created by 刘瑞龙 on 15/11/2.
//  Copyright © 2015年 com.Dmeng. All rights reserved.
//

#import "TouchView.h"
#import "ChannelUnitModel.h"
#import "LRLChannelEditController.h"

//左右边距
#define EdgeX 5
#define TopEdge 30

//每行频道的个数
#define ButtonCountOneRow 4
#define ButtonHeight (ButtonWidth * 4/9)
#define LocationWidth (ScreenWidth - EdgeX * 2)
#define ButtonWidth (LocationWidth/ButtonCountOneRow)
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define TitleSize 12.0
#define EditTextSize 9.0

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LRLChannelEditController ()
{
    BOOL _isEditing;
    CGPoint _oldCenter;
    NSInteger _moveIndex;
}
@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *topDataSource;
@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *bottomDataSource;

@property (nonatomic, strong) NSMutableArray<TouchView *> *topViewArr;
@property (nonatomic, strong) NSMutableArray<TouchView *> *bottomViewArr;

@property (nonatomic, weak) IBOutlet UILabel *topLabel;
@property (nonatomic, assign) CGFloat topHeight;

@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, assign) CGFloat bottomHeight;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UILabel *editAlertLabel;
@property (nonatomic, strong) TouchView *clearView;
@property (nonatomic, strong) ChannelUnitModel *placeHolderModel;
@property (nonatomic, strong) ChannelUnitModel *touchingModel;

@property (nonatomic, strong) ChannelUnitModel *initialIndexModel;
@property (nonatomic, strong) TouchView *initalTouchView;
@property (nonatomic, assign) NSInteger locationIndex;

@end

@implementation LRLChannelEditController

-(id)initWithTopDataSource:(NSArray<ChannelUnitModel *> *)topDataArr andBottomDataSource:(NSArray<ChannelUnitModel *> *)bottomDataSource andInitialIndex:(NSInteger)initialIndex{
    if (self = [super init]) {
        self.topDataSource = [NSMutableArray arrayWithArray:topDataArr];
        self.bottomDataSource = [NSMutableArray arrayWithArray:bottomDataSource];
        self.locationIndex = initialIndex;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configUI];
}

-(void)configUI{
    self.topViewArr = [NSMutableArray array];
    self.bottomViewArr = [NSMutableArray array];
    self.scrollView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    
    //上面的标题
    self.topLabel.text = @"我的栏目";
    self.topLabel.font = [UIFont boldSystemFontOfSize:TitleSize];
    
    self.editAlertLabel.textColor = UIColorFromRGB(0xc0c0c0);
    self.editAlertLabel.font = [UIFont systemFontOfSize:EditTextSize];
    self.editAlertLabel.hidden = YES;
    
    [self.editButton addTarget:self action:@selector(editOrderAct:) forControlEvents:UIControlEventTouchUpInside];
    
    for (int i = 0; i < self.topDataSource.count; ++i) {
        TouchView *touchView = [[TouchView alloc] initWithFrame:CGRectMake(5 + i%ButtonCountOneRow * ButtonWidth, TopEdge + i/ButtonCountOneRow * ButtonHeight, ButtonWidth, ButtonHeight)];
        touchView.userInteractionEnabled = YES;
        
        ChannelUnitModel *model = self.topDataSource[i];
        touchView.contentLabel.text = model.name;
        if (i < 2) { //位于前两个的频道不添加任何手势, 并且文字颜色为灰色
            touchView.contentLabel.textColor = UIColorFromRGB(0xc0c0c0);
            touchView.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(defaultTopTap:)];
            [touchView addGestureRecognizer:touchView.tap];
        }else{
            touchView.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topTapAct:)];
            [touchView addGestureRecognizer:touchView.tap];
            
            touchView.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topPanAct:)];
            touchView.pan.enabled = NO;
            [touchView addGestureRecognizer:touchView.pan];
            
            touchView.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAct:)];
            [touchView addGestureRecognizer:touchView.longPress];
        }
        
        if (self.locationIndex == i) { //蓝色 //008dff
            touchView.contentLabel.textColor = UIColorFromRGB(0x008dff);
            self.initialIndexModel = self.topDataSource[i];
            self.initalTouchView = touchView;
        }
        
        [self.scrollView addSubview:touchView];
        [self.topViewArr addObject:touchView];
    }
    
    //下面的标题
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,TopEdge + 25 + self.topHeight, 150, 20)];
    self.bottomLabel.textAlignment = NSTextAlignmentLeft;
    self.bottomLabel.text = @"点击添加更过栏目";
    self.bottomLabel.font = [UIFont boldSystemFontOfSize:TitleSize];
    [self.scrollView addSubview:self.bottomLabel];
    
    CGFloat startHeight = self.bottomLabel.frame.origin.y + 20 + 10;
    
    for (int i = 0; i < self.bottomDataSource.count; ++i) {
        TouchView *touchView = [[TouchView alloc] initWithFrame:CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, startHeight + i/ButtonCountOneRow * ButtonHeight, ButtonWidth, ButtonHeight)];
        ChannelUnitModel *model = self.bottomDataSource[i];
        touchView.contentLabel.text = model.name;
        touchView.userInteractionEnabled = YES;
        touchView.contentLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:touchView];
        [self.bottomViewArr addObject:touchView];
        
        touchView.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomTapAct:)];
        [touchView addGestureRecognizer:touchView.tap];
    }
    self.scrollView.contentSize = CGSizeMake(ScreenWidth, 85 + self.topHeight + self.bottomHeight + ButtonHeight);
}
#pragma mark - 重新布局下边
-(void)reconfigBottomView{
    CGFloat startHeight = self.bottomLabel.frame.origin.y + 20 + 10;
    for (int i = 0; i < self.bottomViewArr.count; ++i) {
        TouchView *touchView = self.bottomViewArr[i];
        touchView.frame = CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, startHeight + i/ButtonCountOneRow * ButtonHeight, ButtonWidth, ButtonHeight);
    }
}
#pragma mark - 重新布局上边
-(void)reconfigTopView{
    for (int i = 0; i < self.topViewArr.count; ++i) {
        TouchView *touchView = self.topViewArr[i];
        touchView.frame = CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, TopEdge + i/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
    }
}

#pragma mark - 从上到下
-(void)topTapAct:(UITapGestureRecognizer *)tap{
    TouchView *touchView = (TouchView *)tap.view;
    NSInteger index = [self.topViewArr indexOfObject:touchView];
    if (_isEditing) {
        [self.scrollView bringSubviewToFront:touchView];
        //获取点击view的位置
        [self.bottomViewArr insertObject:touchView atIndex:0];
        [self.topViewArr removeObject:touchView];
        //为了安全, 加判断
        if (index < self.topDataSource.count) {
            ChannelUnitModel *cModel = self.topDataSource[index];
            cModel.isTop = NO;
            [self.bottomDataSource insertObject:cModel atIndex:0];
            [self.topDataSource removeObjectAtIndex:index];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomLabel.frame = CGRectMake(10, TopEdge + 25 + self.topHeight, 200, 20);
            [self reconfigTopView];
            [self reconfigBottomView];
            touchView.closeImageView.hidden = YES;
        }];
        
        [touchView.pan removeTarget:self action:@selector(topPanAct:)];
        [touchView removeGestureRecognizer:touchView.pan];
        touchView.pan = nil;
        
        [touchView.longPress removeTarget:self action:@selector(longTapAct:)];
        [touchView removeGestureRecognizer:touchView.longPress];
        touchView.longPress = nil;
        
        [touchView.tap removeTarget:self action:@selector(topTapAct:)];
        [touchView.tap addTarget:self action:@selector(bottomTapAct:)];
    }else{
        [self returnToHomeWithIndex:index];
    }
}
#pragma mark - 点击上边前两个按钮
-(void)defaultTopTap:(UITapGestureRecognizer *)tap{
    if (!_isEditing) {
        TouchView *touchView = (TouchView *)tap.view;
        NSInteger index = [self.topViewArr indexOfObject:touchView];
        [self returnToHomeWithIndex:index];
    }
}
#pragma mark - 返回到home页面, 带有点击的某个index
-(void)returnToHomeWithIndex:(NSInteger)index{
    if (self.chooseIndexBlock) {
        self.chooseIndexBlock(index, self.topDataSource, self.bottomDataSource);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateTOsql];
    }];
}
#pragma mark - 从下到上
-(void)bottomTapAct:(UITapGestureRecognizer *)tap{
    TouchView *touchView = (TouchView *)tap.view;
    [self.scrollView bringSubviewToFront:touchView];
    NSInteger index = [self.bottomViewArr indexOfObject:touchView];
    [self.topViewArr addObject:touchView];
    [self.bottomViewArr removeObject:touchView];
    //为了安全, 加判断
    if (index < self.bottomDataSource.count) {
        ChannelUnitModel *model = self.bottomDataSource[index];
        model.isTop = YES;
        if (model == self.initialIndexModel) {
            if (_isEditing) {
            }else{
                touchView.contentLabel.textColor = UIColorFromRGB(0x008dff);
            }
        }
        [self.topDataSource addObject:model];
        [self.bottomDataSource removeObject:model];
    }
    
    NSInteger i = self.topViewArr.count - 1;
    [UIView animateWithDuration:0.3 animations:^{
        touchView.frame = CGRectMake(EdgeX + i%ButtonCountOneRow * ButtonWidth, TopEdge + i/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
        self.bottomLabel.frame = CGRectMake(10, TopEdge + 25 + self.topHeight, 200, 20);
        [self reconfigBottomView];
        touchView.closeImageView.hidden = !_isEditing;
    }];
    
    touchView.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topPanAct:)];
    [touchView addGestureRecognizer:touchView.pan];
    touchView.pan.enabled = _isEditing;
    
    touchView.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAct:)];
    [touchView addGestureRecognizer:touchView.longPress];
    
    [touchView.tap removeTarget:self action:@selector(bottomTapAct:)];
    [touchView.tap addTarget:self action:@selector(topTapAct:)];
}

#pragma mark - 拖拽手势
-(void)topPanAct:(UIPanGestureRecognizer *)pan{
    TouchView *touchView = (TouchView *)pan.view;
    [self.scrollView  bringSubviewToFront:touchView];
    static int staticIndex = 0;
    if (pan.state == UIGestureRecognizerStateBegan) {
        [touchView inOrOutTouching:YES];
        //记录移动的label最初的index
        _moveIndex = [self.topViewArr indexOfObject:touchView];
        if (_moveIndex < self.topDataSource.count) {
            self.touchingModel = self.topDataSource[_moveIndex];
        }
        [self.topViewArr removeObject:touchView];
        if (self.touchingModel) {
            [self.topDataSource removeObject:self.touchingModel];
            [self.topDataSource addObject:self.placeHolderModel];
        }
        _oldCenter = touchView.center;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        CGPoint movePoint = [pan translationInView:self.scrollView];
        touchView.center = CGPointMake(_oldCenter.x + movePoint.x, _oldCenter.y + movePoint.y);
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        //没有超出范围
        if (!(x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight  || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth)))) {
            //记录移动过程中label所处的index
            int index = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
            //当index发生改变时, 插入占位的label, 重新布局UI
            if (staticIndex !=index) {
                staticIndex = index;
                if (staticIndex < self.topViewArr.count && staticIndex >= 0) {
                    if ([self.topViewArr containsObject:self.clearView]) {
                        [self.topViewArr removeObject:self.clearView];
                    }
                    [self.topViewArr insertObject:self.clearView atIndex:staticIndex];
                    if (!self.clearView.superview) {
                        [self.scrollView addSubview:self.clearView];
                        [self.scrollView sendSubviewToBack:self.clearView];
                    }
                    self.clearView.frame = CGRectMake(EdgeX + staticIndex%ButtonCountOneRow * ButtonWidth, TopEdge + staticIndex/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
                    [UIView animateWithDuration:0.5 animations:^{
                        [self reconfigTopView];
                    }];
                }else{
                }
            }
        }
    }else if(pan.state == UIGestureRecognizerStateEnded){
        [touchView inOrOutTouching:NO];
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        if (x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth))) {
            NSLog(@"超出范围");
            [UIView animateWithDuration:0.5 animations:^{
                touchView.center = _oldCenter;
            }];
        }else{
            _moveIndex = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
        }
        staticIndex = 0;
        if ([self.topViewArr containsObject:self.clearView]) {
            [self.topViewArr removeObject:self.clearView];
            if (self.clearView.superview) {
                [self.clearView removeFromSuperview];
            }
        }
        if ([self.topDataSource containsObject:self.placeHolderModel]) {
            [self.topDataSource removeObject:self.placeHolderModel];
        }
        if (_moveIndex < self.topViewArr.count && _moveIndex >= 0 ) {
            [self.topViewArr insertObject:touchView atIndex:_moveIndex];
            if (_moveIndex < self.topDataSource.count && self.touchingModel) {
                [self.topDataSource insertObject:self.touchingModel atIndex:_moveIndex];
            }
        }else{
            [self.topViewArr addObject:touchView];
            if (self.touchingModel) {
                [self.topDataSource removeObject:self.placeHolderModel];
                [self.topDataSource addObject:self.touchingModel];
            }
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self reconfigTopView];
        }];
    }else if(pan.state == UIGestureRecognizerStateCancelled){
    }else if(pan.state == UIGestureRecognizerStateFailed){
    }
}
#pragma mark - 长按手势
-(void)longTapAct:(UILongPressGestureRecognizer *)longPress{
    TouchView *touchView = (TouchView *)longPress.view;
    [self.scrollView bringSubviewToFront:touchView];
    static CGPoint touchPoint;
    static CGFloat offsetX;
    static CGFloat offsetY;
    static NSInteger staticIndex = 0;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        _isEditing = YES;
        [touchView inOrOutTouching:YES];
        [self inOrOutEditWithEditing:_isEditing];
        //记录移动的label最初的index
        _moveIndex = [self.topViewArr indexOfObject:touchView];
        if (_moveIndex < self.topDataSource.count) {
            self.touchingModel = self.topDataSource[_moveIndex];
        }
        [self.topViewArr removeObject:touchView];
        if (self.touchingModel) {
            [self.topDataSource removeObject:self.touchingModel];
            [self.topDataSource addObject:self.placeHolderModel];
        }
        _oldCenter = touchView.center;
        
        //这是为了计算手指在Label上的偏移位置
        touchPoint = [longPress locationInView:touchView];
        CGPoint centerPoint = CGPointMake(ButtonWidth/2, ButtonHeight/2);
        offsetX = touchPoint.x - centerPoint.x;
        offsetY = touchPoint.y - centerPoint.y;
        
        CGPoint movePoint = [longPress locationInView:self.scrollView];
        [UIView animateWithDuration:0.1 animations:^{
            touchView.center = CGPointMake(movePoint.x - offsetX, movePoint.y - offsetY);
        }];
    }else if(longPress.state == UIGestureRecognizerStateChanged){
        CGPoint movePoint = [longPress locationInView:self.scrollView];
        touchView.center = CGPointMake(movePoint.x - offsetX, movePoint.y - offsetY);
        
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        //没有超出范围
        if (!(x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth)))) {
            //记录移动过程中label所处的index
            int index = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
            
            //当index发生改变时, 插入占位的label, 重新布局UI
            if (staticIndex !=index) {
                staticIndex = index;
                if (staticIndex < self.topViewArr.count && staticIndex >= 0) {
                    if ([self.topViewArr containsObject:self.clearView]) {
                        [self.topViewArr removeObject:self.clearView];
                    }
                    [self.topViewArr insertObject:self.clearView atIndex:staticIndex];
                    if (!self.clearView.superview) {
                        [self.scrollView addSubview:self.clearView];
                        [self.scrollView sendSubviewToBack:self.clearView];
                    }
                    self.clearView.frame = CGRectMake(EdgeX + staticIndex%ButtonCountOneRow * ButtonWidth, TopEdge + staticIndex/ButtonCountOneRow*ButtonHeight, ButtonWidth, ButtonHeight);
                    [UIView animateWithDuration:0.5 animations:^{
                        [self reconfigTopView];
                    }];
                }else{
                    NSLog(@"计算index 超出范围");
                }
            }
        }
    }else if(longPress.state == UIGestureRecognizerStateEnded){
        [touchView inOrOutTouching:NO];
        CGFloat x = touchView.center.x;
        CGFloat y = touchView.center.y;
        if (x < EdgeX || x > ScreenWidth - EdgeX || y < TopEdge || y > TopEdge + self.topHeight || (y < (TopEdge + ButtonHeight) && x < (EdgeX + 2 * ButtonWidth))) {
            NSLog(@"长按手势结束: 超出范围");
            [UIView animateWithDuration:0.5 animations:^{
                touchView.center = _oldCenter;
            }];
        }else{
            _moveIndex = ((int)((y - TopEdge)/ButtonHeight)) * ButtonCountOneRow + (int)(x - EdgeX)/ButtonWidth;
        }
        staticIndex = 0;
        if ([self.topViewArr containsObject:self.clearView]) {
            [self.topViewArr removeObject:self.clearView];
            if (self.clearView.superview) {
                [self.clearView removeFromSuperview];
            }
        }
        if ([self.topDataSource containsObject:self.placeHolderModel]) {
            [self.topDataSource removeObject:self.placeHolderModel];
        }
        if (_moveIndex < self.topViewArr.count && _moveIndex >= 0) {
            [self.topViewArr insertObject:touchView atIndex:_moveIndex];
            if (_moveIndex < self.topDataSource.count && self.touchingModel) {
                [self.topDataSource insertObject:self.touchingModel atIndex:_moveIndex];
            }
        }else{
            [self.topViewArr addObject:touchView];
            if (self.touchingModel) {
                [self.topDataSource addObject:self.touchingModel];
            }
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self reconfigTopView];
        }];
    }else if(longPress.state == UIGestureRecognizerStateCancelled){
    }else if(longPress.state == UIGestureRecognizerStateFailed){
    }
}

#pragma mark - 用于占位的透明label
-(TouchView *)clearView{
    if (!_clearView) {
        _clearView = [[TouchView alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, ButtonWidth - 10, ButtonHeight - 10)];
        imageView.image = [UIImage imageNamed:@"lanmu2"];
        [_clearView addSubview:imageView];
        _clearView.backgroundColor = [UIColor clearColor];
        [_clearView.contentLabel removeFromSuperview];
    }
    return _clearView;
}
#pragma mark - 用于占位的model, 由于计算位置有问题
-(ChannelUnitModel *)placeHolderModel{
    if (!_placeHolderModel) {
        _placeHolderModel = [[ChannelUnitModel alloc] init];
    }
    return _placeHolderModel;
}
#pragma mark - 充当计算属性使用
-(CGFloat)topHeight{
    if (self.topDataSource.count < ButtonCountOneRow) {
        return ButtonHeight;
    }else{
        return ((self.topDataSource.count - 1)/ButtonCountOneRow + 1) * ButtonHeight;
    }
}
-(CGFloat)bottomHeight{
    if (self.bottomDataSource.count < ButtonCountOneRow) {
        return ButtonHeight;
    }else{
        return ((self.bottomDataSource.count - 1)/ButtonCountOneRow + 1) * ButtonHeight;;
    }
}
#pragma mark - 点击编辑或者完成按钮
-(void)editOrderAct:(UIButton *)button{
    _isEditing = !_isEditing;
    [self inOrOutEditWithEditing:_isEditing];
    if (!_isEditing) { //点击完成
    }
}
#pragma mark - 进入或者退出编辑状态
-(void)inOrOutEditWithEditing:(BOOL)isEditing{
    if (isEditing) {
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"finsh"] forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"finsh-1"] forState:UIControlStateHighlighted];
        
        if (self.initalTouchView) {
            if (self.locationIndex > 1) {
                self.initalTouchView.contentLabel.textColor = UIColorFromRGB(0X333333);
            }else{
                self.initalTouchView.contentLabel.textColor = UIColorFromRGB(0xc0c0c0);
            }
        }
        
        self.editAlertLabel.hidden = NO;
        for (int i = 0; i < self.topViewArr.count; ++i) {
            TouchView *touchView = self.topViewArr[i];
            if (touchView.pan) {
                touchView.pan.enabled = YES;
                touchView.closeImageView.hidden = NO;
            }
        }
    }else{
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"reorder"] forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"reorder-1"] forState:UIControlStateHighlighted];
        
        if (self.initalTouchView && self.initialIndexModel.isTop) {
            self.initalTouchView.contentLabel.textColor = UIColorFromRGB(0x008dff);
        }
        self.editAlertLabel.hidden = YES;
        for (int i = 0; i < self.topViewArr.count; ++i) {
            TouchView *touchView = self.topViewArr[i];
            if (touchView.pan) {
                touchView.pan.enabled = NO;
                touchView.closeImageView.hidden = YES;
            }
        }
    }
}

#pragma mark - 预留的同步到本地的方法
-(void)updateTOsql{
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.topDataSource];
    [arr addObjectsFromArray:self.bottomDataSource];
}

#pragma mark - 点击关闭按钮
- (IBAction)closeButtonAct:(id)sender {
    if (self.initialIndexModel && self.initialIndexModel.isTop) {
        if ([self.topDataSource containsObject:self.initialIndexModel]) {
            if (self.chooseIndexBlock) {
                self.chooseIndexBlock([self.topDataSource indexOfObject:self.initialIndexModel], self.topDataSource, self.bottomDataSource);
            }
        }
    }else{
        if (self.removeInitialIndexBlock) {
            self.removeInitialIndexBlock(self.topDataSource, self.bottomDataSource);
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateTOsql];
    }];
}

@end

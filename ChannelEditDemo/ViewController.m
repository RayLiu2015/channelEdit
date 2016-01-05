//
//  ViewController.m
//  ChannelEditDemo
//
//  Created by liuRuiLong on 16/1/5.
//  Copyright © 2016年 liuRuiLong. All rights reserved.
//

#import "LRLChannelEditController.h"
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *topChannelArr;

@property (nonatomic, strong) NSMutableArray<ChannelUnitModel *> *bottomChannelArr;

@property (nonatomic, assign) NSInteger chooseIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(NSMutableArray<ChannelUnitModel *> *)topChannelArr{
    if (!_topChannelArr) {
        //这里模拟从本地获取的频道数组
        _topChannelArr = [NSMutableArray array];
        for (int i = 0; i < 50; ++i) {
            ChannelUnitModel *channelModel = [[ChannelUnitModel alloc] init];
            channelModel.name = [NSString stringWithFormat:@"标题%d", i];
            channelModel.cid = [NSString stringWithFormat:@"%d", i];
            channelModel.isTop = YES;
            [_topChannelArr addObject:channelModel];
        }
    }
    return _topChannelArr;
}
-(NSMutableArray<ChannelUnitModel *> *)bottomChannelArr{
    if (!_bottomChannelArr) {
        _bottomChannelArr = [NSMutableArray array];
        for (int i = 30; i < 50; ++i) {
            ChannelUnitModel *channelModel = [[ChannelUnitModel alloc] init];
            channelModel.name = [NSString stringWithFormat:@"标题%d", i];
            channelModel.cid = [NSString stringWithFormat:@"%d", i];
            channelModel.isTop = NO;
            [_bottomChannelArr addObject:channelModel];
        }

    }
    return _bottomChannelArr;
}

#pragma mark - 跳转都频道编辑页面
- (IBAction)goToTheChannelEdit:(id)sender {
    LRLChannelEditController *channelEdit = [[LRLChannelEditController alloc] initWithTopDataSource:self.topChannelArr andBottomDataSource:self.bottomChannelArr andInitialIndex:self.chooseIndex];
    
    //编辑后的回调
    __weak ViewController *weakSelf = self;
    channelEdit.removeInitialIndexBlock = ^(NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr){
        weakSelf.topChannelArr = topArr;
        weakSelf.bottomChannelArr = bottomArr;
        NSLog(@"删除了初始选中项的回调:\n保留的频道有: %@", topArr);
    };
    channelEdit.chooseIndexBlock = ^(NSInteger index, NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr){
        weakSelf.topChannelArr = topArr;
        weakSelf.bottomChannelArr = bottomArr;
        weakSelf.chooseIndex = index;
        NSLog(@"选中了某一项的回调:\n保留的频道有: %@, 选中第%ld个频道", topArr, index);
    };
    
    channelEdit.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:channelEdit animated:YES completion:nil];
}

@end

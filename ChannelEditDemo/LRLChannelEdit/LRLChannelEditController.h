//
//  LRLChannelEditController.h
//  V1_Circle
//
//  Created by 刘瑞龙 on 15/11/2.
//  Copyright © 2015年 com.Dmeng. All rights reserved.
//

#import "ChannelUnitModel.h"

#import <UIKit/UIKit.h>

@interface LRLChannelEditController : UIViewController

-(id)initWithTopDataSource:(NSArray<ChannelUnitModel *> *)topDataArr andBottomDataSource:(NSArray<ChannelUnitModel *> *)bottomDataSource andInitialIndex:(NSInteger)initialIndex;

/**
 * @b 编辑后, 删除初始选中项排序的回调
 */
@property (nonatomic, copy) void(^removeInitialIndexBlock)(NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr);

/**
 * @b 选中某一个频道回调
 */
@property (nonatomic, copy) void(^chooseIndexBlock)(NSInteger index, NSMutableArray<ChannelUnitModel *> *topArr, NSMutableArray<ChannelUnitModel *> *bottomArr);

@end

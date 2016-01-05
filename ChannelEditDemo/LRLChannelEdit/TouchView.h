//
//  TouchView.h
//  V1_Circle
//
//  Created by 刘瑞龙 on 15/11/2.
//  Copyright © 2015年 com.Dmeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchView : UIView

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *closeImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

-(void)inOrOutTouching:(BOOL)inOrOut;

@end

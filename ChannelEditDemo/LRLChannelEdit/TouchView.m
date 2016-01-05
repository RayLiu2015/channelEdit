//
//  TouchView.m
//  V1_Circle
//
//  Created by 刘瑞龙 on 15/11/2.
//  Copyright © 2015年 com.Dmeng. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

-(float)getTextSizeWithInOrOut:(BOOL)inOrOut{
    if (inOrOut) {
        return 15.0;
    }else{
        return 12.0;
    }
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10)];
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0];

        self.contentLabel.font = [UIFont systemFontOfSize:[self getTextSizeWithInOrOut:NO]];
        self.contentLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        [self addSubview:self.contentLabel];
        
        self.closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 16.5, 1.5, 15, 15)];
        self.closeImageView.hidden = YES;
        self.closeImageView.image = [UIImage imageNamed:@"del"];
        [self addSubview:self.closeImageView];
    }
    return self;
}

-(void)inOrOutTouching:(BOOL)inOrOut{
    if (inOrOut) {
        self.contentLabel.frame = self.bounds;
        self.contentLabel.font = [UIFont systemFontOfSize:[self getTextSizeWithInOrOut:YES]];
        self.backgroundColor = self.contentLabel.backgroundColor;
        self.alpha = 0.7;
        self.contentLabel.alpha = 0.7;
    }else{
        self.contentLabel.frame = CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10);
        self.contentLabel.font = [UIFont systemFontOfSize:[self getTextSizeWithInOrOut:NO]];
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1.0;
        self.contentLabel.alpha = 1.0;
    }
}
@end

//
//  UIImage+LRLBundle.m
//  ChannelEditDemo
//
//  Created by liuRuiLong on 2017/5/21.
//  Copyright © 2017年 liuRuiLong. All rights reserved.
//

#import "UIImage+LRLBundle.h"

@implementation UIImage(MyBundle)

+(UIImage *)imageMyBundleNamed:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:[@"LRLChannelEdit.bundle" stringByAppendingPathComponent:imageName]];
    if (image) {
        return image;
    } else {
        image = [UIImage imageNamed:[@"Frameworks/LRLChannelEdit.framework/LRLChannelEdit.bundle" stringByAppendingPathComponent:imageName]];
        if (!image) {
            image = [UIImage imageNamed:imageName];
        }
        return image;
    }
}

@end


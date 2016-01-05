//
//  ChannelUnitModel.m
//  V1_Circle
//
//  Created by 刘瑞龙 on 15/11/10.
//  Copyright © 2015年 com.Dmeng. All rights reserved.
//

#import <objc/runtime.h>
#import "ChannelUnitModel.h"

@implementation ChannelUnitModel
-(NSString *)description{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(self.class, &count);
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < count; ++i) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *proName = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:proName];
        
        [str appendFormat:@"<%@ : %@> \n", proName, value];
    }
    free(ivars);
    return str;
}
@end

//
//  MultiProcCounterHelper.m
//  MultiProcCounterHelper
//
//  Created by Christian Tietze on 19/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

#import "MultiProcCounterHelper.h"

@implementation MultiProcCounterHelper

- (void)currentCountWithReply:(void (^)(NSUInteger))reply
{
    reply(1337);
}

@end

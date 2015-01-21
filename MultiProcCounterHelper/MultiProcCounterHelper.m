//
//  MultiProcCounterHelper.m
//  MultiProcCounterHelper
//
//  Created by Christian Tietze on 19/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

#import "MultiProcCounterHelper.h"

@implementation MultiProcCounterHelper

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
    NSString *response = [aString uppercaseString];
    reply(response);
}

@end

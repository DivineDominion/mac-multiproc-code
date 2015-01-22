//
//  ProvidesCounts.h
//  MultiProcCounterHelper
//
//  Created by Christian Tietze on 19/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProvidesCounts
- (void)currentCountWithReply:(void (^)(NSUInteger))reply;
@end

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"MultiProcCounterHelper"];
     _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(StringModifing)];
     [_connectionToService resume];

Once you have a connection to the service, you can use it like this:

     [[_connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
         // We have received a response. Update our text field, but do it on the main thread.
         NSLog(@"Result string was: %@", aString);
     }];

 And, when you are finished with the service, clean up the connection like this:

     [_connectionToService invalidate];
*/

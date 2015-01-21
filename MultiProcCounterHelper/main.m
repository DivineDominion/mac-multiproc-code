//
//  main.m
//  MultiProcCounterHelper
//
//  Created by Christian Tietze on 19/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiProcCounterHelper.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(MultiProcCounterHelperProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    MultiProcCounterHelper *exportedObject = [MultiProcCounterHelper new];
    newConnection.exportedObject = exportedObject;
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

@end

int main(int argc, const char *argv[])
{
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:bundleId];
    ServiceDelegate *delegate = [ServiceDelegate new];
    listener.delegate = delegate;
    
    [listener resume];
    [[NSRunLoop currentRunLoop] run];
    
    return 0;
}

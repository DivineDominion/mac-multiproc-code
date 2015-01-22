//
//  MultiProcCounterHelper.h
//  MultiProcCounterHelper
//
//  Created by Christian Tietze on 19/01/15.
//  Copyright (c) 2015 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProvidesCounts.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface MultiProcCounterHelper : NSObject <ProvidesCounts>
@end

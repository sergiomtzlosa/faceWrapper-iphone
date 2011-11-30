//
//  NSThread+Blocks.m
//  Precio Casa
//
//  Created by Sergio on 16/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSThread+Blocks.h"

@interface NSThread (Private)

+ (void)executeThread:(void (^)(void))blockExecution;

@end

@implementation NSThread (Private)

+ (void)executeThread:(void (^)(void))blockExecution
{
    blockExecution();
}

@end

@implementation NSThread (Blocks)

+ (void)detachNewThreadSelectorWithBlock:(void (^)(void))block
{
    void (^auxBlock)(void) = [block copy];

    [NSThread detachNewThreadSelector:@selector(executeThread:)  
                             toTarget:self
                           withObject:auxBlock];
}

@end
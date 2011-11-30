//
//  NSObject+AsyncBlock.m
//  Precio Casa
//
//  Created by Sergio on 14/11/11.
//  Copyright (c) 2011 Sergio.com. All rights reserved.
//

#import "NSObject+Block.h"

@implementation NSObject (Block)

+ (void)performBlockInBackground:(void (^)(void))block
{
    void (^blockKit)(void) = [block copy];
    
    [self performSelectorInBackground:@selector(executorBlock:) withObject:blockKit];
}

- (void)executorBlock:(void (^)(void))blockExec
{
    blockExec();
}

+ (void)performBlockOnMainThread:(void (^)(void))block
{
    void (^blockKit)(void) = [block copy];
    
    [self performSelectorOnMainThread:@selector(executorBlock:) withObject:blockKit waitUntilDone:YES];
}

+ (id)performBlockInBackgroundReturningValue:(void (^)(void))block
{
    @autoreleasepool
    {
        id (^blockAuxiliar)(void) = [block copy];
        
        return blockAuxiliar();
    }
}

+ (id)performBlockOnMainThreadReturningValue:(void (^)(void))block
{
    id (^blockAuxiliar)(void) = [block copy];
    
    return blockAuxiliar();
}

@end
//
//  NSObject+AsyncBlock.h
//  Precio Casa
//
//  Created by Sergio on 14/11/11.
//  Copyright (c) 2011 Sergio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Block)

+ (void)performBlockInBackground:(void (^)(void))block;

+ (void)performBlockOnMainThread:(void (^)(void))block;

+ (id)performBlockInBackgroundReturningValue:(void (^)(void))block;

+ (id)performBlockOnMainThreadReturningValue:(void (^)(void))block;

@end
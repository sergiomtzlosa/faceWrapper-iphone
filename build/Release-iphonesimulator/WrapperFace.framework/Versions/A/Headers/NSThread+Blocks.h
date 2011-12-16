//
//  NSThread+Blocks.h
//  Precio Casa
//
//  Created by Sergio on 16/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (Blocks)

+ (void)detachNewThreadSelectorWithBlock:(void (^)(void))block;

@end

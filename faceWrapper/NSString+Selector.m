//
//  NSString+Selector.m
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSString+Selector.h"

@implementation NSString (Selector)

- (void)selectorDidRespondInClass:(id)delegate execute:(void (^)(void))block
{
    ([delegate respondsToSelector:NSSelectorFromString(self)]) ? block() : nil;
}

@end

//
//  TypeChecker.m
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSArray+TypeChecker.h"

@implementation NSArray (TypeChecker)

- (BOOL)arrayIsTypeOf:(Class)type
{
    for (id object in self)
    {
        if (![object isKindOfClass:type]) 
        {
            return NO;
        }
    }

    return YES;
}

@end

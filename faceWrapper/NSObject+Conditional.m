//
//  NSObject+Conditional.m
//  faceWrapper
//
//  Created by Sergio on 29/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSObject+Conditional.h"

@implementation NSObject (Conditional)

+ (void)ifEvaluate:(BOOL)condition isTrue:(void (^)(void))trueBlock isFalse:(void (^)(void))falseBlock
{
    (condition) ? trueBlock() : falseBlock();
}

@end

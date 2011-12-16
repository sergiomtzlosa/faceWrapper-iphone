//
//  NSObject+Conditional.h
//  faceWrapper
//
//  Created by Sergio on 29/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Conditional)

+ (void)ifEvaluate:(BOOL)condition isTrue:(void (^)(void))trueBlock isFalse:(void (^)(void))falseBlock;

@end

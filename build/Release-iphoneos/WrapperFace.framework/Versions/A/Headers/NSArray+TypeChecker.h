//
//  TypeChecker.h
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TypeChecker)

- (BOOL)arrayIsTypeOf:(Class)type;

@end

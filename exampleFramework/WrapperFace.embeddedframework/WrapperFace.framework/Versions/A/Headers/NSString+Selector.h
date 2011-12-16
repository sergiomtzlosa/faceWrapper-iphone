//
//  NSString+Selector.h
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Selector)

- (void)selectorDidRespondInClass:(id)delegate execute:(void (^)(void))block;

@end

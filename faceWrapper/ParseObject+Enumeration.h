//
//  ParseObject+Enumeration.h
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "ParseObject.h"

@interface ParseObject (Enumeration)

- (void)loopOverFaces:(void (^)(NSDictionary *))facesArray;

@end

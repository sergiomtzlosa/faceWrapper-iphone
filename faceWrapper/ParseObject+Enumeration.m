//
//  ParseObject+Enumeration.m
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "ParseObject+Enumeration.h"

@implementation ParseObject (Enumeration)

- (void)loopOverFaces:(void (^)(NSDictionary *))facesArray
{
    for (NSDictionary *face in self.rootObject) 
    {
        facesArray(face);
    }
}

@end

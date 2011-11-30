//
//  NSMutableArray+NURL.m
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSMutableArray+Objects.h"

@implementation NSMutableArray (Objects)

- (void)addURLsToArray:(NSURL *)url
{
    [self addObject:url];
}

- (void)addAttributeToArray:(ATTRIBUTE)attribute
{    
    [self addObject:[NSNumber numberWithInt:attribute]];
}

- (void)addImageToArray:(NSURL *)imageURL
{
    [self addObject:imageURL];
}

- (void)addImagePOSTToArray:(FWImage *)image
{
    [self addObject:image];
}

@end

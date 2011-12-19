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

- (void)addTidToArray:(int)tid
{    
    [self addObject:[NSNumber numberWithInt:tid]];
}

- (void)addImageToArray:(NSURL *)imageURL
{
    [self addObject:imageURL];
}

- (void)addImagePOSTToArray:(FWImage *)image
{
    [self addObject:image];
}

- (void)addUIDsToArray:(NSString *)uid
{
    [self addObject:uid];
}

@end

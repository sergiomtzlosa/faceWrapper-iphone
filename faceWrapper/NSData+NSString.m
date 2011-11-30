//
//  NSData+NSData_NSString.m
//  Precio Casa
//
//  Created by Sergio on 18/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSData+NSString.h"

@implementation NSString (Cast)

- (void)castToDataUTF8:(void (^)(NSData *))completion
{
    completion([self dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)castToDataASCII:(void (^)(NSData *))completion
{
    completion([self dataUsingEncoding:NSASCIIStringEncoding]);
}

@end

@implementation NSData (Cast)

- (void)castToStringUTF8:(void (^)(NSString *))completion
{
    completion([[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding]);
}

- (void)castToStringASCII:(void (^)(NSString *))completion
{
    completion([[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding]);
}

@end
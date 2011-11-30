//
//  NSObject+URLDownload.h
//  Precio Casa
//
//  Created by Sergio on 15/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (URLDownload)

+ (NSData *)downloadURLWithString:(NSString *)stringURL;

+ (void)downloadURLWithString:(NSString *)stringURL completion:(void (^)(NSData *data))completion;

+ (void)downloadURLWithStringWithStatus:(NSString *)stringURL completion:(void (^)(NSData *data, int status))completion;

@end

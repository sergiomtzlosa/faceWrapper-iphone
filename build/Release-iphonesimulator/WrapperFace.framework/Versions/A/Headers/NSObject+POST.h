//
//  NSObject+POST.h
//  faceWrapper
//
//  Created by Sergio on 29/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (POST)

+ (void)sendPOSTWithURL:(NSURL *)url withParams:(NSString *)params images:(NSArray *)images completion:(void (^)(NSData *))block;

@end

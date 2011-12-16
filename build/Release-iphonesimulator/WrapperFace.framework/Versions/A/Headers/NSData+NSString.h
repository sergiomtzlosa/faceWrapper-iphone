//
//  NSData+NSData_NSString.h
//  Precio Casa
//
//  Created by Sergio on 18/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Cast)

- (void)castToDataUTF8:(void (^)(NSData *))completion;

- (void)castToDataASCII:(void (^)(NSData *))completion;

@end

@interface NSData (Cast)

- (void)castToStringUTF8:(void (^)(NSString *))completion;

- (void)castToStringASCII:(void (^)(NSString *))completion;

@end

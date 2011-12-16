//
//  ParseObject.h
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseObject : NSObject
{
    NSDictionary *rawDictionary;
    NSArray *rootObject;
}

+ (void)printObject:(id)object;
- (id)initWithRawDictionary:(NSDictionary *)raw;

@property (nonatomic, strong) NSArray *rootObject;
@property (nonatomic, strong) NSDictionary *rawDictionary;

@end

//
//  FaceWrapper.h
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+Objects.h"
#import "NSString+Selector.h"
#import "NSArray+TypeChecker.h"
#import "FWObject.h"
#import "FWImage.h"
#import "Constants.h"

@interface FaceWrapper : NSObject

+ (FaceWrapper *)instance;

+ (void)throwExceptionWithName:(NSString *)name reason:(NSString *)reason;

+ (NSDictionary *)parseFaceXML:(NSData *)xml;

- (void)detectFaceWithFWObject:(FWObject *)object 
               runInBackground:(BOOL)background
                completionData:(void (^)(NSDictionary *, int))block;

@end

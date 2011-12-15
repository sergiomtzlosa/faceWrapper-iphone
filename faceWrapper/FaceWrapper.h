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
#import "NSObject+Block.h"
#import "NSThread+Blocks.h"
#import "Constants.h"
#import "FBGetterManager.h"

@protocol FaceWrapperDelegate <NSObject>
@optional

- (void)faceWrapperTrainFaceSuccess:(NSDictionary *)faceData photoTag:(int)tag;
- (void)faceWrapperStatusFacing:(NSDictionary *)faceData photoTag:(int)tag;

@end

@interface FaceWrapper : NSObject

+ (FaceWrapper *)instance;

+ (void)throwExceptionWithName:(NSString *)name reason:(NSString *)reason;

+ (NSDictionary *)parseFaceXML:(NSData *)xml;

- (void)detectFaceWithFWObject:(FWObject *)object 
               runInBackground:(BOOL)background
                completionData:(void (^)(NSDictionary *, int))block;

- (void)trainFaceWithFWObject:(FWObject *)object 
                     delegate:(id<FaceWrapperDelegate>)delegate
              runInBackground:(BOOL)background;

- (void)statusFaceWithFWObject:(FWObject *)object delegate:(id<FaceWrapperDelegate>)delegate;

@end

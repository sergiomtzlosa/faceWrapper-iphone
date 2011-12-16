//
//  FBGetter.h
//  faceWrapper
//
//  Created by sid on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBGetterObject.h"

@interface FBGetterManager : NSObject

+ (NSNumber *)objectFromFBAttribute:(FBATTRIBUTE)attr;

+ (void)requestForFacebookWithObject:(FBGetterObject *)object completionBlock:(void (^)(NSDictionary *))block;

@end

//
//  NSMutableArray+NURL.h
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWObject.h"
#import "FWImage.h"

@interface NSMutableArray (Objects)

- (void)addURLsToArray:(NSURL *)url;
- (void)addAttributeToArray:(ATTRIBUTE)attribute;
- (void)addImageToArray:(NSURL *)imageURL;
- (void)addImagePOSTToArray:(FWImage *)image;
- (void)addUIDsToArray:(NSString *)uid;
- (void)addTidToArray:(NSString *)tid;

@end

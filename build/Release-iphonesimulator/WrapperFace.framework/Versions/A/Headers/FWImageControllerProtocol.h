//
//  adasd.h
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FWImageControllerDelegate <NSObject>
@required

- (void)controllerDidFindFaceItemWithObject:(NSDictionary *)faces postImageTag:(int)tag;
- (void)controllerDidRecognizeFaceItemWithObject:(NSDictionary *)faces postImageTag:(int)tag;

@end

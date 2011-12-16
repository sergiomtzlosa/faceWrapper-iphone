//
//  FWImageController.h
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FaceWrapper.h"
#import "FWImageControllerProtocol.h"
#import "ParseObject.h"
#import "ParseObject+Enumeration.h"
#import "FWAccount.h"
#import "FWKeysHelper.h"

@interface FWImageController : UIViewController
{
    NSArray *objects;
    id delegate;
    
@private
    UIImageView *imageView;
}

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, retain) id<FWImageControllerDelegate> delegate;

@end

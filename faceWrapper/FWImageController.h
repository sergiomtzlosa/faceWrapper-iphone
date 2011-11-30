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

@interface FWImageController : UIViewController
{
    FWObject *object;
    id delegate;
    
@private
    UIImageView *imageView;
}

@property (nonatomic, strong) FWObject *object;
@property (nonatomic, retain) id<FWImageControllerDelegate> delegate;

@end

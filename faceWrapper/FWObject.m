//
//  FWObject.m
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FWObject.h"

@implementation FWObject
@synthesize urls;
@synthesize detector;
@synthesize attributes;
@synthesize format;
@synthesize callback;
@synthesize callback_url;
@synthesize isRESTObject;
@synthesize postImages;

- (id)init
{
    if ((self = [super init])) 
    {
        
    }
    
    return self;
}

@end

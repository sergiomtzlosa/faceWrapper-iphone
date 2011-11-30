//
//  FWImage.m
//  faceWrapper
//
//  Created by Sergio on 29/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FWImage.h"

@implementation FWImage
@synthesize imageName;
@synthesize extension;
@synthesize data;
@synthesize pathPostImage;

- (id)initWithURL:(NSURL *)_urlImage imageName:(NSString *)_imageName extension:(NSString *)_extension
{
    if ((self = [super init]))
    {
        self.imageName = _imageName;
        self.extension = _extension;
        self.data = [NSData dataWithContentsOfURL:_urlImage];
    }
    
    return self;
}

- (id)initWithData:(NSData *)dataImage imageName:(NSString *)_imageName extension:(NSString *)_extension andFullPath:(NSString *)fullPath
{
    if ((self = [super init]))
    {
        self.imageName = _imageName;
        self.extension = _extension;
        self.data = dataImage;
        self.pathPostImage = fullPath;
    }
    
    return self;
}

@end

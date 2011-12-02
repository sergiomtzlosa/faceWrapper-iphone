//
//  FWImage.h
//  faceWrapper
//
//  Created by Sergio on 29/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FWImage : UIImage
{
    NSString *imageName;
    NSString *extension;
    NSData *data;
    NSString *pathPostImage;
    int tag;
}

- (id)initWithURL:(NSURL *)urlImage imageName:(NSString *)imageName extension:(NSString *)extension;
- (id)initWithData:(NSData *)dataImage imageName:(NSString *)_imageName extension:(NSString *)_extension andFullPath:(NSString *)fullPath;

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *pathPostImage;
@property (nonatomic) int tag;

@end
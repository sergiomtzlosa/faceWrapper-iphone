//
//  FWObject.h
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    DETECTOR_TYPE_DEFAULT = 0,
    DETECTOR_TYPE_NORMAL = 1,
    DETECTOR_TYPE_AGGRESSIVE = 2
}DETECTOR_TYPE;

typedef enum
{
    FORMAT_TYPE_JSON = 0,
    FORMAT_TYPE_XML = 1
}FORMAT_TYPE;

typedef enum
{
    ATTRIBUTE_ALL = 0,
    ATTRIBUTE_NONE = 1,
    ATTRIBUTE_GENDER = 2,
    ATTRIBUTE_GLASSES = 3,
    ATTRIBUTE_SMILING = 4
}ATTRIBUTE;

@interface FWObject : NSObject
{
    FORMAT_TYPE format;
    NSArray *urls;
    DETECTOR_TYPE detector;
    NSMutableArray *attributes;
    NSString *callback;
    NSURL *callback_url;
    BOOL isRESTObject;
    NSMutableArray *postImages;
}

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic) DETECTOR_TYPE detector;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic) FORMAT_TYPE format;
@property (nonatomic, strong) NSString *callback;
@property (nonatomic, strong) NSURL *callback_url;
@property (nonatomic) BOOL isRESTObject;
@property (nonatomic, strong) NSMutableArray *postImages;

@end

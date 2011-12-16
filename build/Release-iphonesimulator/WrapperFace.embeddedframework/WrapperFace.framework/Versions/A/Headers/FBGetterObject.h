//
//  FBGetterObject.h
//  faceWrapper
//
//  Created by sid on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWObject.h"

typedef enum
{
    ORDER_RECENT = 0,
    ORDER_RANDOM = 1,
    ORDER_DEFAULT = 2,
}ORDER;

typedef enum
{
    LIMIT_DEFAULT = 5,
}LIMIT;

typedef enum
{
    FBATTRIBUTE_YAW_LEFT = 5,
    FBATTRIBUTE_YAW_RIGHT = 6,
    FBATTRIBUTE_YAW_CENTER = 7,
    FBATTRIBUTE_YAW_RANGE = 8,
    
    FBATTRIBUTE_ROLL_LEFT = 9,
    FBATTRIBUTE_ROLL_RIGHT = 10,
    FBATTRIBUTE_ROLL_CENTER = 11,
    FBATTRIBUTE_ROLL_RANGE = 12,
    
    FBATTRIBUTE_PITCH_LEFT = 13,
    FBATTRIBUTE_PITCH_RIGHT = 14,
    FBATTRIBUTE_PITCH_CENTER = 15,
    FBATTRIBUTE_PITCH_RANGE = 16,
    
    FBATTRIBUTE_SIZE_RANGE = 17,
    
    FBATTRIBUTE_GENDER_FEMALE = 18,
    FBATTRIBUTE_GENDER_MALE = 19,
    FBATTRIBUTE_GLASSES_TRUE = 20,
    FBATTRIBUTE_GLASSES_FALSE = 21,
    FBATTRIBUTE_SMILING_TRUE = 22,
    FBATTRIBUTE_SMILING_FALSE = 23,
    
}FBATTRIBUTE;

@interface FBGetterObject : FWObject <NSMutableCopying>
{
    ORDER order;
    int limit;
    BOOL together;
    FBATTRIBUTE attribute;
    CGPoint yawRange;
    CGPoint rollRange;
    CGPoint pitchRange;
    CGPoint sizeRange; //in pixels
    
    NSArray *smilingUDIDs;
}

+ (FBGetterObject *)objectWithObject:(FBGetterObject *)object;
- (id)initWithFWObject:(FWObject *)fwObject;

@property (nonatomic) ORDER order;
@property (nonatomic) int limit;
@property (nonatomic) BOOL together;
@property (nonatomic) FBATTRIBUTE attribute;
@property (nonatomic) CGPoint sizeRange;
@property (nonatomic) CGPoint yawRange;
@property (nonatomic) CGPoint rollRange;
@property (nonatomic) CGPoint pitchRange;
@property (nonatomic, retain) NSArray *smilingUDIDs;

@end

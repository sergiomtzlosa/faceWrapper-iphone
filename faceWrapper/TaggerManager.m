//
//  TaggerManager.m
//  faceWrapper
//
//  Created by macpocket1 on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TaggerManager.h"

@implementation TaggerManager

+ (TaggerManager *)sharedInstance
{
    static dispatch_once_t pred;
    static TaggerManager *singleton;
    dispatch_once(&pred, ^{
        
        singleton = [[TaggerManager alloc] init];
    });
    
    return singleton;
}

- (void)saveTagWithObject:(FWObject *)object delegate:(id<TaggerManagerDelegate>)delegate
{
    //REST
}

- (void)addTagWithObject:(FWObject *)object delegate:(id<TaggerManagerDelegate>)delegate
{
    //REST
}

- (void)getTagsWithObject:(FWObject *)object delegate:(id<TaggerManagerDelegate>)delegate
{
    //REST or POST
}

- (void)removeTagWithObject:(FWObject *)object delegate:(id<TaggerManagerDelegate>)delegate
{
    //REST
}

@end

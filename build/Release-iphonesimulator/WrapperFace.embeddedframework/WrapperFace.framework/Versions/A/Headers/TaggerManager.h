//
//  TaggerManager.h
//  faceWrapper
//
//  Created by Sergio on 07/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWObject.h"

typedef void (^Block)(NSDictionary *);

typedef enum
{
    TAG_ACTION_SAVE = 0,
    TAG_ACTION_REMOVE = 1
}TAG_ACTION;

@interface TaggerManager : NSObject

+ (TaggerManager *)sharedInstance;
- (void)actionTagWithObject:(FWObject *)object doAction:(TAG_ACTION)action blockCompletion:(Block)completion;
- (void)addTagWithObject:(FWObject *)object blockCompletion:(Block)completion;
- (void)getTagsWithObject:(FWObject *)object blockCompletion:(Block)completion;

@end

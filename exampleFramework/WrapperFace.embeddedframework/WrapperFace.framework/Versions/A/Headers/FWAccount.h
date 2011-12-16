//
//  FWAccount.h
//  faceWrapper
//
//  Created by Sergio on 02/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWObject.h"

@interface FWAccount : NSObject

+ (NSDictionary *)namespacesFromCurrentAccount;

+ (NSDictionary *)limitsFromCurrentAccount;

+ (NSDictionary *)usersFromCurrentAccountForNameSpaces:(NSArray *)namespaces;

@end

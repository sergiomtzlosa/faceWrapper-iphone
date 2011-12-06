//
//  FacebookManager.h
//  faceWrapper
//
//  Created by sid on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FbGraph.h"

@interface FacebookManager : NSObject <UIWebViewDelegate>
{
@private
    NSString *userId;
    NSString *accessToken;
    FbGraph *fbGraph;
}

+ (FacebookManager *)instance;
- (void)requestTokenWithcompletion:(void (^)(NSString *, NSString *))blockCompletion;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) FbGraph *fbGraph;

@end

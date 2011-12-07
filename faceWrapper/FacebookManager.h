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
    BOOL train, simple, status;
}

+ (FacebookManager *)instance;
- (void)requestToken;
- (void)responseBlockForStatus:(void (^)(NSString *, NSString *))blockCompletion;
- (void)responseBlockForTrain:(void (^)(NSString *, NSString *))blockCompletion;
- (void)requestTokenWithcompletion:(void (^)(NSString *, NSString *))simpleBlock;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) FbGraph *fbGraph;
@property (nonatomic) BOOL train;
@property (nonatomic) BOOL simple;
@property (nonatomic) BOOL status;
@end

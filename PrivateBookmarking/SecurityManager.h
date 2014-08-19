//
//  SecurityManager.h
//  PrivateBookmarking
//
//  Created by alexbutenko on 7/21/14.
//  Copyright (c) 2014 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^onAddedToKeychainBlockType)();

@interface SecurityManager : NSObject

@property (readonly, nonatomic) NSString *errorMessage;
@property (copy, nonatomic) onAddedToKeychainBlockType onAdded;

- (BOOL)canEvaluatePolicy;
- (void)evaluatePolicyWithCompletion:(void(^)(BOOL result, NSError *error))completionBlock;

@end

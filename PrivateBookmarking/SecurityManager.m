//
//  SecurityManager.m
//  PrivateBookmarking
//
//  Created by alexbutenko on 7/21/14.
//  Copyright (c) 2014 alex. All rights reserved.
//

#import "SecurityManager.h"

@import LocalAuthentication;

@implementation SecurityManager

//Why I don't use swift? http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift
- (id)init {
    self = [super init];
    
    if (self) {
        CFErrorRef error = NULL;
        
        // Should be the secret invalidated when passcode is removed? If not then use kSecAttrAccessibleWhenUnlocked
        SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                    kSecAccessControlUserPresence, &error);
        if(sacObject == NULL || error != NULL) {
            NSLog(@"can't create sacObject: %@", error);
        }
        
        // we want the operation to fail if there is an item which needs authenticaiton so we will use
        // kSecUseNoAuthenticationUI
        NSDictionary *attributes = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                     (__bridge id)kSecAttrService: [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey],
                                     (__bridge id)kSecValueData: [@"12345" dataUsingEncoding:NSUTF8StringEncoding],
                                     (__bridge id)kSecUseNoAuthenticationUI: @YES,
                                     (__bridge id)kSecAttrAccessControl: (__bridge id)sacObject};
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            OSStatus status =  SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
            
            [self updateErrorMessageWithStatus:status];
            
            if (self.onAdded) {
                self.onAdded();
            }
        });
    }
    
    return self;
}

- (void)updateErrorMessageWithStatus: (NSInteger)status
{
    switch (status) {
        case errSecSuccess:
            NSLog(@"added successfully");
            break;
        case errSecDuplicateItem:
            _errorMessage = @"Item already exists";
            break;
        case errSecItemNotFound :
            _errorMessage = @"Item not found";
            break;
        case -26276: // this error will be replaced by errSecAuthFailed
            _errorMessage = @"Item authentication failed";
            break;
            
        case -25308:
            _errorMessage = @"Interaction is not allowed";
            break;
            
        default:
            _errorMessage = @"unknown error";
            break;
    }
    
    NSLog(@"error %@", _errorMessage);
}

- (BOOL)canEvaluatePolicy
{
    NSError *error;
    BOOL success = NO;
    
    @try {
        LAContext *context = [[LAContext alloc] init];
        
        // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
        success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    }
    @catch (NSException *exception) {
        success = NO;
    }
    @finally {
        return success;
    }
}

- (void)evaluatePolicyWithCompletion:(void(^)(BOOL result, NSError *error))completionBlock
{
    LAContext *context = [[LAContext alloc] init];
    
    // show the authentication UI with our reason string
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Unlock access to locked feature"
                      reply:
     ^(BOOL success, NSError *authenticationError) {
         completionBlock(success, authenticationError);
     }];
}

@end

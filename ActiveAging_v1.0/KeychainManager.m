//
//  KeychainManager.m
//  TestActiveAging
//
//  Created by Kwok Ping Lau on 1/15/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "KeychainManager.h"
#import "UserInfo.h"

static KeychainManager * _keyManager = nil;

@implementation KeychainManager{
    UserInfo * _userInfo;
}

#pragma mark - PUBLIC_METHODS
+ (instancetype) sharedInstance{
    if (_keyManager == nil){
        _keyManager = [KeychainManager new];
    }
    return _keyManager;
}


// MARK: FOUND_KEYCHAIN_ITEM?
- (BOOL) foundKeychain{
    
    OSStatus errorStus = noErr;
    _genericQuery = [NSMutableDictionary new];
    
    _genericQuery = [@{(__bridge id)kSecClass           : (__bridge id)kSecClassGenericPassword,
                       (__bridge id)kSecAttrLabel       : keyAttrLabel,
                       (__bridge id)kSecAttrDescription : keyAttrDescription,
                       (__bridge id)kSecAttrService     : keyAttrService,
                       (__bridge id)kSecMatchLimit      : (__bridge id)kSecMatchLimitOne,
                       } mutableCopy];
            // SETUP the basic Query => Define what you are looking for
            // In this case =>
            // kSecClass ; kSecAttrLabel ; kSecAttrDescription ; kSecAttrService ;
            // Then state what you wish to return
            // in this case ... nothing ... just want to check if such file exists
    
    errorStus = SecItemCopyMatching((__bridge CFDictionaryRef)_genericQuery, nil);
    
    if (errorStus == noErr){ // if keychain item with _genericQuery definition was found
        
        [self retrieveUserInfo];
        
        return true;
    }
    
    // If not found, show me the error and return false
    _errorString = [self NSStringFromOSStatus:errorStus];
    
    return false;
}


// MARK: ADD_KEYCHAIN_ITEM
- (BOOL) setKeychainObject:(NSString *)object forKey:(NSString *)key{
    NSMutableDictionary * dict = [self prepareDict:key];
    NSData * encodedObj = [object dataUsingEncoding:NSUTF8StringEncoding];
    
    dict [(__bridge id)kSecValueData] = encodedObj;
    
    OSStatus errorStus = SecItemAdd((__bridge CFDictionaryRef)dict, nil);
    
    if (errorStus == noErr){
        [_userInfo setUserInfo:object userPassword:key];
        return true;
    }
    
    _errorString = [self NSStringFromOSStatus:errorStus];
    return false;
}

// MARK: GET_KEYCHAIN_ITEM
- (NSData *) getKeychainObjectForKey :(NSString *)key{
    NSMutableDictionary * dict = [self prepareDict:key];
    dict [(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    dict [(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    CFTypeRef ref = nil;
    
    OSStatus errorStus = SecItemCopyMatching((__bridge CFDictionaryRef)dict, &ref);
    
    if (errorStus != noErr){
        NSLog(@"Error with Getting Keychain Object");
        return nil;
    }
    
    return (__bridge NSData *) ref;
}

// MARK: UPDATE_KEYCHAIN_ITEM
- (BOOL) updateKeychain: (NSString *) object forKey: (NSString *) key{
    NSMutableDictionary * dict = [self prepareDict:key];
    // Set up UPDATE_DICT
    NSMutableDictionary * updateDict = [NSMutableDictionary new];
    NSData * encodedObj = [object dataUsingEncoding:NSUTF8StringEncoding];
    updateDict [(__bridge id)kSecValueData] = encodedObj;
    
    OSStatus errorStus = SecItemUpdate((__bridge CFDictionaryRef)dict, (__bridge CFDictionaryRef)updateDict);
    
    if (errorStus == noErr){
        return true;
    }
    _errorString = [self NSStringFromOSStatus:errorStus];
    return false;
}

#pragma mark - PRIVATE METHODS
// MARK: RETURN_STRING_FROM_OSSTATUS
- (NSString *) NSStringFromOSStatus: (OSStatus) errCode{
    if (errCode == noErr)
        return @"noErr";
    char message[5] = {0};
    *(UInt32*) message = CFSwapInt32HostToBig(errCode);
    return [NSString stringWithCString:message encoding:NSASCIIStringEncoding];
    
//    NSBundle * secBundle = [NSBundle bundleWithIdentifier:@"com.apple.security"];
//    NSString * keyStr = [NSString stringWithFormat:@"%d",errCode];
//    NSString * errStr = [secBundle localizedStringForKey:keyStr
//                                                   value:keyStr
//                                                   table:@"SecErrorMessages"];
//    return errStr;
}


// MARK: PREPARE_DICTIONARY
- (NSMutableDictionary *) prepareDict: (NSString *) key{
    _userInfo = [UserInfo shareInstance];
    
    NSMutableDictionary * dict = [@{(__bridge id)kSecClass          :(__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrService    :keyAttrService,
                                    (__bridge id)kSecAttrLabel      :keyAttrLabel,
                                    (__bridge id)kSecAttrDescription:keyAttrDescription,
                                    (__bridge id)kSecAttrAccessible :(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                                    } mutableCopy];
    
    NSData * encodedKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    dict [(__bridge id)kSecAttrAccount] = encodedKey;
    return dict;
}


// MARK: RETRIEVE_USER_INFO 
- (void) retrieveUserInfo {

    _userInfo = [UserInfo shareInstance];
    
    NSMutableDictionary * keyItemData = [@{(__bridge id)kSecClass           : (__bridge id)kSecClassGenericPassword,
                                           (__bridge id)kSecAttrLabel       : keyAttrLabel,
                                           (__bridge id)kSecAttrDescription : keyAttrDescription,
                                           (__bridge id)kSecAttrService     : keyAttrService,
                                           (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
                                           (__bridge id)kSecReturnData      : (__bridge id)kCFBooleanTrue,
                                           (__bridge id)kSecMatchLimit      : (__bridge id)kSecMatchLimitOne,
                                           } mutableCopy];
    
    CFDictionaryRef resultRef = nil; // SET UP a DICTIONARY REFERENCE to save DATA & ATTRIBUTES
    
    OSStatus errorStus = SecItemCopyMatching((__bridge CFDictionaryRef)keyItemData, (CFTypeRef *) &resultRef);
    if (errorStus == noErr){
        NSDictionary * resultDict = (__bridge_transfer NSDictionary *)resultRef;
        
        NSString * password = [[NSString alloc] initWithData:resultDict[(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
        NSString * username = [[NSString alloc] initWithData:resultDict[(__bridge id)kSecAttrAccount] encoding:NSUTF8StringEncoding] ;
        [_userInfo setUserInfo:username userPassword:password];
    }else{
        NSLog(@"Something wrong with RETRIEVING USER INFO");
    }
}







@end

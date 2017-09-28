//
//  Constants.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


#define iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version) [[[UIDevice currentDevice] systemVersion] floatValue] <= version

// 30M
#define MAX_CACHE_SIZE 30*1024*1024
#define MAX_ITEM_SIZE 1024*1024

#define KEYBOARD_HEADER_HEIGHT 35
#define DEVICE_WIDTH [[UIScreen mainScreen] bounds].size.width
#define DEVICE_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define FONTSIZE_SCALE [[UIScreen mainScreen] bounds].size.height == 480 ? 1 : ([[UIScreen mainScreen] bounds].size.height == 568 ? 1.12 : ([[UIScreen mainScreen] bounds].size.width == 375 ? 1.21 : ([[UIScreen mainScreen] bounds].size.width == 414 ? 1.23 : 1.23)))

#endif /* Constants_h */

#define CONTACT @"Contact"
#define PAGEITEMS 50

#pragma mark - contacts Authorizatio Status
typedef enum {
    
    ContactAuthorizationStatusDenied = 1,
    ContactAuthorizationStatusRestricted = 2,
} ContactAuthorizationStatus;


#pragma mark - contacts loading Error
typedef enum {
    
    ContactLoadingFailError = 3
} ErorrCode;

typedef NS_ENUM(NSInteger, ScrollOrientation) {
    
    ScrollOrientationUp = 1,
    ScrollOrientationDown = -1
};

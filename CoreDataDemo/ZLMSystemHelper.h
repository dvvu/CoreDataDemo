//
//  ZLMSystemHelper.h
//  PhoneBook
//
//  Created by chuonghm on 8/14/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Utilities for reading system information
 */
@interface ZLMSystemHelper : NSObject

/**
 Get free RAM memory at current time

 @return free memory in bytes
 */
+ (unsigned long)getFreeMemory;

@end

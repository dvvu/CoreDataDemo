//
//  NSString+Extension.h
//  PhoneBook
//
//  Created by chuonghm on 8/10/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(ContactPicker)

/**
 Remove acent of string

 @return ANSCI string
 */
- (NSString *)toANSCI;

/**
 Get first character represent string in alphabet

 @return alphabet letter
 */
- (NSString *)getFirstChar;

@end

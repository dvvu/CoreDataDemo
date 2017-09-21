//
//  NSString+Extension.m
//  PhoneBook
//
//  Created by chuonghm on 8/10/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString(ContactPicker)

- (NSString *)toANSCI {
    return [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
}

- (NSString *)getFirstChar {
    unichar firstChar = [[self uppercaseString] characterAtIndex:0];
    if (!(firstChar >= 'A' && firstChar <= 'Z')
        && !(firstChar >= '0' && firstChar <= '9')) {
        firstChar = [[[self uppercaseString] toANSCI] characterAtIndex:0];
    }
    if (!(firstChar >= 'A' && firstChar <= 'Z')) {
        firstChar = '#';
    }
    return [NSString stringWithFormat:@"%c",firstChar];
}

@end

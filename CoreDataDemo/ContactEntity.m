//
//  ContactEntity.m
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactEntity.h"
#import "Constants.h"

@interface ContactEntity()

@property (nonatomic, strong) NSString* textNameDefault;

@end

@implementation ContactEntity

#pragma mark - validate phoneNumber

- (BOOL)validatePhone:(NSString *)phoneNumber {
    
    NSString* phoneRegex = @"^[0-9-\\s]{6,14}$";
    NSPredicate* validatePhoneNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [validatePhoneNumber evaluateWithObject:phoneNumber];
}

@end

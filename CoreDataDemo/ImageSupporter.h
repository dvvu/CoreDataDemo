//
//  ImageSupporter.h
//  CoreDataDemo
//
//  Created by Doan Van Vu on 9/20/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photos/Photos.h"
#import <UIKit/UIKit.h>

@interface ImageSupporter : NSObject

+ (instancetype)sharedInstance;

#pragma mark - makeRoundImage
- (UIImage *)makeRoundImage:(UIImage *)image;

#pragma mark - resizeImage
- (UIImage *)resizeImage:(UIImage *)image;

#pragma mark - checkPermissionPhoto
- (void)checkPermissionPhoto:(void(^)(NSString *))completion;

#pragma mark - getImagePickerwithURL
- (void)getImagePickerwithURL:(NSURL *)profileImageURL completion:(void(^)(UIImage *))completion;

#pragma mark - profileImageDefault
- (void)profileImageDefault:(NSString *)textNameDefault completion:(void(^)(UIImage *))completion;

@end

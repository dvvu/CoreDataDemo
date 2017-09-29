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

#pragma mark - resizeImage
- (UIImage *)resizeImage:(UIImage *)image;

#pragma mark - makeRoundImage
- (UIImage *)makeRoundImage:(UIImage *)image;

#pragma mark - removeImageFromFolder
- (void)removeImageFromFolder:(NSString *)imageName;

#pragma mark - profileImageDefault
- (UIImage *)profileImageDefault:(NSString *)textNameDefault;

#pragma mark - checkPhotoPermission
- (void)checkPhotoPermission:(void(^)(NSString *))completion;

#pragma mark - storeImageToFolder
- (void)storeImageToFolder:(UIImage *)image withImageName:(NSString *)imageName;

#pragma mark - getImageFromFolder
- (void)getImageFromFolder:(NSString *)imageName completion:(void(^)(UIImage* image))compeltion;

#pragma mark - profileImageDefault
- (void)profileImageDefault:(NSString *)textNameDefault completion:(void(^)(UIImage *))completion;

@end

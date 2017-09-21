//
//  ImageSupporter.m
//  CoreDataDemo
//
//  Created by Doan Van Vu on 9/20/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageSupporter.h"

@interface ImageSupporter ()

@property (nonatomic) dispatch_queue_t photoPermissionQueue;

@end

@implementation ImageSupporter

#pragma mark - singleton

+ (instancetype)sharedInstance {
    
    static ImageSupporter* sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[ImageSupporter alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _photoPermissionQueue = dispatch_queue_create("PHOTO_PERMISSION_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - draw image circle

- (UIImage *)makeRoundImage:(UIImage *)image {
    
    // Resize image
    image = [self resizeImage:image];
    CGFloat imageWidth = image.size.width;
    CGRect rect = CGRectMake(0, 0, imageWidth, imageWidth);
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(rect.size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:imageWidth/2] addClip];
    [image drawInRect:rect];
    UIImage* imageCircle = UIGraphicsGetImageFromCurrentImageContext();
    
    // End ImageContext
    UIGraphicsEndImageContext();
    
    return imageCircle;
}

#pragma mark - resize image

- (UIImage *)resizeImage:(UIImage *)image {
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    CGFloat edgeSquare = 100;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if (imageWidth > imageHeight) {
        
        CGFloat scaleRatio = edgeSquare / imageHeight;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(-(imageWidth - imageHeight) / 2, 0);
    } else {
        
        CGFloat scaleRatio = edgeSquare / imageWidth;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(0, -(imageHeight - imageWidth) / 2);
    }
    
    CGSize size = CGSizeMake(edgeSquare, edgeSquare);
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - checkPermissionPhoto

- (void)checkPermissionPhoto:(void(^)(NSString *))completion {
    
    dispatch_async(_photoPermissionQueue, ^ {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        if (status == PHAuthorizationStatusAuthorized) {
            
            // Access has been granted.
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                completion(nil);
            });
        } else if (status == PHAuthorizationStatusDenied) {
            
            // Access has been denied.
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                completion(@"PHAuthorizationStatusDenied");
            });
        } else if (status == PHAuthorizationStatusNotDetermined) {
            
            // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        completion(nil);
                    });
                } else {
                    // Access has been denied.
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        completion(@"PHAuthorizationStatusDenied");
                    });
                }
            }];
        } else if (status == PHAuthorizationStatusRestricted) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                completion(@"PHAuthorizationStatusRestricted");
            });
        }
    });
}

#pragma mark - getImagePickerwithURL

- (void)getImagePickerwithURL:(NSURL *)profileImageURL completion:(void(^)(UIImage *))completion {
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];

    [library assetForURL:profileImageURL resultBlock:^(ALAsset* asset) {

        UIImage* image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];

        dispatch_async(dispatch_get_main_queue(), ^{

            completion(image);
        });
    } failureBlock:^(NSError* error) {

        completion(nil);
    }];
}

#pragma mark - profileImageDefault

- (UIImage *)profileImageDefault:(NSString *)textNameDefault {
    
    // Size image
    int imageWidth = 100;
    int imageHeight =  100;
    
    // Rect for image
    CGRect rect = CGRectMake(0,0,imageHeight,imageHeight);
    
    // setup text
    UIFont* font = [UIFont systemFontOfSize: 50];
    CGSize textSize = [textNameDefault.uppercaseString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50]}];
    NSMutableAttributedString* nameAttString = [[NSMutableAttributedString alloc] initWithString:textNameDefault.uppercaseString];
    NSRange range = NSMakeRange(0, [nameAttString length]);
    [nameAttString addAttribute:NSFontAttributeName value:font range:range];
    [nameAttString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
    
    // Create image
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    UIColor* fillColor = [UIColor lightGrayColor];
    
    // Begin ImageContext Options
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(rect.size);
    
    //  Draw Circle image
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:imageWidth/2] addClip];
    [image drawInRect:rect];
    
    // Draw text
    [nameAttString drawInRect:CGRectIntegral(CGRectMake(imageWidth/2 - textSize.width/2, imageHeight/2 - textSize.height/2, imageWidth, imageHeight))];
    UIImage* profileImageDefault = UIGraphicsGetImageFromCurrentImageContext();
    
    // End ImageContext
    UIGraphicsEndImageContext();
    
    // End ImageContext Options
    UIGraphicsEndImageContext();
    
    return profileImageDefault;
}

@end
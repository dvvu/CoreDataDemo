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
@property (nonatomic) dispatch_queue_t defaultImageQueue;
@property (nonatomic) dispatch_queue_t imageFromFolderQueue;
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
        _defaultImageQueue = dispatch_queue_create("DEFAULT_IMAGE_QUEUE", DISPATCH_QUEUE_SERIAL);
        _imageFromFolderQueue = dispatch_queue_create("IMAGE_FROM_FOlDER_QUEUE", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - getImageFromFoder

- (void)getImageFromFolder:(NSString *)imageName completion:(void(^)(UIImage* image))compeltion {
    
    dispatch_async(_imageFromFolderQueue, ^ {
        
        //Get image file from sand box using file name and file path
        NSString* stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"ImageFolder"];
        stringPath = [stringPath stringByAppendingPathComponent:imageName];
        
        UIImage* image = [UIImage imageWithContentsOfFile:stringPath];
        
        if (compeltion) {
            
            if (image) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    compeltion(image);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    compeltion(nil);
                });
            }
        }
    });
}

#pragma mark - storeImageToDirectory

- (void)storeImageToFolder:(UIImage *)image withImageName:(NSString *)imageName {
    
    dispatch_barrier_async(_imageFromFolderQueue, ^ {
   
        // For error information
        NSError* error;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* dataPath = [documentsDirectory stringByAppendingPathComponent:@"ImageFolder"];
        
        if (![fileManager fileExistsAtPath:dataPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        NSData* imageData = UIImagePNGRepresentation(image);
        
        NSString* imgfileName = [NSString stringWithFormat:@"%@%@", imageName, @".png"];
        
        // File we want to create in the documents directory
        NSString* imgfilePath = [dataPath stringByAppendingPathComponent:imgfileName];
        
        // Write the file
        [imageData writeToFile:imgfilePath atomically:YES];
    });
}

#pragma mark - removeImageFromFolder

- (void)removeImageFromFolder:(NSString *)imageName {
    
    dispatch_barrier_async(_imageFromFolderQueue, ^ {
        
        // For error information
        NSError* error;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* dataPath = [documentsDirectory stringByAppendingPathComponent:@"ImageFolder"];
        
        NSString* imagwNamePath = [NSString stringWithFormat:@"%@/%@%@", dataPath, imageName, @".png"];
        
        if ([fileManager fileExistsAtPath:dataPath]) {
            
            [fileManager removeItemAtPath:imagwNamePath error:&error];
        }
    });
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
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion(nil);
                });
            }
        } else if (status == PHAuthorizationStatusDenied) {
            
            // Access has been denied.
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion(@"PHAuthorizationStatusDenied");
                });
            }
        } else if (status == PHAuthorizationStatusNotDetermined) {
            
            // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    if (completion) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            completion(nil);
                        });
                    }
                } else {
                    // Access has been denied.
                    if (completion) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            completion(@"PHAuthorizationStatusDenied");
                        });
                    }
                }
            }];
        } else if (status == PHAuthorizationStatusRestricted) {
            
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion(@"PHAuthorizationStatusRestricted");
                });
            }
        }
    });
}

#pragma mark - profileImageDefault

- (void)profileImageDefault:(NSString *)textNameDefault completion:(void(^)(UIImage *))completion {
    
    dispatch_async(_photoPermissionQueue, ^ {
    
        int imageWidth = 100;
        int imageHeight = 100;
        
        // Rect for image
        CGRect rect = CGRectMake(0,0,imageHeight,imageHeight);
        
        // setup text
        UIFont* font = [UIFont systemFontOfSize:35];
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
        
        if (completion) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(profileImageDefault);
            });
        }
    });
}

#pragma mark - profileImageDefault

- (UIImage *)profileImageDefault:(NSString *)textNameDefault {

    int imageWidth = 70;
    int imageHeight = 70;
    
    // Rect for image
    CGRect rect = CGRectMake(0,0,imageHeight,imageHeight);
    
    // setup text
    UIFont* font = [UIFont systemFontOfSize:30];
    CGSize textSize = [textNameDefault.uppercaseString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:35]}];
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

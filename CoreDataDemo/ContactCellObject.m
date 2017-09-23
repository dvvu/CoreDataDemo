//
//  ContactCellObject.m
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactCache.h"
#import "ImageSupporter.h"

@implementation ContactCellObject

- (Class)cellClass {
    
    return [ContactTableViewCell class];
}

- (void)getImageCacheForCell: (UITableViewCell *)cell {
    
    [[ContactCache sharedInstance] getImageForKey:_identifier completionWith:^(UIImage* image) {
        
        __weak ContactTableViewCell* contactTableViewCell = (ContactTableViewCell *)cell;
        
        if (image) {
            
            if ([_identifier isEqualToString:contactTableViewCell.identifier]) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    contactTableViewCell.profileImageView.image = image;
                });
            }
        } else {
            
            [[ImageSupporter sharedInstance] getImagePickerwithURL:[NSURL URLWithString:_profileImageURL] completion:^(UIImage* image) {
                
                if (image) {
                    
                    image = [[ImageSupporter sharedInstance] makeRoundImage:[[ImageSupporter sharedInstance] resizeImage:image]];
                   
                    [[ContactCache sharedInstance] setImageForKey:image forKey:_identifier];
                    
                    // Run on main Thread
                    if ([_identifier isEqualToString:contactTableViewCell.identifier]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            contactTableViewCell.profileImageView.image = image;
                        });
                    }
                }
            }];
        }
    }];
}

@end

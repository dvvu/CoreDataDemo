//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "NICellCatalog.h"

@protocol ContactModelProtocol <NSObject>

@property (readonly, nonatomic, copy) NSString* firstName;
@property (readonly, nonatomic, copy) NSString* lastName;
@property (readonly, nonatomic, copy) NSString* phoneNumber;
@property (readonly, nonatomic, copy) UIImage* contactImage;
@property (readonly, nonatomic, copy) NSString* company;

@end

@interface ContactCellObject : NITitleCellObject <ContactModelProtocol>

@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, copy) NSString* phoneNumber;
@property (nonatomic, copy) UIImage* contactImage;
@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, copy) NSString* company;

- (void)getImageCacheForCell: (UITableViewCell *)cell;

@end

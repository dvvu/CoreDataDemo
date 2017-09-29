//
//  ContactCellObject.h
//  NimbusExample
//
//  Created by Doan Van Vu on 7/5/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#import "ContactCellObject.h"
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface ContactTableViewCell : UITableViewCell <NICell>
@property (nonatomic) id<ContactModelProtocol>model;
@property (nonatomic) UIImageView* profileImageView;
@property (nonatomic) UILabel* phoneNumber;
@property (nonatomic) NSString* identifier;
@property (nonatomic) UILabel* nameLabel;
@property (nonatomic) UILabel* company;
@end


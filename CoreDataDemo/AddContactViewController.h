//
//  AddContactViewController.h
//  ContactsWithCoreData
//
//  Created by Doan Van Vu on 9/13/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ContactEntities+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface AddContactViewController : UIViewController

#pragma mark - prepareData
@property (nonatomic) ContactEntities* contactEntities;

@end

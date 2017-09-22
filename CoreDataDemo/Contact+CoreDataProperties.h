//
//  Contact+CoreDataProperties.h
//  
//
//  Created by Doan Van Vu on 9/22/17.
//
//

#import "Contact+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

+ (NSFetchRequest<Contact *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *company;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, copy) NSString *phoneNumber;
@property (nullable, nonatomic, copy) NSString *profileImageURL;

@end

NS_ASSUME_NONNULL_END

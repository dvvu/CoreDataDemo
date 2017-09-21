//
//  ContactEntities+CoreDataProperties.h
//  
//
//  Created by Doan Van Vu on 9/19/17.
//
//

#import "ContactEntities+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactEntities (CoreDataProperties)

+ (NSFetchRequest<ContactEntities *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString* profileImageURL;
@property (nullable, nonatomic, copy) NSString* identifier;
@property (nullable, nonatomic, copy) NSString* phoneNumber;
@property (nullable, nonatomic, copy) NSString* company;
@property (nullable, nonatomic, copy) NSString* firstName;
@property (nullable, nonatomic, copy) NSString* lastName;

@end

NS_ASSUME_NONNULL_END

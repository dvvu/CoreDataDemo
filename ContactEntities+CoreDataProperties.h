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

@property (nullable, nonatomic, copy) NSString *contactTitle;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSString *phoneNumer;
@property (nullable, nonatomic, copy) NSString *company;

@end

NS_ASSUME_NONNULL_END

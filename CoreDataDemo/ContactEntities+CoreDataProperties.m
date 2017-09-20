//
//  ContactEntities+CoreDataProperties.m
//  
//
//  Created by Doan Van Vu on 9/19/17.
//
//

#import "ContactEntities+CoreDataProperties.h"

@implementation ContactEntities (CoreDataProperties)

+ (NSFetchRequest<ContactEntities *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ContactEntities"];
}

@dynamic identifier;
@dynamic phoneNumber;
@dynamic company;
@dynamic firstName;
@dynamic lastName;

@end

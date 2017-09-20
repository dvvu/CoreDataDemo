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

@dynamic contactTitle;
@dynamic identifier;
@dynamic phoneNumer;
@dynamic company;

@end

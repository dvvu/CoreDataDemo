//
//  Contact+CoreDataProperties.m
//  
//
//  Created by Doan Van Vu on 9/22/17.
//
//

#import "Contact+CoreDataProperties.h"

@implementation Contact (CoreDataProperties)

+ (NSFetchRequest<Contact *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
}

@dynamic company;
@dynamic firstName;
@dynamic identifier;
@dynamic lastName;
@dynamic phoneNumber;

@end

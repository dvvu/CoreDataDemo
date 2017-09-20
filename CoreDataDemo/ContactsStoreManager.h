//
//  ContactsStoreManager.h
//  ContactsWithCoreData
//
//  Created by Doan Van Vu on 9/14/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"

@interface ContactsStoreManager : NSObject

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

#pragma mark - sharedInstance
+ (ContactsStoreManager *)sharedInstance;

#pragma mark - initializeCoreDataURLForResource
- (void)initializeCoreDataURLForResource:(NSString *)urlForResource andNameTable:(NSString *)tableName;

#pragma mark - addContact
- (void)addObject:(NSManagedObject *)object toTable:(NSString *)tableName;

#pragma mark - deleteContact
- (void)deleteObject:(NSManagedObject *)object fromTable:(NSString *)tableName;

#pragma mark - updateContact
- (void)updateObjec:(NSManagedObject *)object atTable:(NSString *)tableName;

#pragma mark - getContacts
- (NSArray *)getObjectsFromTable:(NSString *)tableName;

#pragma mark - clearCoreData
- (void)clearCoreData:(NSString *)tableName;

@end

//
//  CoreDataManager.h
//  CoreDataDemo
//
//  Created by Doan Van Vu on 9/22/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^CoreDataSaveSuccess)();

typedef void (^CoreDataFetchSuccess)(NSArray* results);

typedef void (^CoreDataNewCreateIDSuccess)(NSInteger new_create_id);

typedef void (^CoreDataFailed)(NSError* error);

@interface CoreDataManager : NSObject

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

#pragma mark - Initialize
- (void)initSettingWithCoreDataName:(NSString *)coreDataName sqliteName:(NSString *)sqliteName;

#pragma mark - Singletone
+ (CoreDataManager *)sharedInstance;

#pragma mark - insert
- (id)createInsertEntityWithClassName:(NSString *)className;

- (void)autoIncrementIDWithEntityClass:(NSString *)entityClass success:(CoreDataNewCreateIDSuccess)success failed:(CoreDataFailed)failed;

#pragma mark - save

- (void)save;

#pragma mark - fetch
- (void)fetchWithEntity:(NSString *)entityClass Predicate:(NSPredicate *)predicate success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed;

#pragma mark - delete
- (void)deleteWithEntity:(id)entity;

#pragma mark - predicate

- (NSPredicate *)setPredicateEqualWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue;

- (NSPredicate *)setPredicateOverWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue;

- (NSPredicate *)setPredicateUnderWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue;
@end

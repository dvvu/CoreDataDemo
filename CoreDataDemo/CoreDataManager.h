//
//  CoreDataManager.h
//  CoreDataDemo
//
//  Created by Doan Van Vu on 9/22/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef void (^CoreDataFetchSuccess)(NSArray* results);
typedef void (^CoreDataFailed)(NSError* error);
typedef void (^CoreDataSaveSuccess)();

@interface CoreDataManager : NSObject

#pragma mark - initSettingWithCoreDataName
- (void)initSettingWithCoreDataName:(NSString *)coreDataName sqliteName:(NSString *)sqliteName;

#pragma mark - Singletone
+ (CoreDataManager *)sharedInstance;

#pragma mark - getEntityWithClass
- (void)getEntityWithClass:(NSString *)entityClass condition:(NSPredicate *)predicate success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed;

#pragma mark - getEntityWithClass
- (void)getEntityWithClass:(NSString *)entityClass condition:(NSPredicate *)predicate fromIndex:(int)index resultsLimit:(int)limit success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed;

#pragma mark - insert
- (id)createInsertEntityWithClassName:(NSString *)className;

#pragma mark - delete
- (void)deleteWithEntity:(id)entity;

#pragma mark - save
- (void)save;

#pragma mark - predicate to setCondition
- (NSPredicate *)setPredicateEqualWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue;

@end

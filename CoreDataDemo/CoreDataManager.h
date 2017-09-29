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

#pragma mark - save
- (void)save;

#pragma mark - delete
- (void)deleteEntity:(id)entity;

#pragma mark - Singletone
+ (CoreDataManager *)sharedInstance;

#pragma mark - createEntityForClass
- (id)createEntityForClass:(NSString *)entityClass;

#pragma mark - settingCoreDataWithName
- (void)initWithCoreDataName:(NSString *)coreDataName andSqliteName:(NSString *)sqliteName;

#pragma mark - predicate to setCondition
- (NSPredicate *)setConditonWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue;

#pragma mark - getEntityFromClass if queue = nil -> callback main
- (void)getEntitiesFromClass:(NSString *)entityClass withCondition:(NSPredicate *)condition callbackQueue:(dispatch_queue_t)queue success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed;

#pragma mark - getEntityWithClass if queue = nil -> callback main
- (void)getEntitiesFromClass:(NSString *)entityClass withCondition:(NSPredicate *)condition maximumEntities:(int)maximumEntities fromIndex:(int)index callbackQueue:(dispatch_queue_t)queue success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed;

@end

//
//  CoreDataManager.m
//  CoreDataDemo
//
//  Created by Doan Van Vu on 9/22/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager ()

@property (nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic) NSManagedObjectModel* managedObjectModel;
@property (nonatomic) dispatch_queue_t contactStoreQueue;

@end

@implementation CoreDataManager

+ (CoreDataManager *)sharedInstance {
    
    static CoreDataManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[CoreDataManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _contactStoreQueue = dispatch_queue_create("CONTACT_STORE_QUEUE", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - Initial

- (void)initSettingWithCoreDataName:(NSString *)coreDataName sqliteName:(NSString *)sqliteName {
    
    dispatch_barrier_async(_contactStoreQueue, ^ {
    
        [self managedObjectContextWithCoreDataName:coreDataName sqliteName:sqliteName];
    });
}

#pragma mark - createInsertEntityWithClassName

- (id)createInsertEntityWithClassName:(NSString *)className {
    
    return [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:_managedObjectContext];
}

#pragma mark - Save

- (void)save {
    
    dispatch_barrier_async(_contactStoreQueue, ^ {
        
        NSError* error = nil;
        [_managedObjectContext save:&error];
    });
}

#pragma mark - fetchWithEntity

- (void)fetchWithEntity:(NSString *)entityClass Predicate:(NSPredicate *)predicate success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed {
   
    dispatch_sync(_contactStoreQueue, ^ {
       
        NSManagedObjectContext* managedObjectContext = _managedObjectContext;
        NSFetchRequest* request = [NSFetchRequest new];
        NSEntityDescription* entity = [NSEntityDescription entityForName:entityClass inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES]]];
        
        if (predicate) {
            
            [request setPredicate:predicate];
        }

        NSError* error;
        NSArray* results = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (error) {
            
            failed(error);
        } else {
            success(results);
        }
    });
}

#pragma mark - autoIncrementIDWithEntityClass

- (void)autoIncrementIDWithEntityClass:(NSString *)entityClass success:(CoreDataNewCreateIDSuccess)success failed:(CoreDataFailed)failed {
    
    dispatch_async(_contactStoreQueue, ^ {
        
        NSManagedObjectContext* managedObjectContext = _managedObjectContext;
        NSFetchRequest* request = [NSFetchRequest new];
        
        NSEntityDescription* entity = [NSEntityDescription entityForName:entityClass inManagedObjectContext:managedObjectContext];
        [request setEntity:entity];
        
        NSError* error;
        NSArray* results = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (error) {
            
            failed(error);
        } else {
            
            success(results.count);
        }
    });
}

#pragma mark - deleteWithEntity

- (void)deleteWithEntity:(id)entity {
    
    dispatch_barrier_async(_contactStoreQueue, ^ {
    
        NSManagedObjectContext* managedObjectContext = _managedObjectContext;
        
        [managedObjectContext deleteObject:entity];
        [self save];
    });
}

#pragma mark - setPredicateEqualWithSearchKey

- (NSPredicate *)setPredicateEqualWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@",searchkey,searchValue];
    return predicate;
}

#pragma mark - setPredicateOverWithSearchKey

- (NSPredicate *)setPredicateOverWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=>%@",searchkey,searchValue];
    return predicate;
}

#pragma mark - setPredicateUnderWithSearchKey

- (NSPredicate *)setPredicateUnderWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=<%@",searchkey,searchValue];
    return predicate;
}

#pragma mark -  managedObjectContextWithCoreDataName

- (NSManagedObjectContext *)managedObjectContextWithCoreDataName:(NSString *)coreDataName sqliteName:(NSString *)sqliteName {
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinatorWithCoreDataName:coreDataName sqliteName:sqliteName];
    
    if (coordinator != nil) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

#pragma mark -  persistentStoreCoordinatorWithCoreDataName

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithCoreDataName:(NSString *)coreDataName sqliteName:(NSString *)sqliteName {
    
    NSURL* storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:sqliteName];
    NSError* error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModelWithCoreDataName:coreDataName]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark -  managedObjectModelWithCoreDataName

- (NSManagedObjectModel *)managedObjectModelWithCoreDataName:(NSString *)coreDataName {
    
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:coreDataName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

#pragma mark -  applicationLibraryDirectory

- (NSURL *)applicationLibraryDirectory {
    
    NSString* coreDataDirPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Library"];
    
    return [NSURL fileURLWithPath:coreDataDirPath];
}

@end

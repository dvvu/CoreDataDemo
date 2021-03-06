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
@property (nonatomic) NSManagedObjectContext* managedObjectContext;
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

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _contactStoreQueue = dispatch_queue_create("CONTACT_STORE_QUEUE", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - initWithCoreDataName

- (void)initWithCoreDataName:(NSString *)coreDataName andSqliteName:(NSString *)sqliteName {
    
    dispatch_barrier_async(_contactStoreQueue, ^ {
    
        [self managedObjectContextWithCoreDataName:coreDataName sqliteName:sqliteName];
    });
}

#pragma mark - createInsertEntityWithClassName

- (id)createEntityForClass:(NSString *)entityClass {
  
    return [NSEntityDescription insertNewObjectForEntityForName:entityClass inManagedObjectContext:_managedObjectContext];
}

#pragma mark - save

- (void)save {
    
    dispatch_barrier_async(_contactStoreQueue, ^ {
        
        NSError* error = nil;
        [_managedObjectContext save:&error];
    });
}

#pragma mark - getEntityFromClass if queue = nil -> callback main 

- (void)getEntitiesFromClass:(NSString *)entityClass withCondition:(NSPredicate *)condition callbackQueue:(dispatch_queue_t)queue success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed {
   
    dispatch_async(_contactStoreQueue, ^ {
       
        NSFetchRequest* request = [NSFetchRequest new];
        NSEntityDescription* entity = [NSEntityDescription entityForName:entityClass inManagedObjectContext:_managedObjectContext];
        [request setEntity:entity];
        NSSortDescriptor* sortFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSSortDescriptor* sortLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        [request setSortDescriptors:@[sortFirstName,sortLastName]];
        
        if (condition) {
            
            [request setPredicate:condition];
        }

        NSError* error;
        NSArray* results = [_managedObjectContext executeFetchRequest:request error:&error];
   
        if (queue) {
            
            dispatch_async(queue, ^ {
                
                if (error) {
                    
                    failed(error);
                } else {
                    success(results);
                }
            });
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                if (error) {
                    
                    failed(error);
                } else {
                    success(results);
                }
            });
        }
    });
}

#pragma mark - getEntityWithClass

- (void)getEntitiesFromClass:(NSString *)entityClass withCondition:(NSPredicate *)condition maximumEntities:(int)maximumEntities fromIndex:(int)index callbackQueue:(dispatch_queue_t)queue success:(CoreDataFetchSuccess)success failed:(CoreDataFailed)failed {
    
    dispatch_async(_contactStoreQueue, ^ {
        
        NSFetchRequest* request = [NSFetchRequest new];
        NSEntityDescription* entity = [NSEntityDescription entityForName:entityClass inManagedObjectContext:_managedObjectContext];
        [request setEntity:entity];
        NSSortDescriptor* sortFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        NSSortDescriptor* sortLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        [request setSortDescriptors:@[sortFirstName,sortLastName]];
        request.fetchLimit = maximumEntities;
        request.fetchOffset = index;
        
        if (condition) {
            
            [request setPredicate:condition];
        }
    
        NSError* error;
        NSArray* results = [_managedObjectContext executeFetchRequest:request error:&error];
        
        if (queue) {
            
            dispatch_async(queue, ^ {
                
                if (error) {
                    
                    failed(error);
                } else {
                    success(results);
                }
            });
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                if (error) {
                    
                    failed(error);
                } else {
                    success(results);
                }
            });
        }
    });
}

#pragma mark - deleteWithEntity

- (void)deleteEntity:(id)entity {
    
    dispatch_barrier_async(_contactStoreQueue, ^ {
        
        [_managedObjectContext deleteObject:entity];
        [self save];
    });
}

#pragma mark - setConditonWithSearchKey

- (NSPredicate *)setConditonWithSearchKey:(NSString *)searchkey searchValue:(id)searchValue {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@",searchkey,searchValue];
    return predicate;
}

#pragma mark - managedObjectContextWithCoreDataName

- (NSManagedObjectContext *)managedObjectContextWithCoreDataName:(NSString *)coreDataName sqliteName:(NSString *)sqliteName {
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinatorWithCoreDataName:coreDataName sqliteName:sqliteName];
    
    if (coordinator != nil) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

#pragma mark - persistentStoreCoordinatorWithCoreDataName

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithCoreDataName:(NSString *)coreDataName sqliteName:(NSString *)sqliteName {
    
    NSURL* storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:sqliteName];
    NSError* error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModelWithCoreDataName:coreDataName]];
 
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - managedObjectModelWithCoreDataName

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

//
//  ContactsStoreManager.m
//  ContactsWithCoreData
//
//  Created by Doan Van Vu on 9/14/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ContactsStoreManager.h"
#import "ContactEntities+CoreDataClass.h"

@interface ContactsStoreManager ()

@end

@implementation ContactsStoreManager

#pragma mark - sharedInstance

+ (ContactsStoreManager *)sharedInstance {
   
    static ContactsStoreManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ContactsStoreManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - initializeCoreDataURLForResource

- (void)initializeCoreDataURLForResource:(NSString *)urlForResource andNameTable:(NSString *)tableName {
    
    // Lấy đường dẫn Resource.
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataDemo" withExtension:@"momd"];
    // Khởi tạo đối tượng Model lên theo url resource -> Đối tượng lưu lại Model.
    
    NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
   
    // Có thể sinh ra lỗi như sai tên file or đuôi file.
    if (managedObjectModel == nil) {
        
        NSLog(@"Error initializing Managed Object Model");
        return;
    }
    
    // Cầu nối dữ liệu hiện tại với nơi lưu trữ vật lý. Đọc và Load Model lên cũng như ghi xuống.
    NSPersistentStoreCoordinator* persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Đối tượng quản lý file
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // lấy đường dẫn đến thư mục docments của ứng dụng.
    NSURL* documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    // Tạo đường dẫn đích đến file , tạo file infor null.
    NSURL* storeURL = [documentsURL URLByAppendingPathComponent:@"ContactEntities.sqlite"];
    
    NSError* error = nil;
    //NSPersistentStoreCoordinator lớp gộp sử dụng NSPersistentStore-> đối tượng thông tin lưu trữ model, để lưu trữ theo kiểu type nào, Tên file, Đưa ra lỗi khi lưu, cấu hình bổ xung cho file sqite, options tuỳ chọn khác. khác vs sqlite chỉ copy bởi vì ở đây resource lưu model.
    NSPersistentStore* store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    //  Nếu lỗi file.
    if (store == nil) {
        
        NSLog(@"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    // tạo một đối tượng context
    NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    // set model cho đối tượng  (context) moc
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    // set context cho property.
    _managedObjectContext = managedObjectContext;
}

#pragma mark - addObject

- (void)addObject:(NSManagedObject *)object toTable:(NSString *)tableName {
    
//    object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:_managedObjectContext];
    NSError* error = nil;
    
    // Lưu không thành công thì trả về mô tả về lỗi đó!.
    if ([_managedObjectContext save:&error] == NO) {
      
        NSLog(@"Error saving context %@\n%@",[error localizedDescription],[error userInfo]);
    }
}

#pragma mark - deleteObject

- (void)deleteObject:(NSManagedObject *)object fromTable:(NSString *)tableName {
    
    // trả về số lượng phần tử trong mảng results.
    NSArray* results = [self getObjectsFromTable:tableName];
        
    for (ContactEntities* result in results) {

        ContactEntities* ob = (ContactEntities *)object;
        
        if ([result identifier] == [ob identifier]) {
            
            [_managedObjectContext deleteObject:result];
        }
    }
    // save context khi đã chỉnh sửa bản ghi
    NSError* error = nil;
    
    if ([_managedObjectContext save:&error] == NO) {
        
        NSLog(@"Error saving context %@\n%@",[error localizedDescription],[error userInfo]);
    }
}

#pragma mark - updateObjec

- (void)updateObjec:(NSManagedObject *)object atTable:(NSString *)tableName {
    
    // Tạo một đối tượng  FetchRequest để đọc thông tin Entity Student.
    NSArray* results = [self getObjectsFromTable:tableName];
  
    for (ContactEntities* result in results) {
        
        if ([[result identifier] isEqualToString:[(ContactEntities *)object identifier]]) {
            
            result.firstName = [(ContactEntities *)object firstName];
            result.lastName = [(ContactEntities *)object lastName];
            result.phoneNumber = [(ContactEntities *)object phoneNumber];
            result.company = [(ContactEntities *)object company];
        }
    }
    // save context khi đã chỉnh sửa bản ghi
    NSError* error = nil;
    
    if ([_managedObjectContext save:&error] == NO) {
        
        NSLog(@"Error saving context %@\n%@",[error localizedDescription],[error userInfo]);
    }
}

#pragma mark - getObjectsFromTable

- (NSArray *)getObjectsFromTable:(NSString *)tableName {
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:tableName];
    NSError* error = nil;
    
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES]]];
    // Truy vấn trả về mảng đối tượng lưu trong results.
    NSArray* results = [_managedObjectContext executeFetchRequest:request error:&error];

    // không có bản ghi thì trả vể error.
    if (!results) {
        
        NSLog(@"Error fetching Student object %@\n%@",[error localizedDescription],[error userInfo]);
        abort();
    }
    
    return results;
}

#pragma mark - clearCoreData

- (void)clearCoreData:(NSString *)tableName {
    
    // trả về số lượng phần tử trong mảng results.
    NSArray* results = [self getObjectsFromTable:tableName];
    
    for (NSManagedObject* result in results) {
        
        [_managedObjectContext deleteObject:result];
    }
    // save context khi đã chỉnh sửa bản ghi
    NSError* error = nil;
    
    if ([_managedObjectContext save:&error] == NO) {
        
        NSLog(@"Error saving context %@\n%@",[error localizedDescription],[error userInfo]);
    }
}

@end

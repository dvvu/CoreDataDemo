//
//  ZLMtsMutableArray.h
//  ZLMtsMutableArray
//
//  Created by chuonghm on 7/24/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Mutable array thread safe
 */
@interface ZLMtsMutableArray : NSObject

/**
 Init a new empty array

 @return - new ZLMtsMutableArray
 */
- (instancetype)init;

/**
 Init a new ZLMtsMutableArray from a NSArray

 @param array - NSArray to init
 @return - new ZLMtsMutableArray contains array's elements
 */
- (instancetype)initWithArray:(NSArray *)array;

/**
 Add a object to array

 @param object - nonnull NSObject to add.
 */
- (void)addObject:(NSObject *)object;

/**
 Add multiple objects from NSArray

 @param array - nonnull and nonempty NSArray to add
 */
- (void)addObjectsFromArray:(NSArray *)array;

/**
 Insert an object at index to array

 @param object - nonnull NSObject to add.
 @param index - index to insert the object at.
 */
- (void)insertObject:(NSObject *)object
             atIndex:(NSUInteger)index;

/**
 Remove an object from array

 @param object - nonnull NSObject to remove.
 */
- (void)removeObject:(NSObject *)object;

/**
 Remove object at index from array

 @param index - index of object to remove.
 */
- (void)removeObjectAtIndex:(NSUInteger)index;

/**
 Remove all objects from array.
 */
- (void)removeAllObjects;

/**
 Pop the last object of array

 @return last object - nil if array is empty
 */
- (id)pop;

/**
 Get object at index in array

 @param index - index of object to get.
 @return - NSObject you want to get.
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 Get number of elements in array

 @return - NSUInteger indicates number of elements.
 */
- (NSUInteger)count;


/**
 Filter array using prdicate

 @param predicate - NSPredicate to use
 @return - NSArray after fitering
 */
- (NSArray *)filteredArrayUsingPredicate: (NSPredicate *) predicate;

/**
 Get index of object

 @param object - object to get index
 @return - index of object
 */
- (NSInteger)indexOfObject: (NSObject *)object;

/**
 Check whether array contains object

 @param object - object to check
 @return - YES if array contains the object, otherwise return NO
 */
- (BOOL)containsObject: (id)object;

- (NSArray *)toNSArray;

@end

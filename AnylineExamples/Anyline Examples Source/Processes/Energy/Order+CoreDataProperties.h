//
//  Order+CoreDataProperties.h
//  AnylineEnergy
//
//  Created by Milutin Tomic on 29/10/15.
//  Copyright © 2015 Milutin Tomic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Order.h"

NS_ASSUME_NONNULL_BEGIN

@interface Order (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *orderDate;
@property (nullable, nonatomic, retain) NSNumber *orderNr;
@property (nullable, nonatomic, retain) NSSet<Customer *> *customers;

@end

@interface Order (CoreDataGeneratedAccessors)

- (void)addCustomersObject:(Customer *)value;
- (void)removeCustomersObject:(Customer *)value;
- (void)addCustomers:(NSSet<Customer *> *)values;
- (void)removeCustomers:(NSSet<Customer *> *)values;

@end

NS_ASSUME_NONNULL_END

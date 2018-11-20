//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSSQLSpecificationProtocol.h"
#import "EMSCommonSQLSpecification.h"

@class EMSShard;

@interface EMSShardDeleteByIdsSpecification : EMSCommonSQLSpecification

- (instancetype)initWithShards:(NSArray<EMSShard *> *)shards;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToSpecification:(EMSShardDeleteByIdsSpecification *)specification;

- (NSUInteger)hash;

@end
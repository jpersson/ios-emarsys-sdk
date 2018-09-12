//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSConfig;
@class EMSTimestampProvider;
@class EMSUUIDProvider;

#define kEMSPredictSuiteName @"com.emarsys.predict"
#define kEMSCustomerId @"customerId"

@interface PRERequestContext : NSObject

@property(nonatomic, strong) NSString *customerId;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider;


@end
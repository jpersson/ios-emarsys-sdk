//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "FakeDependencyContainer.h"

@interface FakeDependencyContainer ()

@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) MobileEngageInternal *mobileEngage;
@property(nonatomic, strong) id <EMSInboxProtocol> inbox;
@property(nonatomic, strong) MEInApp *iam;
@property(nonatomic, strong) PredictInternal *predict;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, strong) EMSNotificationCache *notificationCache;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) MENotificationCenterManager *notificationCenterManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) AppStartBlockProvider *appStartBlockProvider;

@end

@implementation FakeDependencyContainer

- (instancetype)initWithDbHelper:(EMSSQLiteHelper *)dbHelper
                    mobileEngage:(MobileEngageInternal *)mobileEngage
                           inbox:(id <EMSInboxProtocol>)inbox
                             iam:(MEInApp *)iam
                         predict:(PredictInternal *)predict
                  requestContext:(MERequestContext *)requestContext
               requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
               notificationCache:(EMSNotificationCache *)notificationCache
                responseHandlers:(NSArray<EMSAbstractResponseHandler *> *)responseHandlers
                  requestManager:(EMSRequestManager *)requestManager
                  operationQueue:(NSOperationQueue *)operationQueue
       notificationCenterManager:(MENotificationCenterManager *)notificationCenterManager
           appStartBlockProvider:(AppStartBlockProvider *)appStartBlockProvider {
    if (self = [super init]) {
        _dbHelper = dbHelper;
        _mobileEngage = mobileEngage;
        _inbox = inbox;
        _iam = iam;
        _predict = predict;
        _requestContext = requestContext;
        _requestRepository = requestRepository;
        _notificationCache = notificationCache;
        _responseHandlers = responseHandlers;
        _requestManager = requestManager;
        _operationQueue = operationQueue;
        _notificationCenterManager = notificationCenterManager;
        _appStartBlockProvider = appStartBlockProvider;
    }
    return self;
}

@end
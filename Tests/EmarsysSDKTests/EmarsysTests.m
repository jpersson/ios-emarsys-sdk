//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "Emarsys.h"
#import "PredictInternal.h"
#import "EMSSQLiteHelper.h"
#import "EMSDBTriggerKey.h"
#import "EMSDependencyContainer.h"
#import "EmarsysTestUtils.h"
#import "EMSAbstractResponseHandler.h"
#import "MEIAMResponseHandler.h"
#import "MEIAMCleanupResponseHandler.h"
#import "EMSVisitorIdResponseHandler.h"
#import "EMSDependencyInjection.h"
#import "MENotificationCenterManager.h"
#import "FakeDependencyContainer.h"
#import "AppStartBlockProvider.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSRequestFactory.h"
#import "EMSClientStateResponseHandler.h"
#import "EMSLogger.h"
#import "EMSRequestManager.h"

SPEC_BEGIN(EmarsysTests)

        __block id engage;
        __block id push;
        __block id deepLink;
        __block PredictInternal *predict;
        __block MERequestContext *requestContext;
        __block EMSDeviceInfo *deviceInfo;
        __block EMSRequestFactory *requestFactory;
        __block EMSRequestManager *requestManager;
        __block MENotificationCenterManager *notificationCenterManagerMock;
        __block AppStartBlockProvider *appStartBlockProvider;
        __block id deviceInfoClient;

        __block EMSConfig *baseConfig;
        __block id <EMSDependencyContainerProtocol> dependencyContainer;

        NSString *const customerId = @"customerId";

        beforeEach(^{
            engage = [KWMock nullMockForProtocol:@protocol(EMSMobileEngageProtocol)];
            push = [KWMock nullMockForProtocol:@protocol(EMSPushNotificationProtocol)];
            deepLink = [KWMock nullMockForProtocol:@protocol(EMSDeepLinkProtocol)];
            predict = [PredictInternal nullMock];
            requestContext = [MERequestContext nullMock];
            deviceInfo = [EMSDeviceInfo nullMock];
            [requestContext stub:@selector(meId) andReturn:@"fakeMeId"];
            [requestContext stub:@selector(deviceInfo) andReturn:deviceInfo];
            requestFactory = [EMSRequestFactory nullMock];
            requestManager = [EMSRequestManager nullMock];
            notificationCenterManagerMock = [MENotificationCenterManager nullMock];
            appStartBlockProvider = [AppStartBlockProvider nullMock];
            deviceInfoClient = [KWMock nullMockForProtocol:@protocol(EMSDeviceInfoClientProtocol)];

            dependencyContainer = [[FakeDependencyContainer alloc] initWithDbHelper:nil
                                                                       mobileEngage:engage
                                                                           deepLink:deepLink
                                                                               push:push
                                                                              inbox:nil
                                                                                iam:nil
                                                                            predict:predict
                                                                     requestContext:requestContext
                                                                     requestFactory:requestFactory
                                                                  requestRepository:nil
                                                                  notificationCache:nil
                                                                   responseHandlers:nil
                                                                     requestManager:requestManager
                                                                     operationQueue:nil
                                                          notificationCenterManager:notificationCenterManagerMock
                                                              appStartBlockProvider:appStartBlockProvider
                                                                   deviceInfoClient:deviceInfoClient
                                                                             logger:[EMSLogger nullMock]];

            [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                               withDependencyContainer:dependencyContainer];
        });

        afterEach(^{
            [EmarsysTestUtils tearDownEmarsys];
        });

        describe(@"setupWithConfig:", ^{

            it(@"should set predict", ^{
                [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                   withDependencyContainer:nil];
                [[(NSObject *) [Emarsys predict] shouldNot] beNil];
            });

            it(@"should set push", ^{
                [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                   withDependencyContainer:nil];
                [[(NSObject *) [Emarsys push] shouldNot] beNil];
            });

            it(@"should set notificationCenterDelegate", ^{
                [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                   withDependencyContainer:nil];
                [[(NSObject *) [Emarsys notificationCenterDelegate] shouldNot] beNil];
            });

            it(@"register triggers", ^{
                [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                   withDependencyContainer:nil];
                NSDictionary *triggers = [[Emarsys sqliteHelper] registeredTriggers];

                NSArray *afterInsertTriggers = triggers[[[EMSDBTriggerKey alloc] initWithTableName:@"shard"
                                                                                         withEvent:[EMSDBTriggerEvent insertEvent]
                                                                                          withType:[EMSDBTriggerType afterType]]];
                [[theValue([afterInsertTriggers count]) should] equal:theValue(2)];
                [[afterInsertTriggers should] contain:EMSDependencyInjection.dependencyContainer.loggerTrigger];
                [[afterInsertTriggers should] contain:EMSDependencyInjection.dependencyContainer.predictTrigger];
            });

            it(@"should throw an exception when there is no config set", ^{
                @try {
                    [Emarsys setupWithConfig:nil];
                    fail(@"Expected Exception when config is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: config"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            context(@"ResponseHandlers", ^{

                it(@"should register MEIAMResponseHandler", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register MEIAMCleanupResponseHandler", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                    BOOL registered = NO;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[MEIAMCleanupResponseHandler class]]) {
                            registered = YES;
                        }
                    }

                    [[theValue(registered) should] beYes];
                });

                it(@"should register EMSVisitorIdResponseHandler if no features are turned on", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register EMSVisitorIdResponseHandler", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSVisitorIdResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should register EMSClientStateResponseHandler", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:nil];

                    NSUInteger registerCount = 0;
                    for (EMSAbstractResponseHandler *responseHandler in EMSDependencyInjection.dependencyContainer.responseHandlers) {
                        if ([responseHandler isKindOfClass:[EMSClientStateResponseHandler class]]) {
                            registerCount++;
                        }
                    }

                    [[theValue(registerCount) should] equal:theValue(1)];
                });

                it(@"should initialize responseHandlers", ^{
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:nil];

                    [[theValue([EMSDependencyInjection.dependencyContainer.responseHandlers count]) should] equal:theValue(6)];
                });
            });

            context(@"appStart", ^{

                it(@"should register UIApplicationDidBecomeActiveNotification", ^{
                    void (^appStartBlock)() = ^{
                    };
                    void (^appStartBlock2)() = ^{
                    };
                    [[appStartBlockProvider should] receive:@selector(createAppStartEventBlock)
                                                  andReturn:appStartBlock
                                              withArguments:requestManager, requestContext];
                    [[appStartBlockProvider should] receive:@selector(createDeviceInfoEventBlock)
                                                  andReturn:appStartBlock2
                                              withArguments:requestManager, requestFactory, deviceInfo];
                    [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                      withArguments:appStartBlock,
                                                                    UIApplicationDidBecomeActiveNotification];
                    [[notificationCenterManagerMock should] receive:@selector(addHandlerBlock:forNotification:)
                                                      withArguments:appStartBlock2,
                                                                    UIApplicationDidBecomeActiveNotification];
                    [EmarsysTestUtils setupEmarsysWithFeatures:@[]
                                       withDependencyContainer:dependencyContainer];
                });

            });

            context(@"automatic anonym applogin", ^{

                it(@"setupWithConfig should send deviceInfo and login", ^{
                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                            applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                        [builder setMerchantId:@"1428C8EE286EC34B"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils tearDownEmarsys];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[deviceInfoClient should] receive:@selector(sendDeviceInfoWithCompletionBlock:)];
                    [[engage should] receive:@selector(setContactWithContactFieldValue:)
                               withArguments:kw_any()];

                    [Emarsys setupWithConfig:config];
                });

                it(@"setupWithConfig should not send deviceInfo and login when contactFieldValue is available", ^{
                    [requestContext stub:@selector(contactFieldValue)
                               andReturn:@"testContactFieldValue"];

                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                            applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                        [builder setMerchantId:@"1428C8EE286EC34B"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils tearDownEmarsys];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[deviceInfoClient shouldNot] receive:@selector(sendDeviceInfoWithCompletionBlock:)];
                    [[engage shouldNot] receive:@selector(setContactWithContactFieldValue:)
                                  withArguments:kw_any()];

                    [Emarsys setupWithConfig:config];
                });

                it(@"setupWithConfig should not send deviceInfo and login when contactToken is available", ^{
                    [requestContext stub:@selector(contactToken)
                               andReturn:@"testContactToken"];

                    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
                        [builder setMobileEngageApplicationCode:@"14C19-A121F"
                                            applicationPassword:@"PaNkfOD90AVpYimMBuZopCpm8OWCrREu"];
                        [builder setMerchantId:@"1428C8EE286EC34B"];
                        [builder setContactFieldId:@3];
                    }];
                    [EmarsysTestUtils tearDownEmarsys];
                    [EmarsysTestUtils setupEmarsysWithConfig:config
                                         dependencyContainer:dependencyContainer];

                    [[deviceInfoClient shouldNot] receive:@selector(sendDeviceInfoWithCompletionBlock:)];
                    [[engage shouldNot] receive:@selector(setContactWithContactFieldValue:)
                                  withArguments:kw_any()];

                    [Emarsys setupWithConfig:config];
                });

            });
        });

        describe(@"setCustomerWithCustomerId:resultBlock:", ^{
            it(@"should delegate the call to predictInternal", ^{
                [[predict should] receive:@selector(setCustomerWithId:)
                            withArguments:customerId];
                [Emarsys setContactWithContactFieldValue:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal", ^{
                [[engage should] receive:@selector(setContactWithContactFieldValue:completionBlock:)
                           withArguments:customerId, kw_any()];
                [Emarsys setContactWithContactFieldValue:customerId];
            });

            it(@"should delegate the call to mobileEngageInternal with customerId and completionBlock", ^{
                void (^ const completionBlock)(NSError *) = ^(NSError *error) {
                };

                [[engage should] receive:@selector(setContactWithContactFieldValue:completionBlock:)
                           withArguments:customerId, completionBlock];

                [Emarsys setContactWithContactFieldValue:customerId
                                         completionBlock:completionBlock];
            });
        });

        describe(@"clearContact", ^{
            it(@"should delegate call to MobileEngage", ^{
                [[engage should] receive:@selector(clearContactWithCompletionBlock:)];

                [Emarsys clearContact];
            });

            it(@"should delegate call to Predict", ^{
                [[predict should] receive:@selector(clearCustomer)];

                [Emarsys clearContact];
            });
        });

        describe(@"trackDeepLinkWithUserActivity:sourceHandler:", ^{

            it(@"should delegate call to MobileEngage", ^{
                NSUserActivity *userActivity = [NSUserActivity mock];
                EMSSourceHandler sourceHandler = ^(NSString *source) {
                };

                [[deepLink should] receive:@selector(trackDeepLinkWith:sourceHandler:)
                             withArguments:userActivity, sourceHandler];

                [Emarsys trackDeepLinkWithUserActivity:userActivity
                                         sourceHandler:sourceHandler];
            });
        });

        describe(@"trackCustomEventWithName:eventAttributes:completionBlock:", ^{

            it(@"should delegate call to MobileEngage with nil completionBlock", ^{
                NSString *eventName = @"eventName";
                NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};

                [[engage should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                           withArguments:eventName, eventAttributes, kw_any()];

                [Emarsys trackCustomEventWithName:eventName
                                  eventAttributes:eventAttributes];
            });

            it(@"should delegate call to MobileEngage", ^{
                NSString *eventName = @"eventName";
                NSDictionary<NSString *, NSString *> *eventAttributes = @{@"key": @"value"};
                EMSCompletionBlock completionBlock = ^(NSError *error) {
                };

                [[engage should] receive:@selector(trackCustomEventWithName:eventAttributes:completionBlock:)
                           withArguments:eventName, eventAttributes, completionBlock];

                [Emarsys trackCustomEventWithName:eventName
                                  eventAttributes:eventAttributes
                                  completionBlock:completionBlock];
            });
        });

        describe(@"trackMessageOpenWithUserInfo:completionBlock:", ^{

            NSDictionary *const userInfo = @{@"u": @"{\"sid\":\"dd8_zXfDdndBNEQi\"}"};

            it(@"should delegate call to MobileEngage with nil completionBlock", ^{
                [[push should] receive:@selector(trackMessageOpenWithUserInfo:)
                         withArguments:userInfo];

                [Emarsys.push trackMessageOpenWithUserInfo:userInfo];
            });

            it(@"should delegate call to MobileEngage", ^{
                EMSCompletionBlock completionBlock = ^(NSError *error) {
                };

                [[push should] receive:@selector(trackMessageOpenWithUserInfo:completionBlock:)
                         withArguments:userInfo, completionBlock];

                [Emarsys.push trackMessageOpenWithUserInfo:userInfo
                                           completionBlock:completionBlock];
            });
        });

        context(@"production setup", ^{

            beforeEach(^{
                [EMSDependencyInjection tearDown];
                [EmarsysTestUtils setupEmarsysWithFeatures:@[] withDependencyContainer:nil];
            });

            describe(@"push", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.push) shouldNot] beNil];
                });
            });

            describe(@"inbox", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.inbox) shouldNot] beNil];
                });
            });

            describe(@"inApp", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.inApp) shouldNot] beNil];
                });
            });

            describe(@"predict", ^{
                it(@"should not be nil", ^{
                    [[((NSObject *) Emarsys.predict) shouldNot] beNil];
                });
            });
        });

SPEC_END

//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInAppInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

@interface EMSInAppInternalTests : XCTestCase

@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSInAppInternal *internal;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;

@end

@implementation EMSInAppInternalTests

- (void)setUp {
    _timestampProvider = [EMSTimestampProvider new];
    _uuidProvider = [EMSUUIDProvider new];

    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _internal = [[EMSInAppInternal alloc] initWithRequestManager:self.mockRequestManager
                                                  requestFactory:self.mockRequestFactory];
}

- (void)tearDown {
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSInAppInternal alloc] initWithRequestManager:nil
                                          requestFactory:self.mockRequestFactory];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSInAppInternal alloc] initWithRequestManager:self.mockRequestManager
                                          requestFactory:nil];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testTrackInAppDisplay {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *campaignId = @"testCampaignId";
    NSString *eventName = @"inapp:viewed";
    NSDictionary *eventAttributes = @{@"message_id": campaignId};

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                          eventAttributes:eventAttributes
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    [self.internal trackInAppDisplay:campaignId];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                            eventAttributes:eventAttributes
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
}

- (void)testTrackInAppDisplay_shouldNotCallRequestFactory_andRequestManager_whenCampaignId_isNil {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                            eventAttributes:[OCMArg any]
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(requestModel);
    [self.internal trackInAppDisplay:nil];
}

- (void)testTrackInAppClickButtonId {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *campaignId = @"testCampaignId";
    NSString *buttonId = @"testButtonId";
    NSString *eventName = @"inapp:click";
    NSDictionary *eventAttributes = @{
            @"message_id": campaignId,
            @"button_id": buttonId
    };

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                          eventAttributes:eventAttributes
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    [self.internal trackInAppClick:campaignId
                          buttonId:buttonId];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                            eventAttributes:eventAttributes
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
}

- (void)testTrackInAppClickButtonId_shouldNotCallRequestFactory_andRequestManager_whenCampaignId_isNil {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                            eventAttributes:[OCMArg any]
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(requestModel);
    [self.internal trackInAppClick:nil
                          buttonId:@"testButtonId"];
}

- (void)testTrackInAppClickButtonId_shouldNotCallRequestFactory_andRequestManager_whenButtonId_isNil {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                            eventAttributes:[OCMArg any]
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(requestModel);
    [self.internal trackInAppClick:@"testCampaignId"
                          buttonId:nil];
}

- (EMSRequestModel *)createRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
            }             timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

@end

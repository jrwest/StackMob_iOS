// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#define USE_APPLICATION_UNIT_TEST 0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "StackMob.h"
#import "StackMobTestUtils.h"
#import "StackMobTestCommon.h"

//#import "application_headers" as required


@interface StackMobPushTests : StackMobTestCommon {
    NSDictionary * pushPayload;
    NSArray * pushUserTargets;
    NSArray * pushTokenTargets;
    NSString * pushUser;
    NSString * pushToken;

}

- (void)assertResultIsQueued:(NSDictionary *)result;
- (void)registerToken;

- (void)setUp;
- (void)tearDown;

- (void)testRegisterDeviceToken;
- (void)testGetDeviceTokens;
- (void)testSendPushBroadcastWithArguments;
@end


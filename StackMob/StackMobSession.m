// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "StackMobSession.h"

@interface StackMobSession(Private)
- (void)setup;
@end

@implementation StackMobSession

static const int kMaxBurstRequests = 3;
static const NSTimeInterval kBurstDuration = 2;

static StackMobSession* sharedSession = nil;

@synthesize apiKey = _apiKey;
@synthesize apiSecret = _apiSecret;
@synthesize appName = _appName;
@synthesize subDomain = _subDomain;
@synthesize domain = _domain;
@synthesize userObjectName = _userObjectName;
@synthesize apiVersionNumber = _apiVersionNumber;
@synthesize sessionKey = _sessionKey;
@synthesize expirationDate = _expirationDate;
@synthesize pushURL;

+ (StackMobSession*)session {
	return sharedSession;
}


+ (StackMobSession*)sessionForApplication:(NSString*)key 
                                   secret:(NSString*)secret
                                  appName:(NSString*)appName
                                subDomain:(NSString*)subDomain
                         apiVersionNumber:(NSNumber*)apiVersionNumber 
{
	return [self sessionForApplication:key secret:secret appName:appName 
							 subDomain:subDomain domain:SMDefaultDomain apiVersionNumber:apiVersionNumber];
}

+ (StackMobSession*)sessionForApplication:(NSString*)key 
                                   secret:(NSString*)secret 
                                  appName:(NSString*)appName
                                subDomain:(NSString*)subDomain 
                                   domain:(NSString*)domain 
                         apiVersionNumber:(NSNumber*)apiVersionNumber
{
	StackMobSession* session = [[[StackMobSession alloc] initWithKey:key 
                                                              secret:secret 
                                                             appName:appName
                                                           subDomain:subDomain 
                                                              domain:domain
                                                    apiVersionNumber:apiVersionNumber] autorelease];
	return session;
}

+ (StackMobSession*)sessionForApplication:(NSString*)key 
                                   secret:(NSString*)secret 
                                  appName:(NSString*)appName
                                subDomain:(NSString*)subDomain 
                                   domain:(NSString*)domain 
                           userObjectName:(NSString*)userObjectName
                         apiVersionNumber:(NSNumber*)apiVersionNumber
{
	StackMobSession* session = [[[StackMobSession alloc] initWithKey:key 
                                                              secret:secret 
                                                             appName:appName
                                                           subDomain:subDomain 
                                                              domain:domain
                                                      userObjectName:userObjectName
                                                    apiVersionNumber:apiVersionNumber] autorelease];
    SMLog(@"apiVersionNumber %@", apiVersionNumber);
	return session;
}

- (NSMutableString*)urlForMethod:(NSString*)method isUserBased:(BOOL)userBasedRequest isSecure:(BOOL)isSecure
{
  NSMutableArray *parts = [NSMutableArray array];
  [parts addObject:(isSecure ? secureURL : regularURL)];
  
  if(userBasedRequest) [parts addObject:self.userObjectName];
  [parts addObject:method];
  
  NSMutableString *urlString = [NSMutableString stringWithString:[parts componentsJoinedByString:@"/"]];
  return urlString;
}

- (NSMutableString*)secureURLForMethod:(NSString*)method isUserBased:(BOOL)userBasedRequest {
  return  [self urlForMethod:method isUserBased:userBasedRequest isSecure:YES];
}

- (NSMutableString*)urlForMethod:(NSString*)method isUserBased:(BOOL)userBasedRequest {
  return  [self urlForMethod:method isUserBased:userBasedRequest isSecure:NO];
}

- (StackMobSession*)initWithKey:(NSString*)key 
                         secret:(NSString*)secret 
                        appName:(NSString*)appName
                      subDomain:(NSString*)subDomain 
                         domain:(NSString*)domain 
               apiVersionNumber:(NSNumber*)apiVersionNumber
{
	if ((self = [super init])) {
		if (!sharedSession) {
			sharedSession = self;
		}
		_apiKey = [key copy];
		_apiSecret = [secret copy];
		_appName = [appName copy];
		_subDomain = [subDomain copy];
		_domain = [domain copy];
        _apiVersionNumber = [apiVersionNumber copy];
        [self setup];
	}
	return self;
}

- (StackMobSession*)initWithKey:(NSString*)key 
                         secret:(NSString*)secret 
                        appName:(NSString*)appName
                      subDomain:(NSString*)subDomain 
                         domain:(NSString*)domain 
                 userObjectName:(NSString *)userObjectName
               apiVersionNumber:(NSNumber*)apiVersionNumber
{
	if ((self = [super init])) {
		if (!sharedSession) {
			sharedSession = self;
		}
        _apiKey = [key copy];
        _apiSecret = [secret copy];
        _appName = [appName copy];
        _subDomain = [subDomain copy];
        _domain = [domain copy];
        _userObjectName = [userObjectName copy];
        _apiVersionNumber = [apiVersionNumber copy];
        [self setup];
	}
	return self;
}

- (void)setup{
    _sessionKey = nil;
    _expirationDate = nil;
    _requestQueue = [[NSMutableArray alloc] init];
    _lastRequestTime = nil;
    _requestBurstCount = 0;
    _requestTimer = nil; 
    url = [[NSString stringWithFormat:@"%@.%@/api/%@/%@",_subDomain,_domain,_apiVersionNumber,_appName] retain];
    pushURL = [[NSString stringWithFormat:@"http://%@.%@/push/%@/%@",_subDomain,_domain,_apiVersionNumber,_appName] retain];
    secureURL = [[NSString stringWithFormat:@"https://%@", url] retain];
    regularURL = [[NSString stringWithFormat:@"http://%@", url] retain];
}

- (void)dealloc {
    SMLog(@"StackMobSession: dealloc");
	if (sharedSession == self) {
		sharedSession = nil;
	}
	
	[_apiKey release];
	[_apiSecret release];
	[_appName release];
	[_subDomain release];
	[_domain release];
    [_userObjectName release];
    [_apiVersionNumber release];
	[_sessionKey release];
	[_expirationDate release];
	[_lastRequestTime release];
	[_requestQueue release];
	[_requestTimer release]; 
	[url release];
	[secureURL release];
	[regularURL release];
	[super dealloc];
    SMLog(@"StackMobSession: dealloc finished");
}

- (NSString*)apiURL {
	return regularURL;
}

- (NSString*)apiSecureURL {
	return secureURL;
}


- (NSString *)userAgentString {
    return [NSString stringWithFormat:@"StackMob (iOS; %@)/%@", STACKMOB_SDK_VERSION, _appName];
}

@end

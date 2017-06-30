//
//  STPAPIRequestTest.m
//  Stripe
//
//  Created by Ben Guo on 5/10/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Stripe/Stripe.h>
#import "STPAPIRequest.h"
#import "STPTestUtils.h"

@interface STPAPIRequest ()

+ (void)parseResponse:(NSURLResponse *)response body:(NSData *)body error:(NSError *)error deserializers:(NSArray<id<STPAPIResponseDecodable>>*)deserializers completion:(STPAPIResponseBlock)completion;

@end

@interface STPAPIRequestTest : XCTestCase

@end

@implementation STPAPIRequestTest

- (void)testParseResponseWithMultipleSerializers {
    XCTestExpectation *exp = [self expectationWithDescription:@"parseResponse"];
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];
    NSDictionary *json = [STPTestUtils jsonNamed:@"CardSource"];
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)kNilOptions error:nil];
    NSArray *deserializers = @[[STPCard new], [STPSource new]];
    [STPAPIRequest parseResponse:httpURLResponse body:body error:nil deserializers:deserializers completion:^(id<STPAPIResponseDecodable> object, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(object, [STPSource decodedObjectFromAPIResponse:json]);
        XCTAssertEqualObjects(response, httpURLResponse);
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testParseResponseWithMultipleSerializersNoMatchingObject {
    XCTestExpectation *exp = [self expectationWithDescription:@"parseResponse"];
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];
    NSDictionary *json = [STPTestUtils jsonNamed:@"CardSource"];
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)kNilOptions error:nil];
    NSArray *deserializers = @[[STPFile new], [STPBankAccount new]];
    [STPAPIRequest parseResponse:httpURLResponse body:body error:nil deserializers:deserializers completion:^(id<STPAPIResponseDecodable> object, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(object);
        XCTAssertEqualObjects(response, httpURLResponse);
        XCTAssertEqualObjects(error, [NSError stp_genericFailedToParseResponseError]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];   
}

- (void)testParseResponseWithOneSerializer {
    XCTestExpectation *exp = [self expectationWithDescription:@"parseResponse"];
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];
    NSDictionary *json = [STPTestUtils jsonNamed:@"Customer"];
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)kNilOptions error:nil];
    NSArray *deserializers = @[[STPCustomer new]];
    [STPAPIRequest parseResponse:httpURLResponse body:body error:nil deserializers:deserializers completion:^(id<STPAPIResponseDecodable> object, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(((STPCustomer *)object).stripeID, json[@"id"]);
        XCTAssertEqualObjects(response, httpURLResponse);
        XCTAssertNil(error);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testParseResponseWithNoSerializers {
    XCTestExpectation *exp = [self expectationWithDescription:@"parseResponse"];
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];
    NSDictionary *json = [STPTestUtils jsonNamed:@"EphemeralKey"];
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)kNilOptions error:nil];
    NSArray *deserializers = @[];
    [STPAPIRequest parseResponse:httpURLResponse body:body error:nil deserializers:deserializers completion:^(id<STPAPIResponseDecodable> object, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(object);
        XCTAssertEqualObjects(response, httpURLResponse);
        XCTAssertEqualObjects(error, [NSError stp_genericFailedToParseResponseError]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testParseResponseWithError {
    XCTestExpectation *exp = [self expectationWithDescription:@"parseResponse"];
    NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] init];
    NSDictionary *json = @{
                           @"error": @{
                                   @"type": @"invalid_request_error",
                                   @"message": @"Your card number is incorrect.",
                                   @"code": @"incorrect_number"
                                   }
                           };
    NSError *expectedError = [NSError stp_errorFromStripeResponse:json];
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingOptions)kNilOptions error:nil];
    NSArray *deserializers = @[[STPCard new]];
    [STPAPIRequest parseResponse:httpURLResponse body:body error:nil deserializers:deserializers completion:^(id<STPAPIResponseDecodable> object, NSHTTPURLResponse *response, NSError *error) {
        XCTAssertNil(object);
        XCTAssertEqualObjects(response, httpURLResponse);
        XCTAssertEqualObjects(error, expectedError);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end

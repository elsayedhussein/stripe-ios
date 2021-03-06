//
//  STPBankAccountParamsTest.m
//  Stripe
//
//  Created by Joey Dong on 6/19/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

@import XCTest;

#import "STPBankAccountParams.h"
#import "STPBankAccountParams+Private.h"

@interface STPBankAccountParamsTest : XCTestCase

@end

@implementation STPBankAccountParamsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -

- (void)testLast4ReturnsAccountNumberLast4 {
    STPBankAccountParams *bankAccountParams = [[STPBankAccountParams alloc] init];
    bankAccountParams.accountNumber = @"000123456789";
    XCTAssertEqualObjects(bankAccountParams.last4, @"6789");
}

- (void)testLast4ReturnsNilWhenNoAccountNumberSet {
    STPBankAccountParams *bankAccountParams = [[STPBankAccountParams alloc] init];
    XCTAssertNil(bankAccountParams.last4);
}

- (void)testLast4ReturnsNilWhenAccountNumberIsLessThanLength4 {
    STPBankAccountParams *bankAccountParams = [[STPBankAccountParams alloc] init];
    bankAccountParams.accountNumber = @"123";
    XCTAssertNil(bankAccountParams.last4);
}

#pragma mark - STPBankAccountHolderType Tests

- (void)testAccountHolderTypeFromString {
    XCTAssertEqual([STPBankAccountParams accountHolderTypeFromString:@"individual"], STPBankAccountHolderTypeIndividual);
    XCTAssertEqual([STPBankAccountParams accountHolderTypeFromString:@"INDIVIDUAL"], STPBankAccountHolderTypeIndividual);

    XCTAssertEqual([STPBankAccountParams accountHolderTypeFromString:@"company"], STPBankAccountHolderTypeCompany);
    XCTAssertEqual([STPBankAccountParams accountHolderTypeFromString:@"COMPANY"], STPBankAccountHolderTypeCompany);

    XCTAssertEqual([STPBankAccountParams accountHolderTypeFromString:@"garbage"], STPBankAccountHolderTypeIndividual);
    XCTAssertEqual([STPBankAccountParams accountHolderTypeFromString:@"GARBAGE"], STPBankAccountHolderTypeIndividual);
}

- (void)testStringFromAccountHolderType {
    NSArray<NSNumber *> *values = @[
                                    @(STPBankAccountHolderTypeIndividual),
                                    @(STPBankAccountHolderTypeCompany),
                                    ];

    for (NSNumber *accountHolderTypeNumber in values) {
        STPBankAccountHolderType accountHolderType = (STPBankAccountHolderType)[accountHolderTypeNumber integerValue];
        NSString *string = [STPBankAccountParams stringFromAccountHolderType:accountHolderType];

        switch (accountHolderType) {
            case STPBankAccountHolderTypeIndividual:
                XCTAssertEqualObjects(string, @"individual");
                break;
            case STPBankAccountHolderTypeCompany:
                XCTAssertEqualObjects(string, @"company");
                break;
        }
    }
}

#pragma mark - Description Tests

- (void)testDescriptionWorks {
    STPBankAccountParams *bankAccountParams = [[STPBankAccountParams alloc] init];
    bankAccountParams.accountNumber = @"000123456789";
    bankAccountParams.routingNumber = @"123456789";
    bankAccountParams.country = @"US";
    bankAccountParams.currency = @"usd";
    bankAccountParams.accountHolderName = @"John Doe";
    bankAccountParams.accountHolderType = STPBankAccountHolderTypeCompany;
    XCTAssert(bankAccountParams.description);
}

#pragma mark - STPFormEncodable Tests

- (void)testRootObjectName {
    XCTAssertEqualObjects([STPBankAccountParams rootObjectName], @"bank_account");
}

- (void)testPropertyNamesToFormFieldNamesMapping {
    STPBankAccountParams *bankAccountParams = [[STPBankAccountParams alloc] init];

    NSDictionary *mapping = [STPBankAccountParams propertyNamesToFormFieldNamesMapping];

    for (NSString *propertyName in [mapping allKeys]) {
        XCTAssert([bankAccountParams respondsToSelector:NSSelectorFromString(propertyName)]);
    }

    for (NSString *formFieldName in [mapping allValues]) {
        XCTAssert([formFieldName isKindOfClass:[NSString class]]);
        XCTAssert([formFieldName length] > 0);
    }

    XCTAssertEqual([[mapping allValues] count], [[NSSet setWithArray:[mapping allValues]] count]);
}

- (void)testAccountHolderTypeString {
    STPBankAccountParams *bankAccountParams = [[STPBankAccountParams alloc] init];

    bankAccountParams.accountHolderType = STPBankAccountHolderTypeIndividual;
    XCTAssertEqualObjects([bankAccountParams accountHolderTypeString], @"individual");

    bankAccountParams.accountHolderType = STPBankAccountHolderTypeCompany;
    XCTAssertEqualObjects([bankAccountParams accountHolderTypeString], @"company");
}

@end

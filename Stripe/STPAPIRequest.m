//
//  STPAPIRequest.m
//  Stripe
//
//  Created by Jack Flintermann on 10/14/15.
//  Copyright © 2015 Stripe, Inc. All rights reserved.
//

#import "STPAPIRequest.h"

#import "NSMutableURLRequest+Stripe.h"
#import "STPInternalAPIResponseDecodable.h"
#import "STPAPIClient+Private.h"
#import "STPAPIClient.h"
#import "STPCard+Private.h"
#import "STPDispatchFunctions.h"
#import "STPFormEncoder.h"
#import "STPSource+Private.h"
#import "StripeError.h"

@implementation STPAPIRequest

#pragma mark - POST

+ (NSURLSessionDataTask *)postWithAPIClient:(STPAPIClient *)apiClient
                                   endpoint:(NSString *)endpoint
                                 parameters:(NSDictionary *)parameters
                               deserializer:(id<STPAPIResponseDecodable>)deserializer
                                 completion:(STPAPIResponseBlock)completion {
    return [self postWithAPIClient:apiClient endpoint:endpoint parameters:parameters deserializers:@[deserializer] completion:completion];
}

+ (NSURLSessionDataTask *)postWithAPIClient:(STPAPIClient *)apiClient
                                   endpoint:(NSString *)endpoint
                                 parameters:(NSDictionary *)parameters
                              deserializers:(NSArray<id<STPAPIResponseDecodable>>*)deserializers
                                 completion:(STPAPIResponseBlock)completion {
    // Build url
    NSURL *url = [apiClient.apiURL URLByAppendingPathComponent:endpoint];

    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request stp_setFormPayload:parameters];

    // Perform request
    NSURLSessionDataTask *task = [apiClient.urlSession dataTaskWithRequest:request completionHandler:^(NSData *body, NSURLResponse *response, NSError *error) {
        [[self class] parseResponse:response body:body error:error deserializers:deserializers completion:completion];
    }];
    [task resume];

    return task;
}

#pragma mark - GET

+ (NSURLSessionDataTask *)getWithAPIClient:(STPAPIClient *)apiClient
                                  endpoint:(NSString *)endpoint
                                parameters:(NSDictionary *)parameters
                              deserializer:(id<STPAPIResponseDecodable>)deserializer
                                completion:(STPAPIResponseBlock)completion {
    // Build url
    NSURL *url = [apiClient.apiURL URLByAppendingPathComponent:endpoint];

    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request stp_addParametersToURL:parameters];
    request.HTTPMethod = @"GET";

    // Perform request
    NSURLSessionDataTask *task = [apiClient.urlSession dataTaskWithRequest:request completionHandler:^(NSData *body, NSURLResponse *response, NSError *error) {
        [[self class] parseResponse:response body:body error:error deserializers:@[deserializer] completion:completion];
    }];
    [task resume];

    return task;
}

#pragma mark - DELETE

+ (NSURLSessionDataTask *)deleteWithAPIClient:(STPAPIClient *)apiClient
                                     endpoint:(NSString *)endpoint
                                   parameters:(NSDictionary *)parameters
                                 deserializer:(id<STPAPIResponseDecodable>)deserializer
                                   completion:(STPAPIResponseBlock)completion {
    return [self deleteWithAPIClient:apiClient endpoint:endpoint parameters:parameters deserializers:@[deserializer] completion:completion];
}

+ (NSURLSessionDataTask *)deleteWithAPIClient:(STPAPIClient *)apiClient
                                     endpoint:(NSString *)endpoint
                                   parameters:(NSDictionary *)parameters
                                deserializers:(NSArray<id<STPAPIResponseDecodable>> *)deserializers
                                   completion:(STPAPIResponseBlock)completion {
    // Build url
    NSURL *url = [apiClient.apiURL URLByAppendingPathComponent:endpoint];

    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request stp_addParametersToURL:parameters];
    request.HTTPMethod = @"DELETE";

    // Perform request
    NSURLSessionDataTask *task = [apiClient.urlSession dataTaskWithRequest:request completionHandler:^(NSData *body, NSURLResponse *response, NSError *error) {
        [[self class] parseResponse:response body:body error:error deserializers:deserializers completion:completion];
    }];
    [task resume];

    return task;
}

#pragma mark -

+ (void)parseResponse:(NSURLResponse *)response
                 body:(NSData *)body
                error:(NSError *)error
        deserializers:(NSArray<id<STPAPIResponseDecodable>>*)deserializers
           completion:(STPAPIResponseBlock)completion {
    // Derive HTTP URL response
    NSHTTPURLResponse *httpResponse;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *)response;
    }

    // Wrap completion block with main thread dispatch
    void (^safeCompletion)(id<STPAPIResponseDecodable>, NSError *) = ^(id<STPAPIResponseDecodable> responseObject, NSError *responseError) {
        stpDispatchToMainThreadIfNecessary(^{
            completion(responseObject, httpResponse, responseError);
        });
    };

    if (deserializers.count == 0) {
        // Missing deserializers
        return safeCompletion(nil, [NSError stp_genericFailedToParseResponseError]);
    }

    // Parse JSON response body
    NSDictionary *jsonDictionary = nil;
    if (body) {
        jsonDictionary = [NSJSONSerialization JSONObjectWithData:body options:(NSJSONReadingOptions)kNilOptions error:NULL];  // TODO: [joeydong] Should we handle the error object?
    }

    // Determine appropriate deserializer
    NSString *objectString = jsonDictionary[@"object"];

    Class deserializerClass;
    if (deserializers.count == 1) {
        // Legacy deserializers don't always define `stripeObject` method
        deserializerClass = [deserializers.firstObject class];
    } else {
        for (id<STPAPIResponseDecodable> deserializer in deserializers) {
            if ([deserializer respondsToSelector:@selector(stripeObject)]
                && [[(id<STPInternalAPIResponseDecodable>)deserializer stripeObject] isEqualToString:objectString]) {
                // Found matching deserializer
                deserializerClass = [deserializer class];
            }
        }
    }
    if (!deserializerClass) {
        // No deserializer for response body
        return safeCompletion(nil, [NSError stp_genericFailedToParseResponseError]);
    }

    // Generate response object
    id<STPAPIResponseDecodable> responseObject = [deserializerClass decodedObjectFromAPIResponse:jsonDictionary];

    if (!responseObject) {
        // Failed to parse response
        NSError *parsedError = [NSError stp_errorFromStripeResponse:jsonDictionary];

        if (parsedError) {
            // Use response body error
            return safeCompletion(nil, parsedError);
        }

        if (error) {
            // Use NSURLSession error
            return safeCompletion(nil, error);
        }

        // Use generic error
        return safeCompletion(nil, [NSError stp_genericFailedToParseResponseError]);
    }

    return safeCompletion(responseObject, nil);
}

@end

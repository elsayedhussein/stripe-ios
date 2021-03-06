//
//  STPFile+Private.h
//  Stripe
//
//  Created by Joey Dong on 6/20/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import "STPFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface STPFile ()

+ (STPFilePurpose)purposeFromString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

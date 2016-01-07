//
//  HKIAPStoreItem.m
//  HKIAPManager
//
//  Created by Harley.xk on 16/1/6.
//  Copyright © 2016年 Harley.xk. All rights reserved.
//

#import "HKIAPStoreItem.h"

@implementation HKIAPStoreItem

- (NSString *)identifier
{
    return self.product.productIdentifier;
}

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.product.priceLocale];
    NSString *localizedString = [numberFormatter stringFromNumber:self.product.price];
    return localizedString;
}

@end

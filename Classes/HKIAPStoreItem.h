//
//  HKIAPStoreItem.h
//  HKIAPManager
//
//  Created by Harley.xk on 16/1/6.
//  Copyright © 2016年 Harley.xk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface HKIAPStoreItem : NSObject

/**
 *  内购商品信息
 */
@property (strong, nonatomic) SKProduct *product;

/**
 *  iTunes Connect 中设置的 ID
 */
- (NSString *)identifier;

- (NSString *)localizedPrice;

/**
 *  是否已购买此内购商品
 */
@property (assign, nonatomic, getter=isPurchased) BOOL purchased;

@end

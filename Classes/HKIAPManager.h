//
//  HKIAPManager.h
//  HKIAPManager
//
//  Created by Harley.xk on 16/1/6.
//  Copyright © 2016年 Harley.xk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "HKIAPResponse.h"
#import "HKIAPStoreItem.h"


@interface HKIAPManager : NSObject

/**
 *  单例对象
 */
+ (instancetype)sharedManager;

/**
 *  是否可以进行应用内购买,(IAP 可能会被禁用)
 */
- (BOOL)isIAPEnabled;

/**
 *  传入设置好的内购商品ID
 */
- (void)setStoreItemIdentifiers:(NSArray *)identifiers;

/**
 *  更新内购信息
 */
- (void)updateStoreItemsFinished:(HKIAPResponseHandler)finished;

/**
 *  可用的内购商品，需要先更新内购信息，否则返回空
 */
- (NSArray<HKIAPStoreItem *> *)avaliableStoreItems;

/**
 *  购买内购商品
 */
- (void)purchaseItem:(HKIAPStoreItem *)item finished:(HKIAPResponseHandler)finished;

/**
 *  恢复已经购买的内购商品
 */
- (void)restorePurchasedItemsFinished:(HKIAPResponseHandler)finished;


@end

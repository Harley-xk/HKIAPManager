//
//  HKIAPResponse.h
//  HKIAPManager
//
//  Created by Harley.xk on 16/1/6.
//  Copyright © 2016年 Harley.xk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKIAPStoreItem.h"

typedef NS_ENUM(NSUInteger, HKIAPPurchaseResponseStatus)
{
    HKIAPPurchaseResponseStatusSucceed,
    HKIAPPurchaseResponseStatusFailed,
    HKIAPPurchaseResponseStatusCanceled,
    HKIAPPurchaseResponseStatusAlreadyPurchased
};

/**
 *  IAP 操作的结果
 */
@interface HKIAPResponse : NSObject

@property (assign, nonatomic, readonly) BOOL succeed;
@property (copy,   nonatomic, readonly) NSString *message;
@property (strong, nonatomic, readonly) NSError *error;

+ (instancetype)succeedResponse;
+ (instancetype)responseWithError:(NSError *)error;

/**
 *  购买状态，不是购买的回调忽略此参数
 */
@property (assign, nonatomic) HKIAPPurchaseResponseStatus purchaseStatus;

/**
 *  恢复购买的商品列表,只有在成功恢复后的返回结果中才有值
 */
@property (strong, nonatomic) NSArray<HKIAPStoreItem *> *restoredItems;

@end

/**
 *  IAP 操作的结果回调
 */
typedef void(^HKIAPResponseHandler)(HKIAPResponse *response);

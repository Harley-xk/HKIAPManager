//
//  HKIAPManager.m
//  HKIAPManager
//
//  Created by Harley.xk on 16/1/6.
//  Copyright © 2016年 Harley.xk. All rights reserved.
//

#import "HKIAPManager.h"

#pragma mark - HKIAPLOG

#if !defined(DEBUG) || DEBUG == 0
#define HKIAPLOG(format, ...) do {}while(0)
#elif DEBUG >= 1
#define HKIAPLOG(format, ...) \
do { \
if (format) { \
HKIAPLogContent([NSString stringWithFormat:format,##__VA_ARGS__]); \
} \
} while (0)
#endif
extern void HKIAPLogContent(NSString *string);

#pragma mark -

@interface HKIAPManager ()
<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (strong, nonatomic) NSArray *storeItemIdentifiers;
@property (strong, nonatomic) NSMutableArray *storeItems;

@property (copy,   nonatomic) HKIAPResponseHandler updateHandler;
@property (copy,   nonatomic) HKIAPResponseHandler purchaseHandler;
@property (copy,   nonatomic) HKIAPResponseHandler restoreHandler;
@end

@implementation HKIAPManager

+ (instancetype)sharedManager
{
    static HKIAPManager *sharedHKIAPManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHKIAPManager = [HKIAPManager new];
    });
    return sharedHKIAPManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (BOOL)isIAPEnabled
{
    return [SKPaymentQueue canMakePayments];
}

- (void)setStoreItemIdentifiers:(NSArray *)identifiers
{
    _storeItemIdentifiers = identifiers;
}

- (HKIAPStoreItem *)storeItemWithIdentifier:(NSString *)identifier
{
    for (HKIAPStoreItem *item in self.storeItems) {
        if ([item.identifier isEqualToString:identifier]) {
            return item;
        }
    }
    return nil;
}

- (void)addStoreItemWithProduct:(SKProduct *)product
{
    HKIAPStoreItem *item = [HKIAPStoreItem new];
    item.product = product;
    [self.storeItems addObject:item];
}

/**
 *  更新内购信息
 */
- (void)updateStoreItemsFinished:(HKIAPResponseHandler)finished
{
    HKIAPLOG(@"----- 更新内购商品 -----");
    
    self.updateHandler = finished;
    
    self.storeItems = [NSMutableArray array];
    NSSet *identifiers = [NSSet setWithArray:self.storeItemIdentifiers];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    request.delegate = self;
    [request start];
}

- (NSArray<HKIAPStoreItem *> *)avaliableStoreItems
{
    return [NSArray arrayWithArray:self.storeItems];
}

/**
 *  购买内购商品
 */
- (void)purchaseItem:(HKIAPStoreItem *)item finished:(HKIAPResponseHandler)finished
{
    HKIAPLOG(@"----- 购买商品 -----");
    HKIAPLOG(@"商品ID：%@",item.product.productIdentifier);
    HKIAPLOG(@"商品名称：%@",item.product.localizedTitle);
    
    self.purchaseHandler = finished;
    
    SKPayment *payment = [SKPayment paymentWithProduct:item.product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

/**
 *  恢复已经购买的内购商品
 */
- (void)restorePurchasedItemsFinished:(HKIAPResponseHandler)finished
{
    HKIAPLOG(@"----- 恢复已购商品 -----");
    
    self.restoreHandler = finished;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    HKIAPLOG(@"----- 变更购买队列 -----");
    for (SKPaymentTransaction *transaction in transactions)
    {
        HKIAPLOG(@"变更项目ID：%@",transaction.payment.productIdentifier);
        switch (transaction.transactionState)
        {
            //交易完成
            case SKPaymentTransactionStatePurchased:
                HKIAPLOG(@"--- 交易完成 ---");
                [self completeTransaction:transaction];
                break;
            //交易失败
            case SKPaymentTransactionStateFailed:
                HKIAPLOG(@"--- 交易失败 ---");
                [self transactionFailed:transaction];
                break;
            //已经购买过该商品
            case SKPaymentTransactionStateRestored:
                HKIAPLOG(@"--- 已经购买过该商品 ---");
                [self restoreTransaction:transaction];
                break;
            //商品添加进列表
            case SKPaymentTransactionStatePurchasing:
            HKIAPLOG(@"--- 商品加入购买队列 ---");
                break;
            default:
                break;
        }
    }
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (self.restoreHandler) {
        self.restoreHandler([HKIAPResponse responseWithError:error]);
        self.restoreHandler = nil;
    }
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            NSString *productIdentifier = transaction.payment.productIdentifier;
            if ([productIdentifier length] > 0) {
                HKIAPStoreItem *item = [self storeItemWithIdentifier:productIdentifier];
                item.purchased = YES;
            }
            // Remove the transaction from the payment queue.
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        }
    }
    if (self.restoreHandler) {
        self.restoreHandler([HKIAPResponse succeedResponse]);
        self.restoreHandler = nil;
    }
}

#pragma mark - Transaction Tasks
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.
    NSString *productIdentifier = transaction.payment.productIdentifier;
    if ([productIdentifier length] > 0)
    {
        HKIAPStoreItem *item = [self storeItemWithIdentifier:productIdentifier];
        item.purchased = YES;
        
        if (self.purchaseHandler) {
            self.purchaseHandler([HKIAPResponse succeedResponse]);
            self.purchaseHandler = nil;
        }
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        NSString *productIdentifier = transaction.payment.productIdentifier;
        if ([productIdentifier length] > 0) {
            HKIAPStoreItem *item = [self storeItemWithIdentifier:productIdentifier];
            item.purchased = YES;
            
            if (self.purchaseHandler) {
                HKIAPResponse *response = [HKIAPResponse responseWithError:nil];
                response.purchaseStatus = HKIAPPurchaseResponseStatusAlreadyPurchased;
                self.purchaseHandler(response);
                self.purchaseHandler = nil;
            }
        }
        // Remove the transaction from the payment queue.
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
}

- (void)transactionFailed:(SKPaymentTransaction *)transaction
{
    NSError *error = transaction.error;
    HKIAPLOG(@"原因：%@",error.localizedDescription);
    
    HKIAPResponse *response = [HKIAPResponse responseWithError:error];
    
    if (transaction.error.code == SKErrorPaymentCancelled) {
        response.purchaseStatus = HKIAPPurchaseResponseStatusCanceled;
    } else {
        response.purchaseStatus = HKIAPPurchaseResponseStatusFailed;
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if (self.purchaseHandler) {
        self.purchaseHandler(response);
        self.purchaseHandler = nil;
    }
}


#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    HKIAPLOG(@"----- 收到商品信息 -----");
    if (response.products && response.products.count > 0) {
        NSArray *products = response.products;
        HKIAPLOG(@"不合法的商品ID：%@",response.invalidProductIdentifiers);
        HKIAPLOG(@"商品数量：%i\n", (int)products.count);
        // populate UI
        for(SKProduct *product in products){
            HKIAPLOG(@"--- 商品信息 ---");
            HKIAPLOG(@"ID：%@",product.productIdentifier);
            HKIAPLOG(@"描述：%@",product.localizedDescription);
            HKIAPLOG(@"标题：%@",product.localizedTitle);
            HKIAPLOG(@"价格：%@",product.price);
            HKIAPLOG(@"对象信息：%@", [product description]);
            
            [self addStoreItemWithProduct:product];
        }
    }
    if (self.updateHandler) {
        self.updateHandler([HKIAPResponse succeedResponse]);
        self.updateHandler = nil;
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    HKIAPLOG(@"----- 商品更新成功 -----");
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    HKIAPLOG(@"-------商品更新失败----------");
    HKIAPLOG(@"原因：%@",error);
    
    if (self.updateHandler) {
        self.updateHandler([HKIAPResponse responseWithError:error]);
        self.updateHandler = nil;
    }
}


@end

void HKIAPLogContent(NSString *content)
{
    fprintf(stderr, "%s",[content UTF8String]);
}


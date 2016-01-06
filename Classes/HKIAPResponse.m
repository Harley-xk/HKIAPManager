//
//  HKIAPResponse.m
//  HKIAPManager
//
//  Created by Harley.xk on 16/1/6.
//  Copyright © 2016年 Harley.xk. All rights reserved.
//

#import "HKIAPResponse.h"

@interface HKIAPResponse ()
@property (assign, nonatomic) BOOL succeed;
@property (copy,   nonatomic) NSString *message;
@property (strong, nonatomic) NSError *error;
@end

@implementation HKIAPResponse

+ (instancetype)succeedResponse
{
    HKIAPResponse *response = [HKIAPResponse new];
    response.succeed = YES;
    return response;
}

+ (instancetype)responseWithError:(NSError *)error
{
    HKIAPResponse *response = [HKIAPResponse new];
    response.succeed = NO;
    response.error = error;
    response.message = error.localizedDescription;
    return response;

}


@end

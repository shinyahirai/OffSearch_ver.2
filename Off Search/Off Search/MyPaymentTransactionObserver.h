//
//  MyPaymentTransactionObserver.h
//  Off Search
//
//  Created by Shinya Hirai on 2013/12/10.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

// 購入完了のノーティフィケーション
#define kPaymentCompletedNotification  @"PaymentCompletedNotification"

// 購入失敗のノーティフィケーション
#define kPaymentErrorNotification @"PaymentErrorNotification"

@interface MyPaymentTransactionObserver : NSObject <SKPaymentTransactionObserver>
+ (id)sharedObserver;
@end

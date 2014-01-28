//
//  MyPaymentTransactionObserver.m
//  Off Search
//
//  Created by Shinya Hirai on 2013/12/10.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import "MyPaymentTransactionObserver.h"

@implementation MyPaymentTransactionObserver

static MyPaymentTransactionObserver* _sharedObserver = nil;

// 複数のクラスから同一のインスタンスを扱うことをできるようにするためシングルトンにする
+ (id)sharedObserver {
	@synchronized(self) {
		if (_sharedObserver == nil) {
			_sharedObserver = [[self alloc] init];
		}
	}
	return _sharedObserver;
}

#pragma mark - SKPaymentTransactionObserver Required Methods
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"transactionの中身 = %@",transactions);
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
                
            case SKPaymentTransactionStatePurchased:
                // 購入完了時の処理を行う
                [self completeTransaction:transaction];
                NSLog(@"SKPaymentTransactionStatePurchased");
                break;
                
            case SKPaymentTransactionStateFailed:
                // 購入失敗時の処理を行う
                [self failedTransaction:transaction];
                NSLog(@"SKPaymentTransactionStateFailed");
                break;
                
            case SKPaymentTransactionStateRestored:
                // TODO: リストア時の処理を行う
                // [self completeTransaction:transaction];
                NSLog(@"SKPaymentTransactionStateRestored");
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - SKPaymentTransactionObserver Optional Methods

// トランザクションがfinishTransaction経由でキューから削除されたときに送信されます。
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// ユーザーの購入履歴からキューに戻されたトランザクションを追加中にエラーが発生したときに送信されます。
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // TODO: リストアが失敗した時にここを通る
}

// ユーザの購入履歴から全てのトランザクションが正常に戻され、キューに追加された時に送信されます。
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Transaction Methods
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // 購入が完了したことを通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentCompletedNotification
                                                        object:transaction];
    NSLog(@"トランザクションの中身 = %@",transaction);
    // ペイメントキューに終了を伝えてトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    switch (transaction.error.code) {
        case SKErrorPaymentCancelled:
            NSLog(@"SKErrorPaymentCancelled");
            break;
            
        case SKErrorUnknown:
            NSLog(@"SKErrorUnknown");
            break;
            
        case SKErrorClientInvalid:
            NSLog(@"SKErrorClientInvalid");
            break;
            
        case SKErrorPaymentInvalid:
            NSLog(@"SKErrorPaymentInvalid");
            break;
            
        case SKErrorPaymentNotAllowed:
            NSLog(@"SKErrorPaymentNotAllowed");
            break;
            
        default:
            break;
    }
    
    // エラーを通知する
    [[NSNotificationCenter defaultCenter] postNotificationName:kPaymentErrorNotification
                                                        object:transaction];
    
    
    // ペイメントキューに終了を伝えてトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end

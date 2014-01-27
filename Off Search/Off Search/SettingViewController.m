//
//  SettingViewController.m
//  No connection Dictionary
//
//  Created by Shinya Hirai on 2013/11/24.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import "SettingViewController.h"
#import "MyPaymentTransactionObserver.h"

// Reachabilityを使ったネット接続確認マクロ
#define isOffline \
([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable ? YES : NO )

@interface SettingViewController () {
    // Purchases
    UIView *_viewGround;
    UIView *_baseView;
    UIButton* _cancelButton;
    UIButton* _buyButton;
    UIButton* _restoreButton;
    UITextView* _textView;
    
    // ローディング画面用変数
    UIView *_loadingViewGround;
    UIView *_loadingView;
    UIActivityIndicatorView *_indicatorView;
    UILabel *_processinglabel;
    
    NSTimer *_indicatorCompletedTimer;
    NSTimer *_viewCompletedTimer;
}

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}   

-(void)pushbackButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - roading view
-(void) indicatorStart {
    // スタートメソッド
    // 元となるViewをつくる
    _loadingViewGround = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [self.view addSubview:_loadingViewGround];
    
    // 丸みを帯びた土台となるViewをつくる
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(60,100,200,110)];
    [_loadingView setBackgroundColor:[UIColor lightGrayColor]];
    _loadingView.layer.cornerRadius = 10;
    _loadingView.clipsToBounds = YES;
    [_loadingView setAlpha:0.0];
    [_loadingViewGround addSubview:_loadingView];
    
    // indicator(処理中を知らせるためのクルクル回るあれ)をつくる
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_indicatorView setFrame:CGRectMake (79, 15, 40, 40)];
    [_indicatorView setAlpha:0.0];
    [_loadingView addSubview:_indicatorView];
    
    // 処理中のコメント表示用ラベルをつくる
    _processinglabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 200,90)];
    _processinglabel.text = @"処理中...";
    _processinglabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:18.0f];
    _processinglabel.textAlignment = 1;
    _processinglabel.backgroundColor = [UIColor clearColor];
    _processinglabel.textColor = [UIColor whiteColor];
    [_processinglabel setAlpha:0.0];
    [_loadingView addSubview:_processinglabel];
    
    [_indicatorView startAnimating];
    
    // 0.5秒かけてフワッとローディング画面がでるようにするアニメーション
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
    [_loadingView setAlpha:0.4];
    [_indicatorView setAlpha:1.0];
    [_processinglabel setAlpha:1.0];
	[UIView commitAnimations];
}

// こっちは隠すだけ
-(void) indicatorHide {
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
    [_loadingView setAlpha:0.0];
    [_indicatorView setAlpha:.0];
    [_processinglabel setAlpha:0.0];
    [_indicatorView stopAnimating];
    [UIView commitAnimations];
    
    [self indicatorSetTimeInterval];
}

// ストップメソッド
-(void) indicatorStop {
    // タイマー起動
    [_indicatorCompletedTimer invalidate];

    [_indicatorView stopAnimating];
    [_loadingViewGround removeFromSuperview];
    [_loadingView removeFromSuperview];
}

// indicatorRemove用のタイマー
- (void)indicatorSetTimeInterval {
    //2秒後にセレクタメソッドを実行する
    _indicatorCompletedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                       target:self
                                                     selector:@selector(indicatorStop)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    /* NavigationBar */
    UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    // NavigationItemを生成
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:@"アプリ情報"];
    // 設定ボタン生成
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(pushbackButton)];
    // NavigationBarの表示
    navTitle.rightBarButtonItem = btn1;
    [navBar pushNavigationItem:navTitle animated:YES];
    
    [self.view addSubview:navBar];
    
    // ステータスバーの文字色をViewごとに切り替える
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        //viewControllerで制御することを伝える。iOS7 からできたメソッド
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    // 購入処理が完了した時の通知を受け取るように登録
    [notificationCenter addObserver:self
                           selector:@selector(paymentCompletedNotification:)
                               name:kPaymentCompletedNotification
                             object:nil];
    
    // 購入処理が失敗した時の通知を受け取るように登録
    [notificationCenter addObserver:self
                           selector:@selector(paymentErrorNotification:)
                               name:kPaymentErrorNotification
                             object:nil];
    
#if ENABLE_SANDBOX
    NSLog(@"Debug log");
#else
    NSLog(@"Release log");
#endif
    
//    Reachability *reachablity = [Reachability reachabilityForInternetConnection];
//    NetworkStatus status = [reachablity currentReachabilityStatus];
//    switch (status) {
//        case NotReachable:
//            NSLog(@"インターネット接続出来ません");
//            break;
//        case ReachableViaWWAN:
//            NSLog(@"3G接続中");
//            break;
//        case ReachableViaWiFi:
//            NSLog(@"WiFi接続中");
//            break;
//        default:
//            NSLog(@"？？[%d]", status);
//            break;
//    }
    
}

#pragma mark - status bar
- (BOOL)prefersStatusBarHidden {
    //YESでステータスバーを非表示（NOなら表示）
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    //文字を白くする
    return UIStatusBarStyleLightContent;
}

#pragma mark - Cell function

- (void)postSocial {
    // UIActivityViewControllerはソーシャル等に共有する機能を持ったViewを下からmodalでだしてくれる
    // 今回はSettingの中の共有ボタンで使用
    NSString *text = @"ネット通信不要!すぐに検索できる辞書アプリ【Off Search】";
    NSURL* url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/off-search/id768224020?ls=1&mt=8"];
    NSArray* actItems = [NSArray arrayWithObjects: text, url, nil];
    NSLog(@"actItems = %@",actItems);
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
    [self presentViewController:activityView animated:YES completion:nil];
}

- (void)deleteHistory {
    // 履歴一括削除ボタンを押した時の処理
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"履歴一括削除"
                                                        message:@"検索履歴を全部削除します"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // AppDelegateからManagedObjectContextを召喚
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSFetchRequest * allHistoryRequest = [[NSFetchRequest alloc] init];
        [allHistoryRequest setEntity:[NSEntityDescription entityForName:@"History" inManagedObjectContext:context]];
        [allHistoryRequest setIncludesPropertyValues:NO];
        
        NSError * error = nil;
        NSArray * history = [context executeFetchRequest:allHistoryRequest error:&error];
        
        //error handling goes here
        for (NSManagedObject * his in history) {
            [context deleteObject:his];
        }
        NSError *saveError = nil;
        [context save:&saveError];
        //more error handling here
        NSLog(@"OKが押された時にこの処理がされているか確認");
    }
}

#pragma mark -
#pragma mark tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return @"入力履歴";
    } else {
        return @"Off Searchについて";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 2:
            return 2;
            break;
        default:
            return 1;
            break;
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSUserDefaults *purchaseBool = [NSUserDefaults standardUserDefaults];
        if ([purchaseBool boolForKey:@"DEFAULT_KEY_BOOL"] == YES) {
            NSLog(@"購入処理済のため広告削除選択不可");
            return nil;
        }
    }
    
    return indexPath;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cellの生成と初期化
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"広告の削除";
        NSUserDefaults *purchaseBool = [NSUserDefaults standardUserDefaults];
        if ([purchaseBool boolForKey:@"DEFAULT_KEY_BOOL"] == YES) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"既に購入済みです";
            cell.textLabel.textColor = [UIColor colorWithRed:0.192157 green:0.760784 blue:0.952941 alpha:1.00];
        } else {
            cell.textLabel.textColor = [UIColor colorWithRed:0.647059 green:0.647059 blue:0.647059 alpha:1.00];
        }
    } else if (indexPath.section == 2 && indexPath.row == 0){
        cell.textLabel.text = @"バージョン";
        
        cell.accessoryType = UITableViewCellAccessoryNone;

        // バージョン表示用ラベル
        UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(260,12, 100, 20)];
        // アプリバージョン情報
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        rightLabel.text = version;
        rightLabel.textColor = [UIColor colorWithRed:0.647059 green:0.647059 blue:0.647059 alpha:1.00];
        [cell addSubview:rightLabel];
        cell.textLabel.textColor = [UIColor colorWithRed:0.647059 green:0.647059 blue:0.647059 alpha:1.00];

    } else if (indexPath.section == 2 && indexPath.row == 1) {
        cell.textLabel.text = @"友達にこのアプリを共有";
        cell.textLabel.textColor = [UIColor colorWithRed:0.647059 green:0.647059 blue:0.647059 alpha:1.00];
    } else {
        cell.textLabel.text = @"履歴の一括削除";
        cell.textLabel.textColor = [UIColor colorWithRed:0.647059 green:0.647059 blue:0.647059 alpha:1.00];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // 広告削除(有料)機能
        if (!isOffline) {
            NSLog(@"ネット環境");
            [self purchaseView];
        } else {
            NSLog(@"接続不可");
            NSString* message = @"ネットに接続された環境で\nもう一度お試しください。";
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"要ネット接続"
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [alert show];
        }
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        // バージョン確認機能
        NSLog(@"No func");
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        // Social共有機能
        [self postSocial];
    } else {
        // 履歴削除機能
        [self deleteHistory];
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - purchases view
- (void)purchaseView {
    // 元となるViewをつくる
    _viewGround = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [self.view addSubview:_viewGround];
    
    // 丸みを帯びた土台となるViewをつくる
    _baseView = [[UIView alloc] initWithFrame:CGRectMake(10,20,300,538)];
    [_baseView setBackgroundColor:[UIColor whiteColor]];
    _baseView.layer.cornerRadius = 4;
    _baseView.clipsToBounds = YES;
    [_baseView setAlpha:0.0];
    [_viewGround addSubview:_baseView];
    
    // ボタンとテキストビューをつける
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 450, 140, 20)];
    [_cancelButton setAlpha:0.0];
    [_cancelButton setTitle:@"今はやめとく" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(purchaseHide) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:_cancelButton];
    
    _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 450, 60, 20)];
    [_buyButton setAlpha:0.0];
    [_buyButton setTitle:@"購入" forState:UIControlStateNormal];
    [_buyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buyButton addTarget:self action:@selector(handleBuyButton) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:_buyButton];
    
    _restoreButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 480, 120, 20)];
    [_restoreButton setAlpha:0.0];
    [_restoreButton setTitle:@"リストア" forState:UIControlStateNormal];
    [_restoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_restoreButton addTarget:self action:@selector(handleRestoreButton) forControlEvents:UIControlEventTouchUpInside];
    [_baseView addSubview:_restoreButton];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 100, 240, 250)];
    [_textView setAlpha:0.0];
    [_baseView addSubview:_textView];

    // 0.5秒かけてフワッとローディング画面がでるようにするアニメーション
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
    [_baseView setAlpha:0.9];
    [_cancelButton setAlpha:1.0];
    [_buyButton setAlpha:1.0];
    [_restoreButton setAlpha:1.0];
    [_textView setAlpha:1.0];
	[UIView commitAnimations];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self startProductRequest];
}

// viewを隠すだけ
-(void)purchaseHide {
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
    [_baseView setAlpha:0.0];
    [_buyButton setAlpha:0.0];
    [_cancelButton setAlpha:0.0];
    [_textView setAlpha:0.0];
	[UIView commitAnimations];
    
    [self viewSetTimeInterval];
}

// viewをremove
-(void)purchaseRemove {
    [_viewCompletedTimer invalidate];
    [_viewGround removeFromSuperview];
    [_baseView removeFromSuperview];
    [_buyButton removeFromSuperview];
    [_cancelButton removeFromSuperview];
    [_textView removeFromSuperview];
}

// view用のタイマー
- (void)viewSetTimeInterval {
    //2秒後にセレクタメソッドを実行する
    _viewCompletedTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                       target:self
                                                     selector:@selector(purchaseRemove)
                                                     userInfo:nil
                                                      repeats:NO];
}

#pragma mark - purchase
// プロダクトの情報取得開始メソッド
- (void)startProductRequest {
    // iTunes Connectで登録したプロダクトのIDに書き換えて下さい
    NSSet *productIds = [NSSet setWithObjects:@"com.shinya.hirai.1880mm.Off_Search.Remove_banner", nil];
    
    SKProductsRequest *productRequest;
    productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    productRequest.delegate = self;
    [productRequest start];
    [self indicatorStart];
}

// 購入処理の開始前に、端末の設定がコンテンツを購入することができるようになっているか確認する
- (void)buy {
    if ([SKPaymentQueue canMakePayments] == NO) {
        NSString *message = @"機能制限でApp内での購入が不可になっています。";
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"エラー"
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // TODO: 上記if文が通ってしまった場合の分岐が必要？
    // 購入処理を開始する
    SKPayment *payment = [SKPayment paymentWithProduct:[_products objectAtIndex:0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (NSString *invalidProductIdentifier in response.invalidProductIdentifiers) {
        // invalidProductIdentifiersがあればログに出力する
        NSLog(@"%s invalidProductIdentifiers : %@", __PRETTY_FUNCTION__, invalidProductIdentifier);
    }
    
    // プロダクト情報を後から参照できるようにメンバ変数に保存しておく
    self.products = response.products;
    NSLog(@"self.products = %@",self.products);
    
    // 取得したプロダクト情報を順番にUItextVIewに表示する（今回は1つだけ）
    for (SKProduct *product in response.products) {
        NSString *text = [NSString stringWithFormat:@"Title\n%@\n\nDescription\n%@\n\nPrice : %@\n\n",
                          product.localizedTitle,
                          product.localizedDescription,
                          product.price];
        _textView.text = text;
    }
    NSLog(@"_textView.text = %@",_textView.text);
    
    [self indicatorHide];
    
    // 購入ボタンを有効にする
    _buyButton.enabled = YES;
}

#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *message = [NSString stringWithFormat:@"エラーコード %d\n一定時間経過後に\nもう一度お試しください。", error.code];
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"購入処理失敗"
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
    [alert show];
    
    [self indicatorHide];
}

- (void)paymentCompletedNotification:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // 実際はここで機能を有効にしたり、コンテンツを表示したいする
    SKPaymentTransaction *transaction = [notification object];
    NSString *message = [NSString stringWithFormat:@"%@ の購入が完了致しました。", transaction.payment.productIdentifier];
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"購入処理完了"
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
    [alert show];
    
    [self indicatorHide];
    
    // 購入処理保存用
    NSUserDefaults *purchaseBool = [NSUserDefaults standardUserDefaults];
    // 初期値はNO = 0です
    [purchaseBool setBool:YES forKey:@"DEFAULT_KEY_BOOL"];
    NSLog(@"purchaseBool = %hhd",[purchaseBool boolForKey:@"DEFAULT_KEY_BOOL"]);
    
    [self purchaseHide];
    
}

- (void)paymentErrorNotification:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // ここでエラーを表示する
    SKPaymentTransaction *transaction = [notification object];
    NSString *message = [NSString stringWithFormat:@"エラーコード %d\n一定時間経過後に\nもう一度お試しください。", transaction.error.code];
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"購入処理失敗"
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
    [alert show];
    
    [self indicatorHide];
}

#pragma mark - handle method
- (void)handleBuyButton {
    [self indicatorStart];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self buy];
}

- (void)handleRestoreButton {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [self indicatorStart];
    // 処理を開始させる
    [self startRestore];
}

- (void)startRestore {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    // リストア処理を開始させる
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end

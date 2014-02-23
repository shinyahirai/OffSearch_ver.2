//
//  SettingViewController.m
//  No connection Dictionary
//
//  Created by Shinya Hirai on 2013/11/24.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import "SettingViewController.h"


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
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // 例えば
    transition.type = kCATransitionReveal;
    // 例えば
    transition.subtype = kCATransitionFromTop;
    
    // Modal のアニメーションを変更する
    [self.view.layer addAnimation:transition forKey:nil];
    // ここ、なんでmodalViewControllerじゃないんですかね。。。

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
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:@"設定"];
    // 設定ボタン生成
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(pushbackButton)];
    // NavigationBarの表示
    navTitle.rightBarButtonItem = btn1;
    [navBar pushNavigationItem:navTitle animated:YES];
    
    [self.view addSubview:navBar];
    
//    // ステータスバーの文字色をViewごとに切り替える
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        //viewControllerで制御することを伝える。iOS7 からできたメソッド
//        [self setNeedsStatusBarAppearanceUpdate];
//    }
    
    
#if ENABLE_SANDBOX
    NSLog(@"Debug log");
#else
    NSLog(@"Release log");
#endif
        
}

#pragma mark - status bar
- (BOOL)prefersStatusBarHidden {
    //YESでステータスバーを非表示（NOなら表示）
    return NO;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    //文字を白くする
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - Cell function

- (void)postSocial {
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
    }
}

#pragma mark -
#pragma mark tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"入力履歴";
    } else {
        return @"Off Searchについて";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        default:
            return 2;
            break;
    }
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
        cell.textLabel.text = @"履歴の一括削除";
    } else if (indexPath.section == 1 && indexPath.row == 0){
        cell.textLabel.text = @"バージョン";
        
        cell.accessoryType = UITableViewCellAccessoryNone;

        // バージョン表示用ラベル
        UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(260,12, 100, 20)];
        // アプリバージョン情報
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        rightLabel.text = version;
        rightLabel.textColor = [UIColor colorWithRed:0.647059 green:0.647059 blue:0.647059 alpha:1.00];
        [cell addSubview:rightLabel];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = @"このアプリを共有";
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:0.647059 green:0.647059 blue:0.647059 alpha:1.00];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // 履歴削除機能
        [self deleteHistory];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // バージョン確認機能
        NSLog(@"No func");
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        // Social共有機能
        [self postSocial];
    } else {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

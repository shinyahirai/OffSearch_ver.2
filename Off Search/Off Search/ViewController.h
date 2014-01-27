//
//  ViewController.h
//  No connection Dictionary
//
//  Created by Shinya Hirai on 2013/11/22.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>  // UIViewの角を丸めるためのフレームワーク。今回はローディング画面で使用
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "History.h"
#import "AppDelegate.h"
#import "SettingViewController.h"

@interface ViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,ADBannerViewDelegate,GADBannerViewDelegate> {
    // Core Data 用
    NSMutableArray* _objectChanges;
    NSMutableArray* _sectionChanges;
@private
    GADBannerView* adMobView;
    BOOL adMobIsVisible;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


// Core Data 用
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

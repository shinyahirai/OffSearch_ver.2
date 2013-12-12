//
//  SettingViewController.h
//  No connection Dictionary
//
//  Created by Shinya Hirai on 2013/11/24.
//  Copyright (c) 2013年 Shinya Hirai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import <StoreKit/StoreKit.h>

@interface SettingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// 課金用
@property (strong, nonatomic) NSArray *products;

@end

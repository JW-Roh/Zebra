//
//  ZBHomeTableViewController.h
//  Zebra
//
//  Created by midnightchips on 7/1/19.
//  Copyright © 2019 Wilson Styres. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+GlobalColors.h"
#import "ZBDevice.h"
#import "ZBStoresListTableViewController.h"
#import "ZBSettingsTableViewController.h"
#import "ZBWishListTableViewController.h"
#import "ZBWebViewController.h"
#import "ZBDatabaseManager.h"
#import "ZBRepo.h"
#import "ZBNoScrollHeaderTableView.h"
#import "ZBFeaturedCollectionViewCell.h"
#import "UIImage+UIKitImage.h"
@import SDWebImage;

@interface ZBHomeTableViewController : UITableViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *darkModeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (weak, nonatomic) IBOutlet UILabel *udidLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *featuredCollection;
@property NSMutableArray *allFeatured;
@property NSMutableArray *selectedFeatured;
@property NSInteger cellNumber;
@property NSUserDefaults *defaults;
@end

//
//  ViewController.h
//  AcronymFinder
//
//  Created by Deepak on 4/7/17.
//  Copyright © 2017 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import  "QuartzCore/QuartzCore.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(readwrite,assign) BOOL isNetworkReachable;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIButton *fetchDefinitionsButton;
@property (weak, nonatomic) IBOutlet UITableView *definitionsTableView;
@property(strong,nonatomic) NSMutableArray *tableViewDataSourceArray;

-(IBAction)fetchDefinitionsFromAPI:(id)sender;

@end


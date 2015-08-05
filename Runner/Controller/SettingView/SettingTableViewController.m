//
//  SettingTableViewController.m
//  Runner
//
//  Created by delphiwu on 15/8/4.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import "SettingTableViewController.h"

@interface SettingTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *sexSegControl;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
- (IBAction)sexSelect:(id)sender;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //设置身高体重显示值
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"weight"] == nil)
    {
        self.weightLabel.text = @"00 kg";
    } else
    {
        self.weightLabel.text = [NSString stringWithFormat:@"%.1f kg",[defaults floatForKey:@"weight"]];
    }
    
    if ([defaults objectForKey:@"height"] == nil)
    {
        self.heightLabel.text = @"00 cm";
    } else
    {
        self.heightLabel.text = [NSString stringWithFormat:@"%.1f cm",[defaults floatForKey:@"height"]];
    }
    
    if ([defaults objectForKey:@"sexuality"] == nil)
    {
        self.sexSegControl.selectedSegmentIndex = 0;
    } else
    {
        self.sexSegControl.selectedSegmentIndex = [defaults integerForKey:@"sexuality"];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   //隐藏tabbar
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}
- (IBAction)sexSelect:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.sexSegControl.selectedSegmentIndex forKey:@"sexuality"];
    [defaults synchronize];
}

@end

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
   
    [self setNavigationItem];
}

- (void)setNavigationItem
{
    //bar颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:100.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1.0f]];
    [self.navigationController.navigationBar setTranslucent:NO];
    //返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    //title字体
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:19.0]forKey:NSFontAttributeName];
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

- (IBAction)sexSelect:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.sexSegControl.selectedSegmentIndex forKey:@"sexuality"];
    [defaults synchronize];
}

#pragma mark - navigationcontroller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   //隐藏tabbar
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row == 0))
    {
        NSURL *appStoreURL = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/runner/id1028192410?mt=8"];
        [[UIApplication sharedApplication] openURL:appStoreURL];
    }
}
@end

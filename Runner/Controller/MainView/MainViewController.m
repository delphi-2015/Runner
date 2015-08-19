#import "MainViewController.h"
#import "AppDelegate.h"
#import "RunningViewController.h"
#import "Run.h"
#import "MathData.h"

@interface MainViewController ()

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSArray *runArray;

@property (weak, nonatomic) IBOutlet UILabel *totalDistance;
@property (weak, nonatomic) IBOutlet UILabel *totalRuns;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeed;
@property (weak, nonatomic) IBOutlet UILabel *avgCalorie;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //从coredata获取跑步数据
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]]  ;
    
    self.runArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    [self setLabelData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
}

- (void)setLabelData
{
    int seconds = 0;
    float distance = 0;
    float calorie = 0;
    NSInteger con = self.runArray.count;
    for (Run *run in self.runArray)
    {
        calorie +=[MathData valueifDistance:run.distance.floatValue Time:run.duration.intValue];
        seconds += run.duration.intValue;
        distance += run.distance.floatValue;
    }
    
    self.totalDistance.text = [NSString stringWithFormat:@"%.1f",distance/1000];
    self.totalRuns.text = [[NSString stringWithFormat:@"%ld",(long)con] stringByAppendingString:@"次"];
    self.avgSpeed.text = [MathData stringifyAvgPaceFromDist:distance overTime:seconds ifleft:NO];
    self.avgCalorie.text = [[NSString stringWithFormat:@"%.1f",(con == 0?0:calorie/con)] stringByAppendingString:@"kcal"];
}

#pragma mark - navigationcontroller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RunningViewController *controller=segue.destinationViewController;
    controller.managedObjectContext=self.managedObjectContext;
    
    //隐藏tabbar
    [controller setHidesBottomBarWhenPushed:YES];
}
@end

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
//获取跑步数据
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]]  ;
    
    self.runArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    [self setLabelData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RunningViewController *controller=segue.destinationViewController;
    controller.managedObjectContext=self.managedObjectContext;
    [controller setHidesBottomBarWhenPushed:YES];
}

- (void)setLabelData
{
    int seconds = 0;
    float distance = 0;
    NSInteger con = self.runArray.count;
    for (Run *run in self.runArray)
    {
        seconds += run.duration.intValue;
        distance += run.distance.floatValue;
    }
    
    self.totalDistance.text = [MathData stringifyDistance:distance];
    self.totalRuns.text = [NSString stringWithFormat:@"%ld",(long)con];
    self.avgSpeed.text = [MathData stringifyAvgPaceFromDist:distance overTime:seconds ifleft:NO];
}
@end

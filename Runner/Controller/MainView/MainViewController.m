#import "MainViewController.h"
#import "AppDelegate.h"
#import "RunningViewController.h"

@interface MainViewController ()

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSArray *runArray;

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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RunningViewController *controller=segue.destinationViewController;
    controller.managedObjectContext=self.managedObjectContext;
    [controller setHidesBottomBarWhenPushed:YES];
}
@end

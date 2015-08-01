#import "ActivityViewController.h"
#import "AppDelegate.h"
#import "MathData.h"
#import "ActivityCell.h"
#import "Run.h"
#import "DetailViewController.h"
#import "ScrollViewController.h"

@interface ActivityViewController ()

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSArray *runArray;

@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    ScrollViewController *parent = (ScrollViewController *)self.navigationController.parentViewController;
    parent.pageControl.hidden = NO;
    parent.scrollView.scrollEnabled = YES;
    
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
}

- (void)loadData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]]  ;
    
    self.runArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.runArray.count;
}


- (ActivityCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityCell" forIndexPath:indexPath];
    
    Run *run = [self.runArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    cell.dateLabel.text = [formatter stringFromDate:run.timestamp];
    cell.distanceLabel.text = [MathData stringifyDistance:run.distance.floatValue];
    cell.timeLabel.text = [MathData stringifySecondCount:run.duration.intValue usingLongFormat:NO];
    cell.paceLabel.text = [MathData stringifyAvgPaceFromDist:run.distance.floatValue overTime:run.duration.intValue ifleft:NO];
     
    
    return cell;
}

#pragma mark - ActivityCell Edit
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除数据
        [self removeassignCoreData:indexPath];
        [self loadData];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)removeassignCoreData:(NSIndexPath *)indexPath
{
    Run *run = [self.runArray objectAtIndex:indexPath.row];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Run"];
   
    request.predicate = [NSPredicate predicateWithFormat:@"timestamp = %@", run.timestamp];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    for (Run *run in result) {
        [self.managedObjectContext deleteObject:run];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DetailViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Run *run = [self.runArray objectAtIndex:indexPath.row];
        [(DetailViewController *)[segue destinationViewController] setRun:run];
    }
}


@end
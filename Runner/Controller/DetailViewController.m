#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "JBLineChartFooterView.h"
#import "JBLineChartView.h"
#import "JBChartInformationView.h"
#import "MathData.h"
#import "Location.h"



@interface DetailViewController ()<MKMapViewDelegate,JBLineChartViewDelegate,JBLineChartViewDataSource>

@property (weak, nonatomic) IBOutlet JBChartInformationView *JBChartInfoView;
@property (weak, nonatomic) IBOutlet JBLineChartView *JBLineChartView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloireLabel;
@property (strong,nonatomic) NSArray *speedArray;
@property (strong,nonatomic) NSArray *disArray;

@end

@implementation DetailViewController

- (void)setRun:(Run *)run
{
    if (_run != run) {
        _run=run;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar-iPhone.png" ]forBarMetrics:UIBarMetricsCompact];
    [self getBackView:self.navigationController.navigationBar];
    
    [self makeSpeedArray:self.run.locations.array];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
    [self.JBLineChartView reloadData];
    [self.JBLineChartView setState:JBChartViewStateCollapsed];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.JBLineChartView setState:JBChartViewStateExpanded animated:YES];
}

//相当烂！！
- (void)getBackView :(UIView *)view
{
    for (UIView *sview in view.subviews)
    {
        if ([sview isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")])
        {
            for (UIView *view in sview.subviews)
            {
                if ([view isKindOfClass:[UIImageView class]])
                {
                    [view removeFromSuperview];
                }
            }
        }
    }
}

- (void)configureView
{
    //configure JBLineChartView
    self.JBLineChartView.delegate = self;
    self.JBLineChartView.dataSource = self;
    
    //configure JBLineChartFooterView
    JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - (20.0 * 2), 30.0)];
    footerView.leftLabel.text = [NSString stringWithFormat:@"%d", 0];
    footerView.leftLabel.textColor = [UIColor blackColor];
    footerView.rightLabel.text = [NSString stringWithFormat:@"%@",[MathData stringifyDistance:(self.run.distance.floatValue)]];
    footerView.rightLabel.textColor = [UIColor blackColor];
    footerView.sectionCount = 25;
    footerView.footerSeparatorColor = [UIColor blackColor];
    self.JBLineChartView.footerView = footerView;
    
    //configure JBChartInfoView
    [self.JBChartInfoView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
    [self.JBChartInfoView setTitleTextColor:[UIColor blackColor]];
    [self.JBChartInfoView setValueAndUnitTextColor:[UIColor colorWithRed:0.0/255.0 green:171.0/255.0 blue:243.0/255.0 alpha:1.0]];
    [self.JBChartInfoView setTextShadowColor:nil];
    [self.JBChartInfoView setSeparatorColor:[UIColor blackColor]];
}

-(void)makeSpeedArray:(NSArray *)locations
{
    NSMutableArray *rawSpeeds = [NSMutableArray array];
    NSMutableArray *rawDistance = [NSMutableArray array];
    double Addistance = 0;
    double Addtime = 0;
    double tempdistance = 0;
    double temptime = 0;
    int y = 1;
    
    for (int i = 1; i < locations.count; i++) {
        Location *firstLoc = [locations objectAtIndex:(i-1)];
        Location *secondLoc = [locations objectAtIndex:i];
        
        CLLocation *firstLocCL = [[CLLocation alloc] initWithLatitude:firstLoc.latitude.doubleValue longitude:firstLoc.longitude.doubleValue];
        CLLocation *secondLocCL = [[CLLocation alloc] initWithLatitude:secondLoc.latitude.doubleValue longitude:secondLoc.longitude.doubleValue];
        
        double distance = [secondLocCL distanceFromLocation:firstLocCL];
        double time = [secondLoc.timestamp timeIntervalSinceDate:firstLoc.timestamp];
      //  double speed = distance/time;
        Addistance += distance;
        Addtime += time;
        
        if (Addistance>100*y )
        {
            double speed = (Addistance-tempdistance)/(Addtime-temptime);
            [rawDistance addObject:[NSNumber numberWithDouble:Addistance]];
            [rawSpeeds addObject:[NSNumber numberWithDouble:speed]];
            tempdistance = Addistance;
            temptime = Addtime;
            y++;
        }
    }
    self.speedArray = rawSpeeds;
    self.disArray = rawDistance;
}

#pragma mark - JBLineChartViewDelegate

- (void)lineChartView:(JBLineChartView *)lineChartView
didSelectChartAtIndex:(NSInteger)index
{
    if ([self.speedArray count] <= index) {
        return;
    }

    NSNumber *speedValue = [self.speedArray objectAtIndex:index];
    NSString *valueText = [[NSString alloc] init];
    if ([speedValue doubleValue] > 10.0) {
        valueText = [NSString stringWithFormat:@"%.1f", speedValue.doubleValue*3.6];
    }
    else {
        valueText = [NSString stringWithFormat:@"%.2f", speedValue.doubleValue*3.6];
    }
    [self.JBChartInfoView setValueText:valueText unitText:[@" " stringByAppendingString:@"km/h"]];
    
    double distanceValue = [[self.disArray objectAtIndex:index] doubleValue]/1000.0;
    NSString *titleText = [[NSString alloc] init];
    if (distanceValue > 10.0) {
        titleText = [NSString stringWithFormat:@"%.1f", distanceValue];
    }
    else {
        titleText = [NSString stringWithFormat:@"%.2f", distanceValue];
    }
    [self.JBChartInfoView setTitleText:titleText unitText:[@" " stringByAppendingString:@"km"]];
    
    [self.JBChartInfoView setHidden:NO animated:YES];
}

- (void)lineChartView:(JBLineChartView *)lineChartView
didUnselectChartAtIndex:(NSInteger)index
{
    [self.JBChartInfoView setHidden:NO animated:YES];
}

#pragma mark - JBLineChartViewDataSource

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView
          heightForIndex:(NSInteger)index
{
    if ([self.speedArray count] <= index) {
        return 0.0f;
    }
    
    return [[self.speedArray objectAtIndex:index] floatValue]*3.6;
}

- (NSInteger)numberOfPointsInLineChartView:(JBLineChartView *)lineChartView
{
    return [self.speedArray count];
}

- (UIColor *)lineColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor colorWithRed:0.0/255.0 green:171.0/255.0 blue:243.0/255.0 alpha:1.0];
}

- (UIColor *)selectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor colorWithRed:0.0/255.0 green:171.0/255.0 blue:243.0/255.0 alpha:1.0];
}

@end

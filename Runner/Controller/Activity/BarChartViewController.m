#import "BarChartViewController.h"
#import "Run.h"
#import "AppDelegate.h"

@import Charts;

@interface BarChartViewController ()

@property (weak, nonatomic) IBOutlet BarChartView *chartView;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSArray *runArray;
@property (strong,nonatomic) NSArray *monthArray;

@end

@implementation BarChartViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    months = @[
               @"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep",
               @"Oct", @"Nov", @"Dec"
               ];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    self.title = @"Bar Chart";
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"";
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.maxVisibleValueCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 2.0;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 8;
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    leftAxis.valueFormatter.maximumFractionDigits = 1;
    leftAxis.valueFormatter.negativeSuffix = @" km";
    leftAxis.valueFormatter.positiveSuffix = @" km";
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.15;
    
    _chartView.legend.position = ChartLegendPositionBelowChartLeft;
    _chartView.legend.form = ChartLegendFormSquare;
    _chartView.legend.formSize = 9.0;
    _chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _chartView.legend.xEntrySpace = 4.0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    [self setMonthDataArray];

    [self setDataCount:(int)self.monthArray.count range:[self getMaxdistance:self.monthArray]];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_chartView animateWithXAxisDuration:1.0 yAxisDuration:1.0];
  
}

#pragma mark - initialize Data

- (void)loadData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    //这次得降序提取数据了
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]]  ;
    
    self.runArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (void)setMonthDataArray
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    double permonthData = 0;
    NSInteger i = 0;
    NSInteger  firstMonth = [self month:((Run *)self.runArray.firstObject).timestamp];
    
    //将历史数据按照时间戳，每月累计里程，重新放到一个数组
    for (Run *run in self.runArray)
    {
        NSInteger tempMonth = [self month:run.timestamp];

        if (tempMonth == (firstMonth+i))
        {
            permonthData += [run.distance doubleValue];
        }else
        {
            NSInteger y = tempMonth-firstMonth-i;
            if (y > 1)
            {
                for (NSInteger h = 1 ; h < y; h++)
                {
                    permonthData = 0;
                    [tempArray addObject:[NSNumber numberWithDouble:permonthData]];
                }
            }else
            {
                [tempArray addObject:[NSNumber numberWithDouble:permonthData]];
                permonthData = 0;
                permonthData += [run.distance doubleValue];
            }
          
            if ((firstMonth+i) == 12)
            {
                i = 1-firstMonth;
            }else
            {
                i += y;
            }
        }
        
        if (run == (Run *)[self.runArray lastObject])
        {
            [tempArray addObject:[NSNumber numberWithDouble:permonthData]];
        }
    }
    
    self.monthArray = tempArray;
}

- (double)getMaxdistance:(NSArray *)array
{
    //取得历史单月最长里程，以便设定y坐标最大值
    double maxDistance = 0;
    for (NSNumber *temp in array)
    {
        maxDistance = maxDistance>[temp doubleValue] ? maxDistance:[temp doubleValue];
    }
    return ((int)maxDistance/1000)+2.0;
}

- (NSInteger)month:(NSDate *)date
{
    //提取NSDate的月份参数；
    NSDateComponents *dateComponent = [[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]components:NSCalendarUnitMonth fromDate:date];
    
    return dateComponent.month;
}

#pragma mark - make chartData

- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    int y = (int)[self month:((Run *)self.runArray.firstObject).timestamp]-1;
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:months[y % 12]];
        y ++;
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        double val = [[self.monthArray objectAtIndex:i] doubleValue]/1000.00;
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@"月跑步总量"];
    set1.barSpace = 0.35;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _chartView.data = data;
}

@end

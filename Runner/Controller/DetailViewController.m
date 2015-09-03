#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "JBLineChartFooterView.h"
#import "JBLineChartView.h"
#import "JBChartInformationView.h"
#import "MathData.h"
#import "Location.h"
#import "ColorPolyline.h"
#import "MapDetialView.h"
#import "DistanceAnnotation.h"
#import "ScrollViewController.h"


@interface DetailViewController ()<MKMapViewDelegate,JBLineChartViewDelegate,JBLineChartViewDataSource>

@property (weak, nonatomic) IBOutlet JBChartInformationView *JBChartInfoView;
@property (weak, nonatomic) IBOutlet JBLineChartView *JBLineChartView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *calLabel;
@property (strong,nonatomic) NSArray *speedArray;
@property (strong,nonatomic) NSArray *disArray;
@property (strong,nonatomic) NSArray *locArray;
@property (strong,nonatomic) MKPointAnnotation *point;

@end

@implementation DetailViewController

//- (void)setRun:(Run *)run
//{
//    if (_run != run) {
//        _run=run;
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationItem];
    [self makeSpeedArray:self.run.locations.array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
    [self.JBLineChartView reloadData];
    [self.JBLineChartView setState:JBChartViewStateCollapsed];
    
    //显示卡路里数据
    self.calLabel.text = [[NSString stringWithFormat:@"%.1f",[MathData valueifDistance:self.run.distance.floatValue Time:self.run.duration.intValue]]stringByAppendingString:@"kcal"];
    
    //判断父控件种类决定返回按钮方式以及当前界面处理
    if ([self.navigationController.parentViewController isKindOfClass:[ScrollViewController class]])
    {
        ScrollViewController *parent = (ScrollViewController *)self.navigationController.parentViewController;
        parent.pageControl.hidden = YES;
        parent.scrollView.scrollEnabled = NO;
    }else
    {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(15, 30, 25, 30)];
        [button setBackgroundImage:[UIImage imageNamed:@"Arrow"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 64)];
        label.text = [formatter stringFromDate:self.run.timestamp];
        label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blueColor];
        [self.view addSubview:label];;
    }
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.JBLineChartView setState:JBChartViewStateExpanded animated:YES];
    [self loadMap];
}

- (void)setNavigationItem
{
    //设定navigation背景透明以及标题内容
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar-iPhone.png" ]forBarMetrics:UIBarMetricsCompact];
    [self getBackView:self.navigationController.navigationBar];
    //设置navigation的titleview
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 260, 50)];
    label.text = [formatter stringFromDate:self.run.timestamp];
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blueColor];
    self.navigationItem.titleView = label;
}

//刚跑完显示detial时通过添加back键返回rootview
- (void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//相当囧！！去掉一条杠
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
    JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width , 25.0)];
    footerView.leftLabel.text = [NSString stringWithFormat:@"%d", 0];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [NSString stringWithFormat:@"%@",[MathData stringifyDistance:(self.run.distance.floatValue)]];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    footerView.sectionCount = 25;
    footerView.footerSeparatorColor = [UIColor whiteColor];
    self.JBLineChartView.footerView = footerView;
    
    //configure JBChartInfoView
    [self.JBChartInfoView layout:JBChartInformationViewLayoutVertical];
    [self.JBChartInfoView setValueAndUnitTextColor:[UIColor blackColor]];
    [self.JBChartInfoView setTitleTextColor:[UIColor blackColor]];
    [self.JBChartInfoView setTextShadowColor:nil];
    [self.JBChartInfoView setSeparatorColor:[UIColor blackColor]];
}

//重新整理数据，按照50m位单元，设置速度，距离，位置数组
-(void)makeSpeedArray:(NSArray *)locations
{
    NSMutableArray *loc = [NSMutableArray array];
    NSMutableArray *rawSpeeds = [NSMutableArray array];
    NSMutableArray *rawDistance = [NSMutableArray array];
    double Addistance = 0;
    double Addtime = 0;
    double tempdistance = 0;
    double temptime = 0;
    int y = 1;
    
    [loc addObject:locations.firstObject];
    
    for (int i = 1; i < locations.count; i++)
    {
        Location *firstLoc = [locations objectAtIndex:(i-1)];
        Location *secondLoc = [locations objectAtIndex:i];
        
        CLLocation *firstLocCL = [[CLLocation alloc] initWithLatitude:firstLoc.latitude.doubleValue longitude:firstLoc.longitude.doubleValue];
        CLLocation *secondLocCL = [[CLLocation alloc] initWithLatitude:secondLoc.latitude.doubleValue longitude:secondLoc.longitude.doubleValue];
        
        double distance = [secondLocCL distanceFromLocation:firstLocCL];
        double time = [secondLoc.timestamp timeIntervalSinceDate:firstLoc.timestamp];
    
        Addistance += distance;
        Addtime += time;
        //以50m位单位判断是否存储一次
        if (Addistance >= 50*y )
        {
            double speed = (Addistance-tempdistance)/(Addtime-temptime);
            [rawDistance addObject:[NSNumber numberWithDouble:Addistance]];
            [rawSpeeds addObject:[NSNumber numberWithDouble:speed]];
            tempdistance = Addistance;
            temptime = Addtime;
            y++;
            [loc addObject:secondLoc];
        }
    }
    [loc addObject:locations.lastObject];
    [rawDistance addObject:[NSNumber numberWithDouble:Addistance]];
    [rawSpeeds addObject:[NSNumber numberWithDouble:(Addistance/Addtime)]];
    self.speedArray = rawSpeeds;
    self.disArray = rawDistance;
    self.locArray = loc;
}

-(void)loadMap
{
    if (self.run.locations.count>0)
    {
        self.mapView.hidden=NO;
        self.mapView.delegate=self;
        [self.mapView setRegion:[self mapRegion]];
        
        //添加画线和里程显示annotations
        NSArray *colorSegmentArray = [MapDetialView colorSegmentsForLocations:self.locArray speeds:self.speedArray];
        [self.mapView addOverlays:colorSegmentArray];
        [self.mapView addAnnotations:[MapDetialView annotationsForlocationArray:self.locArray distanceArray:self.disArray]];
    }else
    {
        self.mapView.hidden=YES;
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"error" message:@"Sorry,no locations saved!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles: nil];
        
        [alertView show];
    }
}

- (MKCoordinateRegion)mapRegion
{
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.15f; // 15% padding
    region.span.longitudeDelta = (maxLng - minLng) * 1.35f; // 13% padding
    
    return region;
}

#pragma mark - JBLineChartViewDelegate

- (void)lineChartView:(JBLineChartView *)lineChartView
didSelectChartAtIndex:(NSInteger)index
{
    if ([self.speedArray count] <= index) {
        return;
    }
    
    //添加速度数组
    NSNumber *speedValue = [self.speedArray objectAtIndex:index];
    NSString *titleText;
    if ([speedValue doubleValue]*3.6 > 10.0)
    {
        titleText = [NSString stringWithFormat:@"%.1f", speedValue.doubleValue*3.6];
    }else
    {
        titleText = [NSString stringWithFormat:@"%.2f", speedValue.doubleValue*3.6];
    }
    [self.JBChartInfoView setTitleText:titleText unitText:[@" " stringByAppendingString:@"km/h"]];
  
    //添加移动annotation
    [self.mapView removeAnnotation:self.point];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    Location *location = [self.locArray objectAtIndex:index+1];
    annotation.coordinate = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
    
    double distanceValue = [[self.disArray objectAtIndex:index] doubleValue]/1000.0;
    NSString *title;
    if (distanceValue > 10.0)
    {
       title = [NSString stringWithFormat:@"%.1f", distanceValue];
    }else
    {
       title = [NSString stringWithFormat:@"%.2f", distanceValue];
    }
    annotation.title = [title stringByAppendingString:@"km"];
    
    self.point = annotation;
    [self.mapView addAnnotation:self.point];
    //一直显示数组
    [self.mapView selectAnnotation:annotation animated:NO];

    [self.JBChartInfoView setHidden:NO animated:YES];
}

- (void)lineChartView:(JBLineChartView *)lineChartView
didUnselectChartAtIndex:(NSInteger)index
{
    [self.JBChartInfoView setHidden:YES animated:YES];
    [self.mapView removeAnnotation:self.point];
}

#pragma mark - JBLineChartViewDataSource

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView
          heightForIndex:(NSInteger)index
{
    if ([self.speedArray count] <= index) {
        return 0.0f;
    }
    
    return [[self.speedArray objectAtIndex:index] floatValue]*3600;
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


#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[ColorPolyline class]]) {
        ColorPolyline *polyLine = (ColorPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = polyLine.color;
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    if ([annotation isKindOfClass:[DistanceAnnotation class]])
    {
        DistanceAnnotation *distancePointAnnotation = annotation;
        MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"checkpoint"];
        if (!annView)
        {
            annView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"checkpoint"];
        }
        annView.image = distancePointAnnotation.image;
        return annView;
    }
    return nil;
}

@end

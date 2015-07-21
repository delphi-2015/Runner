//
//  RunningViewController.m
//  Runner
//
//  Created by delphiwu on 15/7/19.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import "RunningViewController.h"
#import "Run.h"
#import "Location.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MathData.h"
#import "WGS84TOGCJ02.h"

@interface RunningViewController ()<UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *disLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftpaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightpaceLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *locations;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) Run *run;
@property int seconds;
@property float distance;

@end

@implementation RunningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startRun];
}

- (void)setup
{
    //map
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 300, 300);
    [self.mapView setRegion:region animated:YES];

    
    //locationManager
    if (self.locationManager == nil)
        self.locationManager = [[CLLocationManager alloc] init];
   
    [self.locationManager requestAlwaysAuthorization]; //ios8授权机制
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = 3;
}

- (void)startRun
{
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                                  target:self
                                                selector:@selector(perSecond)
                                                userInfo:nil
                                                 repeats:YES];
    [self.locationManager startUpdatingLocation];
}

- (void)perSecond
{
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [MathData stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.disLabel.text = [NSString stringWithFormat:@"%@", [MathData stringifyDistance:self.distance]];
    self.leftpaceLabel.text = [NSString stringWithFormat:@"%@", [MathData stringifyAvgPaceFromDist:self.distance overTime:self.seconds ifleft:YES]];
    self.rightpaceLabel.text = [NSString stringWithFormat:@"%@", [MathData stringifyAvgPaceFromDist:self.distance overTime:self.seconds ifleft:NO]];
}

- (IBAction)stopBtnPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"取消 " destructiveButtonTitle:nil
                                                    otherButtonTitles:@"保存", @"删除", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 保存
    if (buttonIndex == 0) {
        [self saveData];
     [self performSegueWithIdentifier:@"DetailView" sender:nil];
        
    // 删除
    } else if (buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)saveData
{
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run"
                                                inManagedObjectContext:self.managedObjectContext];
    
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                 inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - CLLocationManager  &  mapView
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc=[locations lastObject];
    //判断是不是属于国内范围
    if (![WGS84TOGCJ02 isLocationOutOfChina:[loc coordinate]])
    {
        for (CLLocation *new in locations)
        {
            CLLocation *newLocation = [WGS84TOGCJ02 transformFromWGSToGCJ:new];
        
            NSDate *eventDate = newLocation.timestamp;
            NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
            if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20)
            {
                if (self.locations.count > 0)
                {
                    self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                    CLLocationCoordinate2D coords[2];
                    coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                    coords[1] = newLocation.coordinate;
           
                    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                }
                [self.locations addObject:newLocation];
            }
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.mapView.centerCoordinate = userLocation.coordinate;
}
@end


#import "MapDetialView.h"
#import <MapKit/MapKit.h>
#import "Location.h"
#import "DistanceAnnotation.h"
#import "ColorPolyline.h"

@implementation MapDetialView

+ (NSArray *)annotationsForlocationArray:(NSArray *)locations distanceArray:(NSArray *)distance
{
    NSMutableArray *annotations = [NSMutableArray array];
    double dist = 0;
    int y = 1;
    
    //增加起点
    DistanceAnnotation *annotationfiret = [[DistanceAnnotation alloc]init];
    Location *firlocation = [locations firstObject];
    annotationfiret.coordinate = CLLocationCoordinate2DMake(firlocation.latitude.doubleValue, firlocation.longitude.doubleValue);
    annotationfiret.image = [UIImage imageNamed:@"start"];
    [annotations addObject:annotationfiret];
    
    if ([distance.lastObject doubleValue] < 1000.0) {
        DistanceAnnotation *annotationlast = [[DistanceAnnotation alloc]init];
        Location *laslocation = [locations lastObject];
        annotationlast.coordinate = CLLocationCoordinate2DMake(laslocation.latitude.doubleValue, laslocation.longitude.doubleValue);
        annotationlast.image = [UIImage imageNamed:@"end"];
        [annotations addObject:annotationlast];
        return annotations;
    }
    
    //遍历distance数组，每1km整合一次
    for (int i = 0; i < distance.count ; i++)
    {
        dist = [[distance objectAtIndex:i] doubleValue];
        if (dist >= 1000*y)
        {
            DistanceAnnotation *annotation = [[DistanceAnnotation alloc]init];
            Location *location = [locations objectAtIndex:i];
            annotation.coordinate = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
            
            //设置里程图片
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 16, 16)];
            label.text = [NSString stringWithFormat:@"%i",y];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            
            UIGraphicsBeginImageContextWithOptions(label.frame.size, NO, 0.0);
            [label.layer renderInContext:UIGraphicsGetCurrentContext()];
            annotation.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
                
            [annotations addObject:annotation];
            y ++;
        }
    }
    
    //增加终点
    DistanceAnnotation *annotationlast = [[DistanceAnnotation alloc]init];
    Location *laslocation = [locations lastObject];
    annotationlast.coordinate = CLLocationCoordinate2DMake(laslocation.latitude.doubleValue, laslocation.longitude.doubleValue);
    annotationlast.image = [UIImage imageNamed:@"end"];
    [annotations addObject:annotationlast];
    return annotations;
}

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations speeds:(NSArray *)smoothSpeeds
{
    
    // 排列速度数组
    NSArray *sortedArray = [smoothSpeeds sortedArrayUsingSelector:@selector(compare:)];
    
    // 找到中间值
    double medianSpeed = ((NSNumber *)[sortedArray objectAtIndex:(locations.count/2)]).doubleValue;
    
    // RGB for red (slowest)
    CGFloat r_red = 1.0f;
    CGFloat r_green = 20/255.0f;
    CGFloat r_blue = 44/255.0f;
    
    // RGB for yellow (middle)
    CGFloat y_red = 1.0f;
    CGFloat y_green = 215/255.0f;
    CGFloat y_blue = 0.0f;
    
    // RGB for green (fastest)
    CGFloat g_red = 0.0f;
    CGFloat g_green = 146/255.0f;
    CGFloat g_blue = 78/255.0f;
    
    NSMutableArray *colorSegments = [NSMutableArray array];
    
    for (int i = 1; i < locations.count; i++) {
        Location *firstLoc = [locations objectAtIndex:(i-1)];
        Location *secondLoc = [locations objectAtIndex:i];
        
        CLLocationCoordinate2D coords[2];
        coords[0].latitude = firstLoc.latitude.doubleValue;
        coords[0].longitude = firstLoc.longitude.doubleValue;
        
        coords[1].latitude = secondLoc.latitude.doubleValue;
        coords[1].longitude = secondLoc.longitude.doubleValue;
        
        NSNumber *speed = [smoothSpeeds objectAtIndex:(i-1)];
        UIColor *color;
        
        // between red and yellow
        if (speed.doubleValue < medianSpeed) {
            NSUInteger index = [sortedArray indexOfObject:speed];
            double ratio = (int)index / ((int)locations.count/2.0);
            CGFloat red = r_red + ratio * (y_red - r_red);
            CGFloat green = r_green + ratio * (y_green - r_green);
            CGFloat blue = r_blue + ratio * (y_blue - r_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
            
            // between yellow and green
        } else {
            NSUInteger index = [sortedArray indexOfObject:speed];
            double ratio = ((int)index - (int)locations.count/2.0) / ((int)locations.count/2.0);
            CGFloat red = y_red + ratio * (g_red - y_red);
            CGFloat green = y_green + ratio * (g_green - y_green);
            CGFloat blue = y_blue + ratio * (g_blue - y_blue);
            color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        }
        
        ColorPolyline *segment = [ColorPolyline polylineWithCoordinates:coords count:2];
        segment.color = color;
        
        [colorSegments addObject:segment];
    }
    
    return colorSegments;
}


@end

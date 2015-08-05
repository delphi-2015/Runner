
#import "MapDetialView.h"
#import <MapKit/MapKit.h>
#import "Location.h"
#import "DistanceAnnotation.h"
#import "ColorPolyline.h"

static const int idealSmoothReachSize = 33; // about 133 locations/mi

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
    annotationfiret.image = [UIImage imageNamed:@"mapPin"];
    [annotations addObject:annotationfiret];
    
    if ([distance.lastObject doubleValue] < 1000.0) {
        DistanceAnnotation *annotationlast = [[DistanceAnnotation alloc]init];
        Location *laslocation = [locations lastObject];
        annotationlast.coordinate = CLLocationCoordinate2DMake(laslocation.latitude.doubleValue, laslocation.longitude.doubleValue);
        annotationlast.image = [UIImage imageNamed:@"mapPin"];
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
    annotationlast.image = [UIImage imageNamed:@"mapPin"];
    [annotations addObject:annotationlast];
    return annotations;
}

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations
{
    if (locations.count == 1){
        Location *loc      = [locations firstObject];
        CLLocationCoordinate2D coords[2];
        coords[0].latitude      = loc.latitude.doubleValue;
        coords[0].longitude     = loc.longitude.doubleValue;
        coords[1].latitude      = loc.latitude.doubleValue;
        coords[1].longitude     = loc.longitude.doubleValue;
        
        ColorPolyline *segment = [ColorPolyline polylineWithCoordinates:coords count:2];
        segment.color = [UIColor blackColor];
        return @[segment];
    }
    
    // make array of all speeds
    NSMutableArray *rawSpeeds = [NSMutableArray array];
    
    for (int i = 1; i < locations.count; i++) {
        Location *firstLoc = [locations objectAtIndex:(i-1)];
        Location *secondLoc = [locations objectAtIndex:i];
        
        CLLocation *firstLocCL = [[CLLocation alloc] initWithLatitude:firstLoc.latitude.doubleValue longitude:firstLoc.longitude.doubleValue];
        CLLocation *secondLocCL = [[CLLocation alloc] initWithLatitude:secondLoc.latitude.doubleValue longitude:secondLoc.longitude.doubleValue];
        
        double distance = [secondLocCL distanceFromLocation:firstLocCL];
        double time = [secondLoc.timestamp timeIntervalSinceDate:firstLoc.timestamp];
        double speed = distance/time;
        
        [rawSpeeds addObject:[NSNumber numberWithDouble:speed]];
    }
    
    // smooth the raw speeds
    NSMutableArray *smoothSpeeds = [NSMutableArray array];
    
    for (int i = 0; i < rawSpeeds.count; i++) {
        
        // set to ideal size
        int lowerBound = i - idealSmoothReachSize / 2;
        int upperBound = i + idealSmoothReachSize / 2;
        
        // scale back reach as necessary
        if (lowerBound < 0) {
            lowerBound = 0;
        }
        
        if (upperBound > ((int)rawSpeeds.count - 1)) {
            upperBound = (int)rawSpeeds.count - 1;
        }
        
        // define range for average
        NSRange range;
        range.location = lowerBound;
        range.length = upperBound - lowerBound;
        
        // get values to average
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        NSArray *relevantSpeeds = [rawSpeeds objectsAtIndexes:indexSet];
        
        double total = 0.0;
        
        for (NSNumber *speed in relevantSpeeds) {
            total += speed.doubleValue;
        }
        
        double smoothAverage = total / (double)(upperBound - lowerBound);
        
        [smoothSpeeds addObject:[NSNumber numberWithDouble:smoothAverage]];
    }
    
    // sort the smoothed speeds
    NSArray *sortedArray = [smoothSpeeds sortedArrayUsingSelector:@selector(compare:)];
    
    // find median
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
        UIColor *color = [UIColor blackColor];
        
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

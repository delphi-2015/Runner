
#import "MapDetialView.h"
#import <MapKit/MapKit.h>
#import "Location.h"
#import "DistanceAnnotation.h"

@implementation MapDetialView

+ (NSArray *)annotationsForlocationArray:(NSArray *)locations distanceArray:(NSArray *)distance
{
  
    
    NSMutableArray *annotations = [NSMutableArray array];
    double dist = 0;
    int y = 1;
    
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
    
    DistanceAnnotation *annotationlast = [[DistanceAnnotation alloc]init];
    Location *laslocation = [locations lastObject];
    annotationlast.coordinate = CLLocationCoordinate2DMake(laslocation.latitude.doubleValue, laslocation.longitude.doubleValue);
    annotationlast.image = [UIImage imageNamed:@"mapPin"];
    [annotations addObject:annotationlast];
    return annotations;
}


@end

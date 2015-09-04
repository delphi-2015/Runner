#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>  

@interface WGS84TOGCJ02 : NSObject

//判断是否已经超出中国范围
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
//转GCJ-02
+ (CLLocation *)transformFromWGSToGCJ:(CLLocation *)wgsLoction;

@end

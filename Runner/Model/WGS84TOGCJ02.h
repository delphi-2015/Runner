//
//  WGS84TOGCJ02.h
//  Runner
//
//  Created by delphiwu on 15/7/19.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>  

@interface WGS84TOGCJ02 : NSObject

//判断是否已经超出中国范围
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
//转GCJ-02
+ (CLLocation *)transformFromWGSToGCJ:(CLLocation *)wgsLoction;

@end

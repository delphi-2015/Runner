//
//  DistanceAnnotation.h
//  Runner
//
//  Created by delphiwu on 15/7/29.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DistanceAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong,nonatomic) NSString *imageName;
@property (strong ,nonatomic) UIImage *image;

@end

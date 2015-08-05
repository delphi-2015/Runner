//
//  MapDetialView.h
//  Runner
//
//  Created by delphiwu on 15/7/24.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapDetialView : NSObject

+ (NSArray *)annotationsForlocationArray:(NSArray *)locations distanceArray:(NSArray *)distance;
+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;
@end

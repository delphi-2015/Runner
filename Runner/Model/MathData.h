//
//  MathData.h
//  Runner
//
//  Created by delphiwu on 15/7/19.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathData : NSObject

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds ifleft:(BOOL)left;
+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;

@end

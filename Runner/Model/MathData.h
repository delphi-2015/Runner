
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MathData : NSObject

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds ifleft:(BOOL)left;
+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;

@end


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PERSON_WEIGHT ([[NSUserDefaults standardUserDefaults] objectForKey:@"weight"] == nil? 0.0:([[NSUserDefaults standardUserDefaults] floatForKey:@"weight"]))

@interface MathData : NSObject

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds ifleft:(BOOL)left;
+ (float)valueifDistance:(float)meters andTime:(int)seconds;

@end

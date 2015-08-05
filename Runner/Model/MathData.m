#import "MathData.h"
#import "Location.h"
#import <CoreLocation/CoreLocation.h>
#import "ColorPolyline.h"

static bool const isMetric = YES;
static float const metersInKM = 1000;
static float const metersInMile = 1609.344;

@implementation MathData

+ (NSString *)stringifyDistance:(float)meters
{
    float unitDivider;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        unitName = @"km";
        // to get from meters to kilometers divide by this
        unitDivider = metersInKM;
        // U.S.
    } else {
        unitName = @"mi";
        // to get from meters to miles divide by this
        unitDivider = metersInMile;
    }
    
    float distance = meters/unitDivider;
    if (distance>10.0)
    {
        return [NSString stringWithFormat:@"%.1f%@", distance, unitName];
    }else
    {
        return [NSString stringWithFormat:@"%.2f%@", distance, unitName];
    }
}

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat
{
    int remainingSeconds = seconds;
    int hours = remainingSeconds / 3600;
    remainingSeconds = remainingSeconds - hours * 3600;
    int minutes = remainingSeconds / 60;
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (longFormat) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%ihr %imin %isec", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%imin %isec", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"%isec", remainingSeconds];
        }
    } else {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%02i:%02i", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"00:%02i", remainingSeconds];
        }
    }
}

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds ifleft:(BOOL)left
{
    if (seconds == 0 || meters == 0) {
        return @"00:00";
    }
    NSString *unitName;
    float unitMultiplier;
    // metric
    if (isMetric) {
        unitName = @"min/km";
        unitMultiplier = metersInKM;
    // U.S.
    } else {
        unitName = @"min/mi";
        unitMultiplier = metersInMile;
    }
    
    if (left)
    {
        float avgPaceSecMeters = seconds / meters;
        int paceMin = (int) ((avgPaceSecMeters * unitMultiplier) / 60);
        int paceSec = (int) (avgPaceSecMeters * unitMultiplier - (paceMin*60));
    
        return [NSString stringWithFormat:@"%i:%02i%@", paceMin, paceSec, unitName];
    }else
    {
        float avgPaceMetersSec = meters/seconds*3.6;
        return [NSString stringWithFormat:@"%.2fkm/h",avgPaceMetersSec];
    }
}

+ (float)valueifDistance:(float)meters andTime:(int)seconds
{
    float speed = seconds/meters*40/6; //分钟／400米
    return PERSON_WEIGHT*30/speed*seconds/3600;
    //跑步热量（kcal）＝体重（kg）×运动时间（小时）×指数K  指数K＝30÷速度（分钟/400米）
}

@end

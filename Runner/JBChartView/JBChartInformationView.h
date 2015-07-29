#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JBChartInformationViewLayout){
	JBChartInformationViewLayoutHorizontal, // default
    JBChartInformationViewLayoutVertical
};

@interface JBChartInformationView : UIView

/*
 * View must be initialized with a layout type (default = horizontal)
 */
- (id)layout:(JBChartInformationViewLayout)layout;

@property (nonatomic, assign, readonly) JBChartInformationViewLayout layout; // read-only (must be set in init..)

// Content
- (void)setTitleText:(NSString *)titleText unitText:(NSString *)unitText;
- (void)setValueText:(NSString *)valueText unitText:(NSString *)unitText;

// Color
- (void)setTitleTextColor:(UIColor *)titleTextColor;
- (void)setValueAndUnitTextColor:(UIColor *)valueAndUnitColor;
- (void)setTextShadowColor:(UIColor *)shadowColor;
- (void)setSeparatorColor:(UIColor *)separatorColor;

// Visibility
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end

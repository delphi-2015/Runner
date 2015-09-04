//
//  CountDownView.m
//  Runner
//
//  Created by delphiwu on 15/9/4.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import "CountDownView.h"

@interface CountDownView ()

@property (assign, nonatomic) NSInteger currentCountDownNumber;
@property (strong, nonatomic) UILabel *countDownLabel;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation CountDownView

- (void)updateAppearance
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    
    self.countDownLabel = [[UILabel alloc] init];
    [self.countDownLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium"size:self.bounds.size.width*0.3]];
    [self.countDownLabel setTextColor:[UIColor blackColor]];
    self.countDownLabel.textAlignment = NSTextAlignmentCenter;
    
    self.countDownLabel.opaque = YES;
    self.countDownLabel.alpha = 1.0;
    [self addSubview: self.countDownLabel];
    
    self.countDownLabel.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + 400, self.frame.size.height);
    [self.countDownLabel setCenter:self.center];
}

- (void)start
{
    self.currentCountDownNumber = self.countDownNumber;
    self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentCountDownNumber];
    [self animate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(animate)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stop
{
    [self.timer invalidate];
}

- (void)animate
{
    [UIView animateWithDuration:0.8 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(2.5, 2.5);
        self.countDownLabel.transform = transform;
        self.countDownLabel.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished)
        {
            if (self.currentCountDownNumber == 0)
            {
                [self stop];
                if (self.delegate)
                {
                    [self.delegate countDownfinished];
                }
            }else
            {
                self.countDownLabel.transform = CGAffineTransformIdentity;
                self.countDownLabel.alpha = 1.0;
            
                self.currentCountDownNumber--;
                if (self.currentCountDownNumber == 0)
                {
                    self.countDownLabel.text = self.finishText;
                }else
                {
                    self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentCountDownNumber];
                }
            }
        }
    }];
}

@end

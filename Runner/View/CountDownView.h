//
//  CountDownView.h
//  Runner
//
//  Created by delphiwu on 15/9/4.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountDownViewdelegate <NSObject>

@required

- (void)countDownfinished;

@end

@interface CountDownView : UIView

@property (strong, nonatomic) NSString *finishText;
@property (assign, nonatomic) NSInteger countDownNumber;

@property (weak, nonatomic) id<CountDownViewdelegate> delegate;

- (void)updateAppearance;
- (void)start;

@end

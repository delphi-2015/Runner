//
//  ScrollViewController.h
//  Runner
//
//  Created by delphiwu on 15/7/31.
//  Copyright (c) 2015年 Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

#import "ScrollViewController.h"

@interface ScrollViewController ()

@property (assign,nonatomic) NSInteger lastPageNum;

@end

@implementation ScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setDelegate:self];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"navigation"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"analyzeView"]];
    
    [self.pageControl setNumberOfPages:2];
    [self.pageControl setCurrentPage:0];
    self.lastPageNum = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSUInteger i =0; i < [self.childViewControllers count]; i++) {
        [self loadScrollViewWithPage:i];
    }
    
    self.pageControl.currentPage = self.lastPageNum;
    
    UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
    if (viewController.view.superview != nil) {
        [viewController viewWillAppear:animated];
    }
    
    self.scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * [self.childViewControllers count], 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.childViewControllers count]) {
        UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
        if (viewController.view.superview != nil) {
            [viewController viewDidAppear:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.childViewControllers count]) {
        UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
        if (viewController.view.superview != nil) {
            [viewController viewWillDisappear:animated];
        }
        self.lastPageNum = self.pageControl.currentPage;
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
    if (viewController.view.superview != nil) {
        [viewController viewDidDisappear:animated];
    }
    [super viewDidDisappear:animated];
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= [self.childViewControllers count])
        return;
    
    // 替换占位符
    UIViewController *controller = [self.childViewControllers objectAtIndex:page];
    if (controller == nil) {
        return;
    }
    
    // 将controller添加到scrollview
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    UIViewController *previousVC = [self.childViewControllers objectAtIndex:1-self.pageControl.currentPage];
    UIViewController *currentVC = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
    [previousVC viewDidDisappear:YES];
    [currentVC viewDidAppear:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //当滑动超过50%的时候就切换视图
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    page = page > 1 ? 1 : page;
    page = page < 0 ? 0 : page;
    if (self.pageControl.currentPage != page) {
        UIViewController *oldViewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
        UIViewController *newViewController = [self.childViewControllers objectAtIndex:page];
        [oldViewController viewWillDisappear:YES];
        [newViewController viewWillAppear:YES];
        self.pageControl.currentPage = page;
        [oldViewController viewDidDisappear:YES];
        [newViewController viewDidAppear:YES];
    }
}
@end

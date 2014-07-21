//
//  AEPageViewController.m
//  huffingtonpost
//
//  Created by Ahmed Eid on 10/1/12.
//  Copyright (c) 2012 Huffington Post. All rights reserved.
//

#import "AEPageViewController.h"

@interface AEPageViewController ()

@property (nonatomic, strong) UIViewController *previousViewController;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIViewController *nextViewController;

@property (nonatomic, strong) NSMutableArray *internalViewConrollers;

@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) int currentPage;

@end

@implementation AEPageViewController

@dynamic viewControllers;

- (instancetype)initWithTransitionStyle:(AEPageViewControllerTransitionStyle)style {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    [self recalculateViewFrames];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    
    [self.view addSubview:self.scrollView];

    self.lastOffset = CGPointZero;
    self.internalViewConrollers = [[NSMutableArray alloc] init];
}

-(void)setPaddingSpaceBetweenViewControllers:(CGFloat)paddingSpaceBetweenViewControllers {
    if (self.paddingSpaceBetweenViewControllers !=paddingSpaceBetweenViewControllers){
        _paddingSpaceBetweenViewControllers = paddingSpaceBetweenViewControllers;
        if(self.scrollView) {
            self.scrollView.frame = [self frameForPagingScrollView];
            [self recalculateViewFrames];
        }
    }
}

- (void)setViewControllers:(NSArray *)viewControllers direction:(AEPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    
    [self clearViewController:self.previousViewController];
    [self clearViewController:self.nextViewController];
    
    if (viewControllers == nil || viewControllers.count ==0){
        [self clearViewController:self.currentViewController];
    }
    
    UIViewController *viewController = viewControllers[0];
   
    if (animated){        
        if(direction == AEPageViewControllerNavigationDirectionForward) {
            self.nextViewController = viewController;
            [self addViewController:self.nextViewController atIndexZero:NO];
        }
        else {
            self.previousViewController = viewController;
            [self addViewController:self.previousViewController atIndexZero:YES];
        }
        [self recalculateViewFrames];

        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
            self.scrollView.contentOffset = CGPointMake(viewController.view.frame.origin.x,0);
            
        } completion:^(BOOL finished) {            
            if(self.currentViewController!=viewController)
            {
                [self clearViewController:self.currentViewController];
                self.currentViewController = viewController;
            }
            self.previousViewController = [self.dataSource pageViewController:self viewControllerBeforeViewController:viewController];
            if (self.previousViewController){
                [self addViewController:self.previousViewController atIndexZero:YES];
            }
            
            self.nextViewController = [self.dataSource pageViewController:self viewControllerAfterViewController:viewController];
            if (self.nextViewController){
                [self addViewController:self.nextViewController atIndexZero:NO];
            }
            [self recalculateViewFrames];
            
            if (completion) completion (finished);
        }];
    } else {
        if(self.currentViewController!=viewController) {
            if(viewController)
                [self addViewController:viewController atIndexZero:NO];
            BOOL success = YES;
            [self clearViewController:self.currentViewController];
            self.currentViewController = viewController;

            if (completion) completion (success);
        }
        
        if(!viewController)
            return;
        self.previousViewController = [self.dataSource pageViewController:self viewControllerBeforeViewController:viewController];
        if (self.previousViewController){
            [self addViewController:self.previousViewController atIndexZero:YES];
        }
        
        self.nextViewController = [self.dataSource pageViewController:self viewControllerAfterViewController:viewController];
        if (self.nextViewController){
            [self addViewController:self.nextViewController atIndexZero:NO];
        }
        [self recalculateViewFrames];
    }
}

- (void)goToViewControllerInDirection:(AEPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if(!self.currentViewController)
        return;
    
    UIViewController* gotoViewController = nil;
    
    
    if(direction==AEPageViewControllerNavigationDirectionForward) {
        if(!self.nextViewController)
            return;
        
        gotoViewController = [self.dataSource pageViewController:self viewControllerAfterViewController:self.nextViewController];
                
        [self clearViewController:self.previousViewController];
        
        self.previousViewController = self.currentViewController;
        self.currentViewController = self.nextViewController;
        self.nextViewController = nil;
        if(gotoViewController) {
            self.nextViewController = gotoViewController;
            [self addViewController:gotoViewController atIndexZero:NO];
        }
        [self recalculateViewFrames];
        if (animated){
            [self.scrollView scrollRectToVisible:self.previousViewController.view.frame animated:NO];
            
            [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
                [self.scrollView scrollRectToVisible:self.currentViewController.view.frame animated:NO];
            } completion:^(BOOL finished) {
                if (completion) completion(finished);
                if ([self.delegate respondsToSelector:@selector(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)]) {
                    [self.delegate pageViewController:self
                                     didFinishAnimating:YES
                                previousViewControllers:(self.previousViewController)?@[self.previousViewController]:nil
                                    transitionCompleted:YES];
                }
            }];
        }
    }
    else {
        if(!self.previousViewController)
            return;
       
        gotoViewController = [self.dataSource pageViewController:self viewControllerBeforeViewController:self.previousViewController];
        
        [self clearViewController:self.nextViewController];
        
        self.nextViewController = self.currentViewController;
        self.currentViewController = self.previousViewController;
        self.previousViewController = nil;
        if(gotoViewController) {
            self.previousViewController = gotoViewController;
            [self addViewController:gotoViewController atIndexZero:YES];
        }
        [self recalculateViewFrames];
        
        if (animated){
            [self.scrollView scrollRectToVisible:self.nextViewController.view.frame animated:NO];
            
            [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
                [self.scrollView scrollRectToVisible:self.currentViewController.view.frame animated:NO];
            } completion:^(BOOL finished) {
                if (completion) completion(finished);
                if ([self.delegate respondsToSelector:@selector(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:)]) {
                    [self.delegate pageViewController:self
                                     didFinishAnimating:YES
                                previousViewControllers:(self.nextViewController)?@[self.nextViewController]:nil
                                    transitionCompleted:YES];
                }
            }];
        }
    }
}

#pragma mark - Frame Calculations

-(void)recalculateViewFrames {

    //Set correct frame for each view controller
    int count = 0;
    for (UIViewController* vc in self.internalViewConrollers) {
         CGRect frame = [self frameForViewControllerAtIndex:count];
       if(self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:insetForViewController:)]) {
            frame = UIEdgeInsetsInsetRect(frame, [self.delegate pageViewController:self insetForViewController:vc ]) ;
        }
        vc.view.frame = frame;
        count++;
    }
    
    //Set updated content size for scrollview 
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    self.scrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * self.internalViewConrollers.count, pagingScrollViewFrame.size.height);
    
    //Set updated content size to currentViewControllers offset minus padding 
    CGPoint offSet = CGPointZero;//self.currentViewController.view.frame.origin;
    offSet.y = 0;
    offSet.x = self.currentViewController.view.frame.origin.x-self.paddingSpaceBetweenViewControllers;
    [self.scrollView setContentOffset:offSet animated:NO];
}

- (CGRect)frameForViewControllerAtIndex:(int)index {
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    CGRect pageFrame = pagingScrollViewFrame;
    pageFrame.size.width = self.view.bounds.size.width;
    pageFrame.origin.x = (pagingScrollViewFrame.size.width * index) + (self.paddingSpaceBetweenViewControllers) ;
    return pageFrame;
}

- (CGRect)frameForPagingScrollView {
    CGRect frame = [self.view bounds];
    frame.origin.x -= self.paddingSpaceBetweenViewControllers;
    frame.size.width += (2 * self.paddingSpaceBetweenViewControllers);

    return frame;
}

#pragma mark - UIScrollViewDelegate 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastOffset = scrollView.contentOffset;
    if([self.delegate respondsToSelector:@selector(pageViewControllerWillBeginSwipe:)])
        [self.delegate pageViewControllerWillBeginSwipe:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = self.scrollView.bounds.size.width;
    int currentPage = (self.scrollView.contentOffset.x + width/2.0f) / width;
    self.currentPage = currentPage;
    
    if ([self.delegate respondsToSelector:@selector(pageViewControllerDidScroll:)]) {
        [self.delegate pageViewControllerDidScroll:self];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    scrollView.userInteractionEnabled = NO;
    scrollView.panGestureRecognizer.enabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < self.lastOffset.x) {
        self.lastOffset = CGPointZero;
        [self goToPreviousPage];
        [self recalculateViewFrames];
        [self.delegate pageViewController:self didFinishAnimating:YES previousViewControllers:(self.nextViewController)?@[self.nextViewController]:nil transitionCompleted:YES];
        
    }
    else if (scrollView.contentOffset.x > self.lastOffset.x) {
        self.lastOffset = CGPointZero;
        [self goToNextPage];
        [self recalculateViewFrames];
        [self.delegate pageViewController:self didFinishAnimating:YES previousViewControllers:(self.previousViewController)?@[self.previousViewController]:nil transitionCompleted:YES];
    }
    else {
        [self.delegate pageViewController:self didFinishAnimating:YES previousViewControllers:nil transitionCompleted:NO];
    }
    
    scrollView.userInteractionEnabled = YES;
    scrollView.panGestureRecognizer.enabled = YES;
}

#pragma mark - Getter & Setter overrides

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.scrollView.scrollEnabled = scrollEnabled;
}

#pragma mark - Helper Methods

- (void)goToNextPage {
    [self.delegate pageViewController:self willTransitionToViewControllers:self.viewControllers];
    
    if (self.previousViewController) {
        [self clearViewController:self.previousViewController];
    }
    if (self.nextViewController) {
        self.previousViewController = self.currentViewController;
        self.currentViewController = self.nextViewController;
        self.nextViewController = [self.dataSource pageViewController:self viewControllerAfterViewController:self.currentViewController];
        if (self.nextViewController){
            [self addViewController:self.nextViewController atIndexZero:NO];
        }
    }    
}

- (void)goToPreviousPage {
    [self.delegate pageViewController:self willTransitionToViewControllers:self.viewControllers];

    if (self.nextViewController) {
        [self clearViewController:self.nextViewController];
    }
    
    if (self.previousViewController) {
        self.nextViewController = self.currentViewController;
        self.currentViewController = self.previousViewController;
        self.previousViewController = [self.dataSource pageViewController:self viewControllerBeforeViewController:self.currentViewController];
        if (self.previousViewController){
            [self addViewController:self.previousViewController atIndexZero:YES];
        }
    } 
}

- (void)clearViewController:(UIViewController *)controller{
    [self.internalViewConrollers removeObject:controller];
    [controller didMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    controller = nil;
}

- (void)addViewController:(UIViewController *)controller atIndexZero:(BOOL)atIndexZero {
    [self addChildViewController:controller];
    [self.scrollView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
   
    if (atIndexZero == YES){
        [self.internalViewConrollers insertObject:controller atIndex:0];
    } else {
        [self.internalViewConrollers addObject:controller];
    }
 }

- (NSArray*)viewControllers {
    return (self.currentViewController)? @[self.currentViewController]:nil;
}

- (void)dealloc {
    [super dealloc];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.internalViewConrollers = nil;
    self.scrollView = nil;
    self.previousViewController = nil;
    self.nextViewController = nil;
    self.currentViewController = nil;
}

@end

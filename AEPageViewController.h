//
//  AEPageViewController.h
//  huffingtonpost
//
//  Created by Ahmed Eid on 10/1/12.
//  Copyright (c) 2012 Huffington Post. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AEPageViewControllerNavigationDirectionForward,
    AEPageViewControllerNavigationDirectionReverse,
    AEPageViewControllerNavigationDirectionNone,
} AEPageViewControllerNavigationDirection;

typedef enum {
    AEPageViewControllerTransitionStylePageCurl = 0,
    AEPageViewControllerTransitionStyleScroll = 1
} AEPageViewControllerTransitionStyle;

@protocol AEPageViewControllerDelegate, AEPageViewControllerDataSource;

@interface AEPageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) CGFloat paddingSpaceBetweenViewControllers;
@property (nonatomic, strong, readonly) UIViewController *currentViewController;
@property (nonatomic, strong, readonly) UIViewController *previousViewController;
@property (nonatomic, strong, readonly) UIViewController *nextViewController;

- (instancetype)initWithTransitionStyle:(AEPageViewControllerTransitionStyle)style;

@property (nonatomic, assign) id <AEPageViewControllerDelegate> delegate;
@property (nonatomic, assign) id <AEPageViewControllerDataSource> dataSource;
@property (nonatomic, readonly) AEPageViewControllerTransitionStyle transitionStyle;
@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, strong, readonly) NSMutableArray *internalViewConrollers;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)setViewControllers:(NSArray *)viewControllers direction:(AEPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)goToViewControllerInDirection:(AEPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@protocol AEPageViewControllerDelegate <NSObject>

@optional

- (void)pageViewControllerWillBeginSwipe:(AEPageViewController *)pageViewController;

// Sent when a gesture-initiated transition begins.
- (void)pageViewController:(AEPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers;

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
- (void)pageViewController:(AEPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;

- (UIEdgeInsets)pageViewController:(AEPageViewController *)pageViewController insetForViewController:(UIViewController *)viewController;

- (void)pageViewControllerDidScroll:(AEPageViewController *)pageViewController;

@end

@protocol AEPageViewControllerDataSource <NSObject>

@required

- (UIViewController *)pageViewController:(AEPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
- (UIViewController *)pageViewController:(AEPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

@optional

- (NSInteger)presentationCountForPageViewController:(AEPageViewController *)pageViewController;
- (NSInteger)presentationIndexForPageViewController:(AEPageViewController *)pageViewController;

@end

//
//  GDGoodsDetailViewController.m
//  GoodsDetailDemo
//
//  Created by 恺撒 on 2016/12/13.
//  Copyright © 2016年 God Is A Girl. All rights reserved.
//

#import "GDGoodsDetailViewController.h"
#import "GDGoodsDetailBottomView.h"
#import "GDUpGeneralInfomationView.h"
#import "GDMiddleTabSwitchView.h"
#import "GDDownDetailInfomationView.h"
#import "GDDownSpecificationSizeView.h"
#import "GDDownHotSaleRecommendView.h"
#import "GDDownInfomationViewProtocol.h"
#import "GDDownInfomationViewDataSource.h"
#import "GDDownInfomationViewDelegate.h"
#import "UIView+GDFrameKit.h"
#import "GDMacros.h"
#import "GDConst.h"

@interface GDGoodsDetailViewController ()<UIScrollViewDelegate,GDUpGeneralInfomationViewDelegate,GDMiddleTabSwitchViewDelegate,GDDownInfomationViewDataSource,GDDownInfomationViewDelegate>

@property (nonatomic, strong) GDGoodsDetailBottomView *bottomView;
@property (nonatomic, strong) GDUpGeneralInfomationView *upInfomationView;
@property (nonatomic, strong) GDMiddleTabSwitchView *tabSwitchView;
@property (nonatomic, strong) UIView <GDDownInfomationViewProtocol>*currentInfoView;
@property (nonatomic, strong) UIScrollView *fullScrollView;
@property (nonatomic, strong) UIView *tabSwitchSnapShotView;
@property (nonatomic, strong) NSMutableArray *sectionHeaderViewArray;
@property (nonatomic, strong) NSArray *tabTitlesArray;
@property (nonatomic, assign) NSInteger currentShowIndex;
@property (nonatomic, assign) BOOL isReachTop;

@end

@implementation GDGoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"商品详情页Demo";
    [self initSubview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubview {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kNavigationBarHeight - kBottomBarHeight)];
    scrollView.contentSize = CGSizeMake(scrollView.width * 3, scrollView.height);
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.fullScrollView = scrollView;
    
    UIView *tableHeaderview1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, self.upInfomationView.totalHeight)];
    UIView *tableHeaderview2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, self.upInfomationView.totalHeight)];
    UIView *tableHeaderview3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, self.upInfomationView.totalHeight)];
    
    // 暂时显示子控件及位置都是固定的
    GDDownDetailInfomationView *detailSubView = [[GDDownDetailInfomationView alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, scrollView.height)];
    GDDownSpecificationSizeView *sizeSubView = [[GDDownSpecificationSizeView alloc] initWithFrame:CGRectMake(scrollView.width, 0, scrollView.width, scrollView.height)];
    GDDownHotSaleRecommendView *recommendSubView = [[GDDownHotSaleRecommendView alloc] initWithFrame:CGRectMake(scrollView.width * 2, 0, scrollView.width, scrollView.height)];
    detailSubView.tag = 0;
    sizeSubView.tag = 1;
    recommendSubView.tag = 2;
    detailSubView.dataSource = self;
    detailSubView.delegate = self;
    sizeSubView.dataSource = self;
    sizeSubView.delegate = self;
    recommendSubView.dataSource = self;
    recommendSubView.delegate = self;
    detailSubView.scrollView.tableHeaderView = tableHeaderview1;
    sizeSubView.scrollView.tableHeaderView = tableHeaderview2;
    recommendSubView.scrollView.tableHeaderView = tableHeaderview3;
    
    [self.fullScrollView addSubview:detailSubView];
    [self.fullScrollView addSubview:sizeSubView];
    [self.fullScrollView addSubview:recommendSubView];
    
    // 暂时默认显示第一个
    _currentShowIndex = 1000;
    self.currentShowIndex = 0;
    [detailSubView.scrollView.tableHeaderView addSubview:self.upInfomationView];
    
    self.bottomView = [[GDGoodsDetailBottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - kBottomBarHeight, SCREEN_WIDTH, kBottomBarHeight)];
    self.bottomView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.bottomView];

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.upInfomationView.superview) {
        [self.upInfomationView removeFromSuperview];
    }
    CGFloat offsetY = self.currentInfoView.scrollView.contentOffset.y;
    self.upInfomationView.top = -offsetY + kNavigationBarHeight;
    [self.view addSubview:self.upInfomationView];
    [self.view addSubview:self.tabSwitchSnapShotView];
    [self.view bringSubviewToFront:self.bottomView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (decelerate) return;
    [self stopScrollFinallyWithScrollView:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self stopScrollFinallyWithScrollView:scrollView];
}

#pragma mark - GDDownInfomationViewDataSource

- (CGFloat)gd_scrollView:(UIScrollView *)scrollView heightForHeaderInSection:(NSInteger)section {
    return kTabSwitchViewHeight;
}

- (UIView *)gd_scrollView:(UIScrollView *)scrollView viewForHeaderInSection:(NSInteger)section {
    UIView *oneHeaderView = [self.sectionHeaderViewArray objectAtIndex:scrollView.tag];
    if (self.currentInfoView.scrollView == scrollView) {
        if (self.tabSwitchView.superview) {
            [self.tabSwitchView removeFromSuperview];
        }
        [oneHeaderView addSubview:self.tabSwitchView];
    }
    return oneHeaderView;
}

#pragma mark - GDDownInfomationViewDelegate

- (void)gd_scrollView:(UIScrollView *)scrollView currentScrollOffsetY:(CGFloat)offsetY {
    
    if (offsetY >= self.upInfomationView.totalHeight && !_isReachTop) {
        self.isReachTop = YES;
        [self.fullScrollView.subviews enumerateObjectsUsingBlock:^(UIView <GDDownInfomationViewProtocol>*subView, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subView conformsToProtocol:@protocol(GDDownInfomationViewProtocol)]) {
                if (scrollView != subView.scrollView) {
                    [subView.scrollView setContentOffset:CGPointMake(0, self.upInfomationView.totalHeight) animated:NO];
                }
            }
        }];
    }
    else if (offsetY < self.upInfomationView.totalHeight && _isReachTop) {
        self.isReachTop = NO;
    }
    if (!_isReachTop) {
        [self.fullScrollView.subviews enumerateObjectsUsingBlock:^(UIView <GDDownInfomationViewProtocol>*subView, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subView conformsToProtocol:@protocol(GDDownInfomationViewProtocol)]) {
                if (scrollView != subView.scrollView) {
                    [subView.scrollView setContentOffset:CGPointMake(0, offsetY) animated:NO];
                }
            }
        }];
    }
}

#pragma mark - GDMiddleTabSwitchViewDelegate

- (void)tabSwitchViewDidSelectIndex:(NSInteger)index {
    
    [self.fullScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0) animated:NO];
    if (self.upInfomationView.superview) {
        [self.upInfomationView removeFromSuperview];
    }
    if (self.tabSwitchView.superview) {
        [self.tabSwitchView removeFromSuperview];
    }
    self.currentShowIndex = index;
    UIView *oneHeaderView = [self.sectionHeaderViewArray objectAtIndex:index];
    [oneHeaderView addSubview:self.tabSwitchView];
    [self.currentInfoView.scrollView.tableHeaderView addSubview:self.upInfomationView];
}

#pragma mark - GDUpGeneralInfomationViewDelegate

- (void)upGeneralInfomationViewHeightChange:(CGFloat)totalHeight {

    self.upInfomationView.height = totalHeight;
    [self.fullScrollView.subviews enumerateObjectsUsingBlock:^(UIView <GDDownInfomationViewProtocol>*subView, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([subView conformsToProtocol:@protocol(GDDownInfomationViewProtocol)]) {
            UIView *newView = subView.scrollView.tableHeaderView;
            newView.height = totalHeight;
            // 注意此时不需要reload
            subView.scrollView.tableHeaderView = newView;
        }
    }];
}

#pragma mark - Private

- (void)stopScrollFinallyWithScrollView:(UIScrollView *)scrollView {
    
    if (self.tabSwitchSnapShotView.superview) {
        [self.tabSwitchSnapShotView removeFromSuperview];
        self.tabSwitchSnapShotView = nil;
    }
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = offsetX / scrollView.width;
    self.currentShowIndex = index;
    self.tabSwitchView.currentSelectIndex = index;
    self.upInfomationView.top = 0;
    if (self.upInfomationView.superview) {
        [self.upInfomationView removeFromSuperview];
    }
    if (self.tabSwitchView.superview) {
        [self.tabSwitchView removeFromSuperview];
    }
    UIView *oneHeaderView = [self.sectionHeaderViewArray objectAtIndex:index];
    [oneHeaderView addSubview:self.tabSwitchView];
    [self.currentInfoView.scrollView.tableHeaderView addSubview:self.upInfomationView];
}

#pragma mark - Set & Get

// 并不是为了提高效率，而是为了结构清晰
- (NSMutableArray *)sectionHeaderViewArray {
    if (!_sectionHeaderViewArray) {
        NSMutableArray *sectionHeaderViewArray = [NSMutableArray array];
        UIView *sectionHeaderView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTabSwitchViewHeight)];
        UIView *sectionHeaderView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTabSwitchViewHeight)];
        UIView *sectionHeaderView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTabSwitchViewHeight)];
        [sectionHeaderViewArray addObject:sectionHeaderView0];
        [sectionHeaderViewArray addObject:sectionHeaderView1];
        [sectionHeaderViewArray addObject:sectionHeaderView2];
        _sectionHeaderViewArray = sectionHeaderViewArray;
    }
    return _sectionHeaderViewArray;
}

- (NSArray *)tabTitlesArray {
    if (!_tabTitlesArray) {
        _tabTitlesArray = @[@"详情",@"规格尺码",@"热卖推荐"];
    }
    return _tabTitlesArray;
}

- (void)setCurrentShowIndex:(NSInteger)currentShowIndex {
    if (_currentShowIndex == currentShowIndex) return;
    _currentShowIndex = currentShowIndex;
    __block UIView <GDDownInfomationViewProtocol>*subView = nil;
    [self.fullScrollView.subviews enumerateObjectsUsingBlock:^(UIView <GDDownInfomationViewProtocol>*oneSubView, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([oneSubView conformsToProtocol:@protocol(GDDownInfomationViewProtocol)] && oneSubView.tag == currentShowIndex) {
            subView = oneSubView;
        }
    }];
    self.currentInfoView = subView;
}

// 外界使用时需要改变top值；同一时间只能有一个superview添加此view
- (GDUpGeneralInfomationView *)upInfomationView {
    if (!_upInfomationView) {
        _upInfomationView = [[GDUpGeneralInfomationView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kNavigationBarHeight - kBottomBarHeight)];
        _upInfomationView.delegate = self;
        _upInfomationView.backgroundColor = [UIColor cyanColor];
        [_upInfomationView bindDataSource];
    }
    return _upInfomationView;
}

// tab切换view
- (GDMiddleTabSwitchView *)tabSwitchView {
    if (!_tabSwitchView) {
        _tabSwitchView = [[GDMiddleTabSwitchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTabSwitchViewHeight)];
        _tabSwitchView.backgroundColor = [UIColor redColor];
        _tabSwitchView.delegate = self;
        [_tabSwitchView getDataSourceTitlesArray:self.tabTitlesArray];
    }
    return _tabSwitchView;
}

// 这样的目的是不用频繁改变tabview的位置，模拟器运行时可能会是白条
// 通过reveal可知返回的是UIReplicantContentView类型view
- (UIView *)tabSwitchSnapShotView {
    if (!_tabSwitchSnapShotView) {
        _tabSwitchSnapShotView = [self.tabSwitchView snapshotViewAfterScreenUpdates:NO];
        _tabSwitchSnapShotView.origin = [self.tabSwitchView convertPoint:self.tabSwitchView.frame.origin toView:self.view];
    }
    return _tabSwitchSnapShotView;
}

@end

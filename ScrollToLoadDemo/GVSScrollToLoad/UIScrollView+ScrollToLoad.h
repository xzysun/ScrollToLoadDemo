//
//  UIScrollView+ScrollToLoad.h
//  ScrollToLoadDemo
//
//  Created by xzysun on 15/3/19.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  在UIScrollView上增加上拉加载更多的控件
 */
@interface UIScrollView (ScrollToLoad)

#pragma mark - 添加/删除控件
/**
 *  添加一个加载更多的Footer
 *
 *  @param callback 触发的回调
 */
-(void)addLoadMoreFooterWithCallback:(void(^)())callback;

/**
 *  添加一个加载更多的Footer
 *
 *  @param target 触发回调的target
 *  @param action 触发回调的action
 */
-(void)addLoadMoreFooterWithTarget:(id)target Action:(SEL)action;

/**
 *  移除一个加载更多的Footer
 */
-(void)removeLoadMoreFooter;

#pragma mark - 控制控件的功能
/**
 *  触发加载更多的读取状态
 */
-(void)loadMoreFooterBeginLoading;

/**
 *  结束加载更多的读取状态
 */
-(void)loadMoreFooterEndLoading;

/**
 *  控制是否允许触发加载更多，如果不允许，则点击无效果且显示loadMoreFooterDisabledText
 */
@property (nonatomic, assign) BOOL loadMoreFooterEnabled;

/**
 *  上拉刷新头部控件的可见性
 */
@property (nonatomic, assign) BOOL loadMoreFooterHidden;

/**
 *  上拉刷新的触发距离，即触发的时候距控件的高度，默认为0
 */
@property (nonatomic, assign) CGFloat loadMoreFooterTriggerHeight;

#pragma mark - 定义控件的显示
/**
 *  普通状态下的文本
 */
@property (nonatomic, copy) NSString *loadMoreFooterNormalText;
/**
 *  加载状态下的文本
 */
@property (nonatomic, copy) NSString *loadMoreFooterLoadingText;
/**
 *  禁止状态下的文本
 */
@property (nonatomic, copy) NSString *loadMoreFooterDisabledText;
/**
 *  文本的颜色，包括菊花的颜色也受这个控制，默认969696
 */
@property (nonatomic, copy) UIColor *loadMoreFooterTextColor;
/**
 *  文本的字体，默认为13.0
 */
@property (nonatomic, copy) UIFont *loadMoreFooterTextFont;
/**
 *  背景的颜色，默认透明
 */
@property (copy, nonatomic) UIColor  *loadMoreFooterBackgroundColor;
@end

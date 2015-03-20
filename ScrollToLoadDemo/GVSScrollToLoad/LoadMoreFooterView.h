//
//  LoadMoreFooterView.h
//  ScrollToLoadDemo
//
//  Created by xzysun on 15/3/19.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 控件的刷新状态
typedef enum {
    LoadMoreStateNormal = 1, // 普通状态
    LoadMoreStateLoading = 2, // 正在读取中的状态
    LoadMoreStateWillLoad = 3
} LoadMoreFooterState;

@interface LoadMoreFooterView : UIView

#pragma mark - 父控件
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;
#pragma mark - 内部的控件
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityView;

#pragma mark - 回调
/**
 *  开始进入读取状态的监听器
 */
@property (weak, nonatomic) id beginLoadingTaget;
/**
 *  开始进入读取状态的监听方法
 */
@property (assign, nonatomic) SEL beginLoadingAction;
/**
 *  开始进入读取状态就会调用
 */
@property (nonatomic, copy) void (^beginLoadingCallback)();
#pragma mark - 刷新相关
/**
 *  是否正在读取
 */
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
/**
 *  是否允许触发
 */
@property (nonatomic, assign) BOOL enabled;
/**
 *  触发时候距离显示出控件的高度，默认是0，也就是显示出控件的瞬间触发
 */
@property (nonatomic, assign) CGFloat triggerHeight;
/**
 *  开始读取
 */
- (void)beginLoading;
/**
 *  结束读取
 */
- (void)endLoading;
#pragma mark -
@property (assign, nonatomic) LoadMoreFooterState state;
/**
 *  正常状态下的文字
 */
@property (copy, nonatomic) NSString *normalText;
/**
 *  读取状态下的文字
 */
@property (copy, nonatomic) NSString *loadingText;
/**
 *  停用状态下的文字
 */
@property (copy, nonatomic) NSString *disabledText;
/**
 *  颜色
 */
@property (copy, nonatomic) UIColor *textColor;
@end

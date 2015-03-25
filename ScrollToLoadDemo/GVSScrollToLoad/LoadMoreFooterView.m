//
//  LoadMoreFooterView.m
//  ScrollToLoadDemo
//
//  Created by xzysun on 15/3/19.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "LoadMoreFooterView.h"
#import <objc/message.h>

// objc_msgSend
#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define msgTarget(target) (__bridge void *)(target)
#define LoadMoreLabelDefaultTextColor [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]
#define LoadMoreLabelDefaultTextFont [UIFont boldSystemFontOfSize:13.0]
static CGFloat const kLoadMoreViewHeight = 64.0;
static NSString *const kLoadMoreContentOffset = @"contentOffset";
static NSString *const kLoadMoreContentSize = @"contentSize";
static NSString *const kLoadMoreContentInset = @"contentInset";
static NSString *const kLoadMoreDefaultLoadingText = @"正在加载更多...";
static NSString *const kLoadMoreDefaultNormalText = @"点击以加载更多";
static NSString *const kLoadMoreDefaultDisableText = @"没有更多数据了";

@interface LoadMoreFooterView ()

@property (nonatomic, weak) UILabel *statusLabel;
@property (nonatomic, weak) UIActivityIndicatorView *activityView;

@property (nonatomic, assign) BOOL buttonMode;
@end

@implementation LoadMoreFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.height = kLoadMoreViewHeight;
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        //初始化控件
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.font = LoadMoreLabelDefaultTextFont;
        statusLabel.textColor = LoadMoreLabelDefaultTextColor;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel = statusLabel;
        [self addSubview:_statusLabel];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_activityView = activityView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFooterViewGesture:)];
        [self addGestureRecognizer:tapGesture];
        self.enabled = YES;
        self.buttonMode = NO;
        self.triggerHeight = 0.0;
        self.loadingText = kLoadMoreDefaultLoadingText;
        self.normalText = kLoadMoreDefaultNormalText;
        self.disabledText = kLoadMoreDefaultDisableText;
        self.textColor = LoadMoreLabelDefaultTextColor;
        self.state = LoadMoreStateNormal;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //调整控件位置
    CGFloat activityX = CGRectGetWidth(self.frame) * 0.5 - 100;
    self.activityView.center = CGPointMake(activityX, CGRectGetHeight(self.frame)/2.0);
    self.statusLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), kLoadMoreViewHeight);
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    //移入新的视图中
    [self.superview removeObserver:self forKeyPath:kLoadMoreContentOffset context:nil];
    [self.superview removeObserver:self forKeyPath:kLoadMoreContentSize context:nil];
    [self.superview removeObserver:self forKeyPath:kLoadMoreContentInset context:nil];
    if (newSuperview) {
        [newSuperview addObserver:self forKeyPath:kLoadMoreContentOffset options:NSKeyValueObservingOptionNew context:nil];
        [newSuperview addObserver:self forKeyPath:kLoadMoreContentSize options:NSKeyValueObservingOptionNew context:nil];
        [newSuperview addObserver:self forKeyPath:kLoadMoreContentInset options:NSKeyValueObservingOptionNew context:nil];
        //调整位置
        CGRect frame = self.frame;
        frame.origin.x = 0;
        frame.size.width = CGRectGetWidth(newSuperview.frame);
        self.frame = frame;
        //记录父视图
        _scrollView = (UIScrollView *)newSuperview;
        _scrollViewOriginalInset = _scrollView.contentInset;
        //调整frame
        [self adjustFrameWithContentSize];
    }
}
- (void)drawRect:(CGRect)rect
{
    if (self.state == LoadMoreStateWillLoad) {
        self.state = LoadMoreStateLoading;
    }
}

#pragma mark 监听UIScrollView的属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    // 不能跟用户交互，直接返回
//    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) {
//        return;
//    }
    if ([kLoadMoreContentInset isEqualToString:keyPath]) {
        //ContentInsets发生了变化，可能需要调整frame
        _scrollViewOriginalInset = _scrollView.contentInset;
        [self adjustFrameWithContentSize];
    } else if ([kLoadMoreContentSize isEqualToString:keyPath]) {
        // 调整frame
        [self adjustFrameWithContentSize];
    } else if ([kLoadMoreContentOffset isEqualToString:keyPath]) {
        //不是用户操作触发的
        if (!_scrollView.dragging) {
            return;
        }
        // 如果正在刷新，直接返回
        if (self.state == LoadMoreStateLoading) {
            return;
        }
        if (!self.enabled) {
            //禁用模式，不再监控高度
            return;
        }
        if (self.buttonMode) {
            //按钮模式，不再监控高度
            return;
        }
        // 调整状态
        [self adjustStateWithContentOffset];
    }
}

#pragma mark - 根据ScrollView调整
- (void)adjustFrameWithContentSize
{
    // 内容的高度
    CGFloat contentHeight = self.scrollView.contentSize.height;
    // 表格的高度
    CGFloat scrollHeight = CGRectGetHeight(self.scrollView.frame) - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
    if (contentHeight <= scrollHeight) {
        self.buttonMode = YES;
    } else {
        self.buttonMode = NO;
    }
    if (CGRectGetMaxY(self.frame) == contentHeight) {
        //在内容分的最底下，不用调整了
        return;
    }
    // 调整位置
    CGRect frame = self.frame;
    frame.origin.y = contentHeight;
    self.frame = frame;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), contentHeight+CGRectGetHeight(self.frame));
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.contentOffset.y;
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
//     //如果是向下滚动到看不见尾部控件，直接返回
//    if (currentOffsetY <= happenOffsetY) return;
    //触发点
    CGFloat normal2loadingOffsetY = happenOffsetY - self.triggerHeight;
    if (self.state == LoadMoreStateNormal && currentOffsetY > normal2loadingOffsetY) {
        //触发读取
        self.state = LoadMoreStateLoading;
    }
}

/**
 *  刚好看到上拉刷新控件时的contentOffset.y
 */
- (CGFloat)happenOffsetY
{
    
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    CGFloat deltaH =  self.scrollView.contentSize.height - h;
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top - CGRectGetHeight(self.frame);
    } else {
        return - self.scrollViewOriginalInset.top - CGRectGetHeight(self.frame);
    }
}

#pragma mark - 是否正在刷新
- (BOOL)isRefreshing
{
    return LoadMoreStateLoading == self.state;
}

-(void)tapFooterViewGesture:(UIGestureRecognizer *)gesture
{
    if (self.state == LoadMoreStateNormal) {
        [self beginLoading];
    }
}

-(void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.userInteractionEnabled = enabled;
    [self endLoading];
    [self settingLabelText];
}

#pragma mark - 开始加载
- (void)beginLoading
{
    if (self.state == LoadMoreStateLoading) {
        // 回调
        if ([self.beginLoadingTaget respondsToSelector:self.beginLoadingAction]) {
            msgSend(msgTarget(self.beginLoadingTaget), self.beginLoadingAction, self);
        }
        
        if (self.beginLoadingCallback) {
            self.beginLoadingCallback();
        }
    } else {
        if (self.window) {
            self.state = LoadMoreStateLoading;
        } else {
            //当前视图并不是在最前面的情况
            _state = LoadMoreStateWillLoad;
            // 为了保证在viewWillAppear等方法中也能刷新
            [self setNeedsDisplay];
        }
    }
}

#pragma mark - 结束加载
- (void)endLoading
{
    self.state = LoadMoreStateNormal;
}

#pragma mark - 设置状态
-(void)setState:(LoadMoreFooterState)state
{
    // 0.存储当前的contentInset
    if (self.state != LoadMoreStateLoading) {
        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
    // 1.一样的就直接返回
    if (self.state == state) return;
    // 2.旧状态
    LoadMoreFooterState oldState = self.state;
    // 3.存储状态
    _state = state;
    // 4.根据状态执行不同的操作
    switch (state) {
        case LoadMoreStateNormal: // 普通状态
        {
            if (oldState == LoadMoreStateLoading) {//从loading状态变成normal状态
                [UIView animateWithDuration:0.2 animations:^{
                    self.activityView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    // 停止转圈圈
                    [self.activityView stopAnimating];
                    // 恢复alpha
                    self.activityView.alpha = 1.0;
                }];
                [self settingLabelText];
                // 直接返回
                return;
            } else {
                // 停止转圈圈
                [self.activityView stopAnimating];
            }
            break;
        }
        case LoadMoreStateLoading:
        {
            // 开始转圈圈
            [self.activityView startAnimating];
            // 回调
            if ([self.beginLoadingTaget respondsToSelector:self.beginLoadingAction]) {
                msgSend(msgTarget(self.beginLoadingTaget), self.beginLoadingAction, self);
            }
            if (self.beginLoadingCallback) {
                self.beginLoadingCallback();
            }
            break;
        }
        default:
            break;
    }
    // 5.设置文字
    [self settingLabelText];
}

#pragma mark - 设置文本与颜色
-(void)settingLabelText
{
    if (!self.enabled) {
        self.statusLabel.text = self.disabledText;
        return;
    }
    switch (self.state) {
        case LoadMoreStateNormal:
            self.statusLabel.text = self.normalText;
            break;
        case LoadMoreStateLoading:
            self.statusLabel.text = self.loadingText;
            break;
        default:
            break;
    }
}

-(void)setNormalText:(NSString *)normalText
{
    _normalText = [normalText copy];
    [self settingLabelText];
}

-(void)setLoadingText:(NSString *)loadingText
{
    _loadingText = [loadingText copy];
    [self settingLabelText];
}

-(void)setDisabledText:(NSString *)disabledText
{
    _disabledText = [disabledText copy];
    [self settingLabelText];
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = [textColor copy];
    self.statusLabel.textColor = textColor;
    self.activityView.color = textColor;
}

-(void)setTextFont:(UIFont *)textFont
{
    _textFont = [textFont copy];
    self.statusLabel.font = textFont;
}
@end

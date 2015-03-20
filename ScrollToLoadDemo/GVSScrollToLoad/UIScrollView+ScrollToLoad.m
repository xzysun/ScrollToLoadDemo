//
//  UIScrollView+ScrollToLoad.m
//  ScrollToLoadDemo
//
//  Created by xzysun on 15/3/19.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "UIScrollView+ScrollToLoad.h"
#import "LoadMoreFooterView.h"
#import <objc/runtime.h>

@interface UIScrollView ()

@property (nonatomic, weak) LoadMoreFooterView *loadMoreFooter;
@end

@implementation UIScrollView (ScrollToLoad)

#pragma mark - 运行时相关
static char ScrollToLoadFooterViewKey;

-(void)setLoadMoreFooter:(LoadMoreFooterView *)loadMoreFooter
{
    [self willChangeValueForKey:@"ScrollToLoadFooterViewKey"];
    objc_setAssociatedObject(self, &ScrollToLoadFooterViewKey, loadMoreFooter, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"ScrollToLoadFooterViewKey"];
}

-(LoadMoreFooterView *)loadMoreFooter
{
    return objc_getAssociatedObject(self, &ScrollToLoadFooterViewKey);
}

#pragma mark - 添加/删除视图
-(void)addLoadMoreFooterWithCallback:(void(^)())callback
{
    if (!self.loadMoreFooter) {
        LoadMoreFooterView *footerView = [[LoadMoreFooterView alloc] initWithFrame:CGRectZero];
        [self addSubview:footerView];
        self.loadMoreFooter = footerView;
    }
    self.loadMoreFooter.beginLoadingCallback = callback;
}

-(void)addLoadMoreFooterWithTarget:(id)target Action:(SEL)action
{
    if (!self.loadMoreFooter) {
        LoadMoreFooterView *footerView = [[LoadMoreFooterView alloc] initWithFrame:CGRectZero];
        [self addSubview:footerView];
        self.loadMoreFooter = footerView;
    }
    self.loadMoreFooter.beginLoadingTaget = target;
    self.loadMoreFooter.beginLoadingAction = action;
}

-(void)removeLoadMoreFooter
{
    [self.loadMoreFooter removeFromSuperview];
    self.loadMoreFooter = nil;
}

#pragma mark - 控制视图
-(void)loadMoreFooterBeginLoading
{
    [self.loadMoreFooter beginLoading];
}

-(void)loadMoreFooterEndLoading
{
    [self.loadMoreFooter endLoading];
}

-(void)setLoadMoreFooterEnabled:(BOOL)enabled
{
    self.loadMoreFooter.enabled = enabled;
}

-(BOOL)loadMoreFooterEnabled
{
    return self.loadMoreFooter.enabled;
}

-(void)setLoadMoreFooterHidden:(BOOL)loadMoreFooterHidden
{
    self.loadMoreFooter.hidden = loadMoreFooterHidden;
}

-(BOOL)loadMoreFooterHidden
{
    return self.loadMoreFooter.hidden;
}

-(CGFloat)loadMoreFooterTriggerHeight
{
    return self.loadMoreFooter.triggerHeight;
}

-(void)setLoadMoreFooterTriggerHeight:(CGFloat)loadMoreFooterTriggerHeight
{
    self.loadMoreFooter.triggerHeight = loadMoreFooterTriggerHeight;
}

#pragma mark - 定义视图效果
-(NSString *)loadMoreFooterNormalText
{
    return self.loadMoreFooter.normalText;
}

-(void)setLoadMoreFooterNormalText:(NSString *)normalText
{
    self.loadMoreFooter.normalText = normalText;
}

-(NSString *)loadMoreFooterLoadingText
{
    return self.loadMoreFooter.loadingText;
}

-(void)setLoadMoreFooterLoadingText:(NSString *)loadingText
{
    self.loadMoreFooter.loadingText = loadingText;
}

-(NSString *)loadMoreFooterDisabledText
{
    return self.loadMoreFooter.disabledText;
}

-(void)setLoadMoreFooterDisabledText:(NSString *)disabledText
{
    self.loadMoreFooter.disabledText = disabledText;
}

-(UIColor *)loadMoreFooterTextColor
{
    return self.loadMoreFooter.textColor;
}

-(void)setLoadMoreFooterTextColor:(UIColor *)textColor
{
    self.loadMoreFooter.textColor = textColor;
}

-(UIColor *)loadMoreFooterBackgroundColor
{
    return self.loadMoreFooter.backgroundColor;
}

-(void)setLoadMoreFooterBackgroundColor:(UIColor *)loadMoreFooterBackgroundColor
{
    self.loadMoreFooter.backgroundColor = loadMoreFooterBackgroundColor;
}
@end

//
//  JFScrollPageSegmentView.m
//  JFScrollPageViewDemo
//
//  Created by Japho on 2018/9/27.
//  Copyright © 2018年 Japho. All rights reserved.
//

#import "JFScrollPageSegmentView.h"

@interface JFScrollPageSegmentView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation JFScrollPageSegmentView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)arrTitles delegate:(id<JFScrollPageSegmentViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeConfig];
        self.arrTitles = arrTitles;
        self.delegate = delegate;
    }
    
    return self;
}

- (void)initializeConfig
{
    self.itemMargin = 15;
    self.selectIndex = 0;
    self.colorTitleNormal = [UIColor whiteColor];
    self.colorTitleSelected = [UIColor whiteColor];
    self.fontTitle = [UIFont systemFontOfSize:14];
    self.fontSelectedTitle = self.fontTitle;
    self.colorIndicator = self.colorTitleSelected;
    self.indicatorExtension = 5.f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    if (self.arrBtnItems.count == 0)
    {
        return;
    }
    
    CGFloat totalButtonWidth = 0.0;
    UIFont *titleFont = _fontTitle;
    
    if (_fontTitle != _fontSelectedTitle)
    {
        for (int i = 0; i < self.arrTitles.count; i++)
        {
            UIButton *btn = self.arrBtnItems[i];
            titleFont = btn.selected ? _fontSelectedTitle : _fontTitle;
            CGFloat itemBtnWidth = [JFScrollPageSegmentView getWidthWithString:self.arrTitles[i] font:titleFont] + self.itemMargin;
            totalButtonWidth += itemBtnWidth;
        }
    }
    else
    {
        for (NSString *title in self.arrTitles)
        {
            CGFloat itemButtonWidth = [JFScrollPageSegmentView getWidthWithString:title font:titleFont] + self.itemMargin;
            totalButtonWidth += itemButtonWidth;
        }
    }
    
    if (totalButtonWidth <= CGRectGetWidth(self.bounds))
    {
        //不能滑动
        CGFloat itemWidth = CGRectGetWidth(self.bounds) / self.arrBtnItems.count;
        CGFloat itemHeight = CGRectGetHeight(self.bounds);
        [self.arrBtnItems enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.frame = CGRectMake(idx * itemWidth, 0, itemWidth, itemHeight);
        }];
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.scrollView.bounds));
    }
    else
    {
        //可以滑动
        CGFloat currentX = 0;
        for (int idx = 0; idx < self.arrTitles.count; idx++)
        {
            UIButton *btn = self.arrBtnItems[idx];
            titleFont = btn.isSelected ? _fontSelectedTitle : _fontTitle;
            CGFloat itemWidth = [JFScrollPageSegmentView getWidthWithString:self.arrTitles[idx] font:titleFont] + self.itemMargin;
            CGFloat itemHeight = CGRectGetHeight(self.bounds);
            btn.frame = CGRectMake(currentX, 0, itemWidth, itemHeight);
            currentX += itemWidth;
        }
        
        self.scrollView.contentSize = CGSizeMake(currentX, CGRectGetHeight(self.scrollView.bounds));
    }
    
    BOOL animated = self.indicatorView.frame.origin.y == 0 ? NO : YES;
    
    [self moveIndicatorViewWithAnimated:animated];
}

- (void)moveIndicatorViewWithAnimated:(BOOL)animated
{
    UIFont *titleFont = _fontTitle;
    UIButton *selectedBtn = self.arrBtnItems[self.selectIndex];
    titleFont = selectedBtn.isSelected ? _fontSelectedTitle : _fontTitle;
    CGFloat indictorWidth = [JFScrollPageSegmentView getWidthWithString:self.arrTitles[self.selectIndex] font:titleFont];
    
    [UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
        
        self.indicatorView.center = CGPointMake(selectedBtn.center.x, CGRectGetHeight(self.scrollView.bounds) - 8);
        self.indicatorView.bounds = CGRectMake(0, 0, indictorWidth, 2);
        
    } completion:^(BOOL finished) {
        
        [self scrollSelectBtnCenterWithAnimated:animated];
        
    }];
}

//滚动
- (void)scrollSelectBtnCenterWithAnimated:(BOOL)animated
{
    UIButton *btnSelected = self.arrBtnItems[self.selectIndex];
    CGRect centerRect = CGRectMake(btnSelected.center.x - CGRectGetWidth(self.scrollView.bounds)/2, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    [self.scrollView scrollRectToVisible:centerRect animated:animated];
}

#pragma mark - --- Private Methods ---

+ (CGFloat)getWidthWithString:(NSString *)string font:(UIFont *)font
{
    NSDictionary *attr = @{NSFontAttributeName : font};
    
    return [string boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size.width;
}

#pragma mark - --- Actions ---

- (void)buttonAction:(UIButton *)button
{
    NSInteger index = button.tag - 100;
    
    if (index == self.selectIndex)
    {
        return;
    }
    
    if (index == self.arrTitles.count - 1)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentViewLastSegmentDidSelect:)])
        {
            [self.delegate segmentViewLastSegmentDidSelect:self];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:scrollAtStartIndex:endIndex:)])
    {
        [self.delegate segmentView:self scrollAtStartIndex:self.selectIndex endIndex:index];
    }
    
    self.selectIndex = index;
}

#pragma mark - --- UIScrollView Delegate ---

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentViewWillBeginDragging:)])
    {
        [self.delegate segmentViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentViewWillEndDragging:)])
    {
        [self.delegate segmentViewWillEndDragging:self];
    }
}

#pragma mark - --- Setter && Getter ---

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = YES;
        _scrollView.delegate = self;
        
        [self addSubview:_scrollView];
    }
    
    return _scrollView;
}

- (NSMutableArray<UIButton *> *)arrBtnItems
{
    if (!_arrBtnItems)
    {
        _arrBtnItems = [[NSMutableArray alloc] init];
    }
    
    return _arrBtnItems;
}

- (UIView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIView alloc] init];
        
        [self.scrollView addSubview:_indicatorView];
    }
    
    return _indicatorView;
}

- (void)setArrTitles:(NSArray *)arrTitles
{
    _arrTitles = arrTitles;
    
    [self.arrBtnItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.arrBtnItems removeAllObjects];
    
    for (NSString *title in arrTitles)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = self.arrBtnItems.count + 100;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:_colorTitleNormal forState:UIControlStateNormal];
        [button setTitleColor:_colorTitleSelected forState:UIControlStateSelected];
        [button.titleLabel setFont:_fontTitle];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        
        if (self.arrTitles.count == self.selectIndex)
        {
            button.selected = YES;
        }
        [self.arrBtnItems addObject:button];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}

- (void)setItemMargin:(CGFloat)itemMargin
{
    _itemMargin = itemMargin;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    [self setSelectIndex:selectIndex withAnimated:YES];
}

- (void)setSelectIndex:(NSInteger)selectIndex withAnimated:(BOOL)animated
{
    if (_selectIndex == selectIndex || selectIndex < 0 || selectIndex > self.arrBtnItems.count - 1)
    {
        return;
    }
    
    UIButton *lastBtn = [self.scrollView viewWithTag:_selectIndex + 100];
    lastBtn.selected = NO;
    lastBtn.titleLabel.font = _fontTitle;
    _selectIndex = selectIndex;
    
    UIButton *currentBtn = [self.scrollView viewWithTag:_selectIndex + 100];
    currentBtn.selected = YES;
    currentBtn.titleLabel.font = _fontSelectedTitle;
    
    [self moveIndicatorViewWithAnimated:animated];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setFontTitle:(UIFont *)fontTitle
{
    _fontTitle = fontTitle;
    for (UIButton *btn in self.arrBtnItems)
    {
        btn.titleLabel.font = fontTitle;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setFontSelectedTitle:(UIFont *)fontSelectedTitle
{
    if (_fontTitle == _fontSelectedTitle)
    {
        _fontSelectedTitle = _fontTitle;
        return;
    }
    
    _fontSelectedTitle = fontSelectedTitle;
    
    for (UIButton *btn in self.arrBtnItems)
    {
        btn.titleLabel.font = btn.selected? fontSelectedTitle : _fontTitle;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setColorTitleNormal:(UIColor *)colorTitleNormal
{
    _colorTitleNormal = colorTitleNormal;
    
    for (UIButton *btn in self.arrBtnItems)
    {
        [btn setTitleColor:colorTitleNormal forState:UIControlStateNormal];
    }
}

- (void)setColorTitleSelected:(UIColor *)colorTitleSelected
{
    _colorTitleSelected = colorTitleSelected;
    
    for (UIButton *btn in self.arrBtnItems)
    {
        [btn setTitleColor:colorTitleSelected forState:UIControlStateSelected];
    }
}

- (void)setColorIndicator:(UIColor *)colorIndicator
{
    _colorIndicator = colorIndicator;
    self.indicatorView.backgroundColor = colorIndicator;
}

- (void)setIndicatorExtension:(CGFloat)indicatorExtension
{
    _indicatorExtension = indicatorExtension;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end

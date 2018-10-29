//
//  JFScrollPageContentView.m
//  JFScrollPageViewDemo
//
//  Created by Japho on 2018/9/27.
//  Copyright © 2018年 Japho. All rights reserved.
//

#import "JFScrollPageContentView.h"

NSString * const scrollPageViewCollectionViewID = @"scrollPageViewCollectionViewID";

@interface JFScrollPageContentView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, strong) NSArray *childVCs;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat startOffsetX;
@property (nonatomic, assign) BOOL isSelectedBtn;   //是否滑动

@end

@implementation JFScrollPageContentView

- (instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentVC:(UIViewController *)parentVC delegate:(id<JFScrollPageContentViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.parentVC = parentVC;
        self.childVCs = childVCs;
        self.delegate = delegate;
        
        [self setupSubViews];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setupSubViews
{
    _startOffsetX = 0;
    _isSelectedBtn = NO;
    _contentViewCanScroll = YES;
    
    for (UIViewController *vc in self.childVCs)
    {
        [self.parentVC addChildViewController:vc];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - --- UICollectionView Delegate ---

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childVCs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:scrollPageViewCollectionViewID forIndexPath:indexPath];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        UIViewController *childVC = self.childVCs[indexPath.item];
        childVC.view.frame = cell.contentView.bounds;
        [cell.contentView addSubview:childVC.view];
    }
    
    return cell;
}

#ifdef __IPHONE_8_0

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIViewController *childVC = self.childVCs[indexPath.item];
    childVC.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:childVC.view];
}

#endif

#pragma mark - --- UIScrollView Delegate ---

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isSelectedBtn = NO;
    _startOffsetX = scrollView.contentOffset.x;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewWillBeginDragging:)])
    {
        [self.delegate contentViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isSelectedBtn)
    {
        return;
    }
    
    CGFloat scrollViewWidth = scrollView.bounds.size.width;
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    NSInteger startIndex =floor(_startOffsetX / scrollViewWidth);
    NSInteger endIndex;
    CGFloat progress;
    
    if (currentOffsetX > _startOffsetX)
    {
        //左滑
        progress = (currentOffsetX - _startOffsetX) / scrollViewWidth;
        endIndex = startIndex + 1;
        if (endIndex > self.childVCs.count - 1)
        {
            endIndex = self.childVCs.count - 1;
        }
    }
    else if (currentOffsetX == _startOffsetX)
    {
        //未滑动
        progress = 0;
        endIndex = startIndex;
    }
    else
    {
        //右滑
        progress = (_startOffsetX - currentOffsetX) / scrollViewWidth;
        endIndex = startIndex - 1;
        endIndex = endIndex < 0 ? 0 : endIndex;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contetnViewDidScroll:startIndex:endIndex:progress:)])
    {
        [self.delegate contetnViewDidScroll:self startIndex:startIndex endIndex:endIndex progress:progress];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat scrollViewWidth = scrollView.bounds.size.width;
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    NSInteger startIndex =floor(_startOffsetX / scrollViewWidth);
    NSInteger endIndex = floor(currentOffsetX / scrollViewWidth);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewDidEndDecelerating:startIndex:endIndex:)])
    {
        [self.delegate contentViewDidEndDecelerating:self startIndex:startIndex endIndex:endIndex];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contentViewDidEndDragging:)])
        {
            [self.delegate contentViewDidEndDragging:self];
        }
    }
}

#pragma mark - --- Setter && Getter ---

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = self.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.bounces = NO;
        collectionView.pagingEnabled = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;

        if (@available(iOS 11.0, *))
        {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:scrollPageViewCollectionViewID];
        
        [self addSubview:collectionView];        
        
        _collectionView = collectionView;
    }
    
    return _collectionView;
}

- (void)setContentViewCurrentIndex:(NSInteger)contentViewCurrentIndex
{
    if (contentViewCurrentIndex < 0 || contentViewCurrentIndex > self.childVCs.count)
    {
        return;
    }
    
    _isSelectedBtn = YES;
    _contentViewCurrentIndex = contentViewCurrentIndex;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:contentViewCurrentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)setContentViewCanScroll:(BOOL)contentViewCanScroll
{
    _contentViewCanScroll = contentViewCanScroll;
    _collectionView.scrollEnabled = contentViewCanScroll;
}

@end

//
//  JFScrollPageContentView.h
//  JFScrollPageViewDemo
//
//  Created by Japho on 2018/9/27.
//  Copyright © 2018年 Japho. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JFScrollPageContentView;

@protocol JFScrollPageContentViewDelegate <NSObject>

@optional


/**
 滑动时调用

 @param contentView 内容视图
 @param startIndex 开始索引
 @param endIndex 结束索引
 @param progress 进度
 */
- (void)contetnViewDidScroll:(JFScrollPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex progress:(CGFloat)progress;


/**
 结束滑动时调用

 @param contentView 内容视图
 @param startIndex 开始缩阴
 @param endIndex 结束索引
 */
- (void)contentViewDidEndDecelerating:(JFScrollPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;


/**
 开始滑动

 @param contentView 内容视图
 */
- (void)contentViewWillBeginDragging:(JFScrollPageContentView *)contentView;


/**
 结束滑动

 @param contentView 内筒视图
 */
- (void)contentViewDidEndDragging:(JFScrollPageContentView *)contentView;

@end

@interface JFScrollPageContentView : UIView

@property (nonatomic, weak) id<JFScrollPageContentViewDelegate> delegate;
@property (nonatomic, assign) NSInteger contentViewCurrentIndex;    //当前显示索引
@property (nonatomic, assign) BOOL contentViewCanScroll;    //能否左右滑动，默认YES


/**
 类的初始化方法

 @param frame frame
 @param childVCs 子控制器
 @param parentVC 父控制器
 @param delegate 代理
 @return 返回内容视图
 */
- (instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentVC:(UIViewController *)parentVC delegate:(id<JFScrollPageContentViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END

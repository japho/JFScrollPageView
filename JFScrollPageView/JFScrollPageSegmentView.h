//
//  JFScrollPageSegmentView.h
//  JFScrollPageViewDemo
//
//  Created by Japho on 2018/9/27.
//  Copyright © 2018年 Japho. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JFScrollPageSegmentView;

@protocol JFScrollPageSegmentViewDelegate <NSObject>

@optional

/**
 切换segment回调

 @param segmentView segmentView
 @param startIndex 切换前索引
 @param endIndex 切换后索引
 */
- (void)segmentView:(JFScrollPageSegmentView *)segmentView scrollAtStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;


/**
 将要开始滑动

 @param segmentView segmentView
 */
- (void)segmentViewWillBeginDragging:(JFScrollPageSegmentView *)segmentView;


/**
 将要停止滑动

 @param segmentView segemntView
 */
- (void)segmentViewWillEndDragging:(JFScrollPageSegmentView *)segmentView;


/**
 最后一个被选中

 @param segmentView segmentView
 */
- (void)segmentViewLastSegmentDidSelect:(JFScrollPageSegmentView *)segmentView;

@end

@interface JFScrollPageSegmentView : UIView

@property (nonatomic, weak) id<JFScrollPageSegmentViewDelegate> delegate;

@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, assign) CGFloat itemMargin;   //标题间距
@property (nonatomic, assign) NSInteger selectIndex;    //选中索引
@property (nonatomic, strong) UIFont *fontTitle;    //字体
@property (nonatomic, strong) UIFont *fontSelectedTitle;   //选中字体
@property (nonatomic, strong) UIColor *colorTitleNormal;    //标题颜色
@property (nonatomic, strong) UIColor *colorTitleSelected;  //标题选中颜色
@property (nonatomic, strong) UIColor *colorIndicator;  //下划线颜色
@property (nonatomic, assign) CGFloat indicatorExtension;
@property (nonatomic, strong) NSMutableArray<UIButton *> *arrBtnItems;
@property (nonatomic, copy) NSArray *arrTitles;

/**
 初始化segmentView

 @param frame frame
 @param arrTitles 标题数组
 @param delegate 代理
 @return segmentView
 */
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)arrTitles delegate:(id<JFScrollPageSegmentViewDelegate>)delegate;


/**
 设置选中index

 @param selectIndex 选中索引
 @param animated 是否动画
 */
- (void)setSelectIndex:(NSInteger)selectIndex withAnimated:(BOOL)animated;

+ (CGFloat)getWidthWithString:(NSString *)string font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END

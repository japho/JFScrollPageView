//
//  ViewController.m
//  JFScrollPageViewDemo
//
//  Created by Japho on 2018/9/27.
//  Copyright © 2018年 Japho. All rights reserved.
//

#import "ViewController.h"
#import "ChildViewController.h"
#import "JFScrollPageSegmentView.h"
#import "JFScrollPageContentView.h"

@interface ViewController () <JFScrollPageContentViewDelegate,JFScrollPageSegmentViewDelegate>

@property (nonatomic, strong) JFScrollPageContentView *pageContentView;
@property (nonatomic, strong) JFScrollPageSegmentView *segmentView;
@property (nonatomic, copy) NSArray *arrTest;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"JFScrollPageView";
    
    self.arrTest = @[@"全部",@"要闻",@"推荐",@"美食吃货",@"美容",@"母婴儿童",@"娱乐",@"其他",@"中国内外",@"时事政治"];
    
    CGFloat safeAreaTop = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.segmentView = [[JFScrollPageSegmentView alloc] initWithFrame:CGRectMake(0, safeAreaTop + 44, screenWidth, 50) titles:self.arrTest delegate:self];
    self.segmentView.selectIndex = 2;
    self.segmentView.colorTitleNormal = [UIColor blackColor];
    self.segmentView.colorTitleSelected = [UIColor redColor];
    self.segmentView.colorIndicator = [UIColor redColor];
    [self.view addSubview:_segmentView];
    
    NSMutableArray *arrChildViewController = [[NSMutableArray alloc] init];
    
    for (NSString *title in self.arrTest)
    {
        ChildViewController *childViewController = [[ChildViewController alloc] init];
        childViewController.title = title;
        [arrChildViewController addObject:childViewController];
    }
    self.pageContentView = [[JFScrollPageContentView alloc]initWithFrame:CGRectMake(0, safeAreaTop + 44 + 50, screenWidth, screenHeight - safeAreaTop - 44 - 50) childVCs:arrChildViewController parentVC:self delegate:self];
    self.pageContentView.contentViewCurrentIndex = 2;
    [self.view addSubview:_pageContentView];
}

#pragma mark - --- Delegate ---

- (void)segmentView:(JFScrollPageSegmentView *)segmentView scrollAtStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.pageContentView.contentViewCurrentIndex = endIndex;
    self.title = self.arrTest[endIndex];
}

- (void)contentViewDidEndDecelerating:(JFScrollPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.segmentView.selectIndex = endIndex;
    self.title = self.arrTest[endIndex];
}

- (void)contetnViewDidScroll:(JFScrollPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex progress:(CGFloat)progress
{
    UIFont *fontTitle = self.segmentView.fontTitle;
    
    UIButton *btnStart = self.segmentView.arrBtnItems[startIndex];
    UIButton *btnEnd = self.segmentView.arrBtnItems[endIndex];
    
    CGFloat startIndictorWidth = [JFScrollPageSegmentView getWidthWithString:self.arrTest[startIndex] font:fontTitle];
    CGFloat endIndictorWidth = [JFScrollPageSegmentView getWidthWithString:self.arrTest[endIndex] font:fontTitle];
    
    CGPoint originalCenter = btnStart.center;
    
    CGFloat margin = btnEnd.center.x - btnStart.center.x;
    CGFloat difference = endIndictorWidth - startIndictorWidth;
    
    self.segmentView.indicatorView.center = CGPointMake(originalCenter.x + margin * progress, self.segmentView.indicatorView.center.y);
    self.segmentView.indicatorView.bounds = CGRectMake(0, 0, startIndictorWidth + difference * progress, 2);
}

@end

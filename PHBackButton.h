//
//  BackButton.h
//  backButton
//
//  Created by admin on 16/3/29.
//  Copyright © 2016年 liuyao. All rights reserved.
//

/*!!!!!!!!!!!!Button的tag不要更改!!!!! 0为不带close 1为带close*/

#import <UIKit/UIKit.h>

@class PHBackButton;

@protocol PHBackButtonDataSource <NSObject>

@optional
//传递要跳转的ViewController类名字符串
- (NSString *)viewControllerToBack:(PHBackButton *)backButton;
//传递webView中的UIWebView
- (UIWebView *)viewControllerIsWeb:(PHBackButton *)backButton;
@end

@protocol PHBackButtonDelegate <NSObject>

@optional
//返回时委托方法
- (void)viewControllerWillGoBack;
//常规未找到时回调处理
- (void)viewControllerNotFound:(NSString *)vcstr;

@end

@interface PHBackButton : UIView
@property (nonatomic, assign) id<PHBackButtonDataSource> dataSource;
@property (nonatomic, assign) id<PHBackButtonDelegate> delegate;
//自定义两个按钮image 设置为nil时为默认
- (void)setBackButtonImage:(NSString *)backName closeButtonImage:(NSString *)closeName;
//返回方法，供其他按钮使用返回时使用
- (void)backVC:(id)viewControllerName;

@end

//
//  BackButton.m
//  backButton
//
//  Created by admin on 16/3/29.
//  Copyright © 2016年 liuyao. All rights reserved.
//

#import "PHBackButton.h"
#import "MHCustomTabBarController.h"

@interface PHBackButton ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *contentView_2;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) id currentViewController;

@end

@implementation PHBackButton

-(void)awakeFromNib {
    
    if (self.tag == 0)
    {
        [[NSBundle mainBundle] loadNibNamed:@"PHBackButton_2" owner:self options:nil];
        self.contentView_2.frame = self.frame;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView_2];
    }
    else if (self.tag == 1)
    {//1本为web使用，带close键，目前舍弃close，全都不用 liuyao
        [[NSBundle mainBundle] loadNibNamed:@"PHBackButton" owner:self options:nil];
        self.contentView.frame = self.frame;
        self.backgroundColor = [UIColor clearColor];
        //默认隐藏close按钮
        self.closeButton.hidden = YES;
        
        [self addSubview: self.contentView];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed:@"PHBackButton_2" owner:self options:nil];
        self.contentView_2.frame = self.frame;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView_2];

    }
}

//button所在当前ViewController
- (id)currentViewController
{
    return [self viewController];
}

//返回事件
- (IBAction)backAction:(id)sender {
//    NSLog(@"back:%@",self.currentViewController);
    
    NSString *viewController = @"";
    if (_dataSource && [_dataSource respondsToSelector:@selector(viewControllerToBack:)]) {
        viewController = [_dataSource viewControllerToBack:self];
    }
    //获取是否为Web页
    UIWebView *webView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(viewControllerIsWeb:)]) {
        webView = [_dataSource viewControllerIsWeb:self];
    }
    
    
    
    if (webView)
    {
        /*liuyao 原web返回逻辑*/
//        //Web页返回规则，webView中能back就back，back后如果还是web页面则显示关闭按钮。不能back就跳出webView
//        if (webView.canGoBack)
//        {
//            [webView goBack];
//            self.closeButton.hidden = NO;
//        }
//        else
//        {
//            [self getToBackVC:@""];
//        }
        /**/
        
        //把native判断变成0url 1原生带入返回按键，让返回根据此做判断
        NSInteger native = [viewController substringWithRange:NSMakeRange(0, 1)].integerValue;
        NSString *vcstr = [viewController substringFromIndex:1];
        if (native == 0)
        {
            if (vcstr.length == 0)
            {
                [self getToBackVC:@""];
                return;
            }
            //判断url的完整性，如果是完整url则直接请求，如果不是则加默认域名后再请求
            NSString *url = nil;
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:vcstr]])
            {
                url = vcstr;
            }
            else
            {
                url = [NSString stringWithFormat:@"%@%@",SEVERURL_USER_ME,vcstr];
            }
//            NSString *url = [NSString stringWithFormat:@"%@%@",SEVERURL_USER_ME,vcstr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            
            [webView loadRequest:request];
        }
        else
        {
            [self getToBackVC:vcstr];
        }
    }
    else
    {
        [self getToBackVC:viewController];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(viewControllerWillGoBack)]) {
        [_delegate viewControllerWillGoBack];
    }
}

//关闭事件
- (IBAction)closeAction:(id)sender {
    [self getToBackVC:@""];
//    NSLog(@"close");
}

//获取view的controller
- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

//通过vc字符串寻找到相应vc返回跳转，如果没有或者空着则默认跳转上一页
- (void)getToBackVC:(id)viewController
{
    NSString *vcstr = nil;
    //先判断viewController是否字符串，不是当空
    if (![viewController isKindOfClass:[NSString class]] || viewController == nil)
    {
        vcstr = @"";
    }
    else
    {
        vcstr = [NSString stringWithFormat:@"%@",viewController];
    }
    
    //如果字符串为空，则默认跳转到上一个界面
    if ([vcstr isEqualToString:@""])
    {
        //如果是nav且不是nav第一层，则pop上一个页面
        if ([self isNavigationController])
        {
            UINavigationController *navc = ((UIViewController *)self.currentViewController).navigationController;
            if (![self isNavTop])
            {
                [navc popViewControllerAnimated:YES];
                return;
            }
            else
            {
                [(UIViewController *)self.currentViewController dismissViewControllerAnimated:YES completion:nil];
                return;
            }
        }
        //如果是present，则dismiss上一个页面
        else
        {
            [(UIViewController *)self.currentViewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }
    //如果字符串为MH页，先看nav下有无presentingViewController，如果无则回到root，如果有则判断是否为MH，是则dismiss，不是则待定
    else if ([vcstr isEqualToString:@"MHCustomTabBarController"])
    {
        UINavigationController *navc = ((UIViewController *)self.currentViewController).navigationController;
        if ([navc.presentingViewController isKindOfClass:[MHCustomTabBarController class]])
        {
            [(UIViewController *)self.currentViewController dismissViewControllerAnimated:YES completion:nil];
            MHCustomTabBarController * topTab = (MHCustomTabBarController *)navc.presentingViewController;
            UINavigationController *topNav = (UINavigationController *)topTab.destinationViewController;
            [topNav popToRootViewControllerAnimated:NO];
        }
        else
        {
            [navc popToRootViewControllerAnimated:YES];
        }
    }
    //如果字符串为4个tab页面，先遍历nav，如果有则返回，没有则dismiss后回到root之后跳转
    else if ([vcstr isEqualToString:@"PHMainPageViewController"] || [vcstr isEqualToString:@"PHMyInfoViewController"] || [vcstr isEqualToString:@"PHGoSceneVC"] || [vcstr isEqualToString:@"PHMessageVC"])
    {
        UINavigationController *navc = ((UIViewController *)self.currentViewController).navigationController;
        Class desvc = NSClassFromString(vcstr);
        if ([self isNavigationController])
        {
            UINavigationController *vc = self.currentViewController;
            //先找自己当前Nav下的页面，有则跳转
            for (UIViewController *c in navc.viewControllers)
            {
                if ([c isKindOfClass:desvc])
                {
                    [navc popToViewController:c animated:YES];
                    return;
                }
            }
            MHCustomTabBarController * topTab = (MHCustomTabBarController *)vc.presentingViewController;
            if (topTab)
            {
                if (![topTab isKindOfClass:[MHCustomTabBarController class]])
                {
                    //返回逻辑错误，在此警告。
                    return;
                }
                UINavigationController *topNav = (UINavigationController *)topTab.destinationViewController;
                if (![topNav isKindOfClass:[UINavigationController class]])
                {
                    //返回逻辑错误，在此警告。
                    return;
                }
                [(UIViewController *)self.currentViewController dismissViewControllerAnimated:YES completion:nil];
                [topNav popToRootViewControllerAnimated:NO];
                [topTab indexAction:vcstr];
                return;
            }
            else
            {
                //没有present过，且要跳tab签时时
                MHCustomTabBarController * mhTab = (MHCustomTabBarController *)navc.parentViewController;
                if (mhTab && [mhTab isKindOfClass:[MHCustomTabBarController class]])
                {
                    [navc popToRootViewControllerAnimated:NO];
                    [mhTab indexAction:vcstr];
                }
            }
        }
        else
        {
            //返回逻辑不全，在此警告。
            return;
        }
        
    }
    
    //如果字符串不为空，则遍历nav的ViewControllers查找该vc，找到了则跳转至此，如果未找到则默认dismiss掉该nav，在其上层nav的ViewControllers继续查找
    else
    {
        UINavigationController *navc = ((UIViewController *)self.currentViewController).navigationController;
        Class desvc = NSClassFromString(vcstr);
        if ([self isNavigationController])
        {
            UINavigationController *vc = self.currentViewController;
            //先找自己当前Nav下的页面，有则跳转
            for (UIViewController *c in navc.viewControllers)
            {
                if ([c isKindOfClass:desvc])
                {
                    [navc popToViewController:c animated:YES];
                    return;
                }
            }
            //未找到则从当前页面的presenting页面中继续查找，有则跳转,已知现应用只有两层结构UITabbarController的tab签为UINavigationController，多为push，很少会present，如present也只会使用一次（如登录、启动闪屏页）。故先以这个逻辑进行查找。
            //liuyao 票乎底层为MHCustomTabBarController，从这里寻找
            //获取最底层UITabbarController
            //UITabBarController *topTab = (UITabBarController *)vc.presentingViewController;
            MHCustomTabBarController * topTab = (MHCustomTabBarController *)vc.presentingViewController;
            if (topTab != nil && ![topTab isKindOfClass:[MHCustomTabBarController class]])
            {
                //返回逻辑错误，在此警告。
                return;
            }

            //获取topTab.presentedViewController，即当前VC dismiss之后所在的UINavigationController，在其堆中查找。
//            UINavigationController *topNav = topTab.selectedViewController;
            UINavigationController *topNav = (UINavigationController *)topTab.destinationViewController;
            if (topNav != nil && ![topNav isKindOfClass:[UINavigationController class]])
            {
                //返回逻辑错误，在此警告。
                return;
            }
            
//            //如果是MHCustomTabBarController，则直接dismiss
//            if ([vcstr isEqualToString:@"MHCustomTabBarController"])
//            {
//                [(UIViewController *)self.currentViewController dismissViewControllerAnimated:YES completion:nil];
//                [topNav popToRootViewControllerAnimated:NO];
//                return;
//            }
            
            for (UIViewController *topC in topNav.viewControllers)
            {
                if ([topC isKindOfClass:desvc])
                {
                    [(UIViewController *)self.currentViewController dismissViewControllerAnimated:YES completion:nil];
                    [topNav popToViewController:topC animated:NO];
                    return;
                }
            }

            //如果至此未找到则回调，通知VC处理该特殊情况
            if (_delegate && [_delegate respondsToSelector:@selector(viewControllerNotFound:)]) {
                [_delegate viewControllerNotFound:vcstr];
                return;
            }
            //全都没找到且回调不启用，则跳到上一个页面
            [navc popViewControllerAnimated:YES];
            return;
        }
        else
        {
            //返回逻辑不全，在此警告。
            return;
        }
    }
}

//判断是否为nav,通过vc.viewcontrollers内是否有值决定
- (BOOL)isNavigationController
{
    BOOL isNav = NO;
    UINavigationController *navc = ((UIViewController *)self.currentViewController).navigationController;
    if (navc.viewControllers.count != 0)
    {
        isNav = YES;
    }
//    UIViewController *vc = self.currentViewController;
//    
//    if (vc.presentingViewController == nil)
//    {
//        isNav = YES;
//    }
//    else
//    {
//        isNav = NO;
//    }
    
    return isNav;
}

//判断是否为nav的第一层
- (BOOL)isNavTop
{
    BOOL isTop = NO;
    if ([self isNavigationController])
    {
        UINavigationController *navc = ((UIViewController *)self.currentViewController).navigationController;
        if (navc.viewControllers.count == 1)
        {
            isTop = YES;
        }
    }
    return isTop;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

//设置button图案
- (void)setBackButtonImage:(NSString *)backName closeButtonImage:(NSString *)closeName
{
    if (backName != nil)
    {
        [self.backButton setImage:[UIImage imageNamed:backName] forState:UIControlStateNormal];
    }
    if (closeName != nil)
    {
        [self.closeButton setImage:[UIImage imageNamed:closeName] forState:UIControlStateNormal];
    }
}

- (void)backVC:(id)viewControllerName
{
    [self getToBackVC:viewControllerName];
}
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    if (self = [super initWithCoder:aDecoder])
//    {
//        [[NSBundle mainBundle] loadNibNamed:@"BackButton" owner:self options:nil];
//        self.contentView.frame = self.frame;
//        [self addSubview: self.contentView];
//        
//    }
//    return self;
//}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame])
//    {
//        [[NSBundle mainBundle] loadNibNamed:@"BackButton" owner:self options:nil];
//        CGRect f = frame;
//        f.origin.x = 0;
//        f.origin.y = 0;
//        self.contentView.frame = f;
//        [self addSubview: self.contentView];
//    }
//    return self;
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

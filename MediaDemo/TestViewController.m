//
//  TestViewController.m
//  MediaDemo
//
//  Created by Cold Mountain on 2024/2/21.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self customNavigationBackBtn];
    
    self.title = @"考试费缴纳";
    float statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
        statusBarHeight = statusBarManager.statusBarFrame.size.height;
    } else {
        // Fallback on earlier versions
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if (@available(iOS 15.0,*)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = [UIColor colorWithRed:44.0/255 green:102.0/255 blue:166.0/255 alpha:1.0];
        [appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = self.navigationController.navigationBar.scrollEdgeAppearance;
        self.navigationController.navigationBar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }else {
        [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
}

- (void)customNavigationBackBtn{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];//设置导航栏标题颜色
     
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    //返回按钮
    UIButton *leftBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [leftBackBtn setImage:[UIImage imageNamed:@"icon_back_white"] forState:UIControlStateNormal];
    [leftBackBtn setImage:[UIImage imageNamed:@"icon_back_white_click"] forState:UIControlStateHighlighted];
    [leftBackBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBackBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    // 让返回按钮内容继续向左边偏移10
    leftBackBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [leftBackBtn addTarget:self action:@selector(backViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBackBtn];
}

- (void)backViewController:(UIBarButtonItem *)barButtonItem{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

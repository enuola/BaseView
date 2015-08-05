//
//  ViewController.m
//  BaseLibrary
//
//  Created by enuola on 15/8/2.
//  Copyright (c) 2015年 enuola. All rights reserved.
//

#import "ViewController.h"
#import "HyperlinkLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor grayColor]];

    HyperlinkLabel *label = [[HyperlinkLabel alloc] initWithFrame:CGRectMake(20, 40, self.view.frame.size.width-40, 500)];
    label.numberOfLines = 0;
    [label setBackgroundColor:[UIColor whiteColor]];
    [label setLinkColor:[UIColor blueColor]];
    [label setUrlColor:[UIColor magentaColor]];
    [label setHightlightColor:[UIColor orangeColor]];

    label.text = @"我是一个支持各种超链接的万能Label.\n1、支持超链接，比如www.baidu.com\n2、支持艾特符号，比如：@乔布斯 \n3、支持井号，比如 #万能Label# \n4、自定义扩展各种点击事件\n5、支持>=iOS6系统，自定义各种颜色自己尝试一下吧~如有问题，@凌凌漆 ";
    [label sizeToFit];
    [self.view addSubview:label];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

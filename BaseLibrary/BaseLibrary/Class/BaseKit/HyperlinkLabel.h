//
//  HyperlinkLabel.h
//  BaseLibrary
//
//  Created by enuola on 15/8/2.
//  Copyright (c) 2015年 enuola. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HyperlinkEntity;

// Constants for identifying link types
typedef NS_ENUM(NSInteger, KILinkType)
{
    KILinkTypeUserHandle,
    KILinkTypeHashtag,
    KILinkTypeURL,
    KILinkTypeExternal
};

// Constants for identifying link types we can detect
typedef NS_OPTIONS(NSUInteger, KILinkDetectionTypes)
{
    KILinkDetectionTypeUserHandle = (1 << 0),
    KILinkDetectionTypeHashtag = (1 << 1),
    KILinkDetectionTypeURL = (1 << 2),
    KILinkDetectionTypeExternal = (1 << 3),
    
    // Convenient constants
    KILinkDetectionTypeNone = 0,
    KILinkDetectionTypeAll = NSUIntegerMax
};

// Block method that is called when an interactive word is touched
typedef void (^KILinkTapHandler)(HyperlinkEntity *linkEntity);

@interface HyperlinkLabel : UILabel

@property (nonatomic, assign) KILinkDetectionTypes linkDetectionTypes;

// Get or set a block that is called when a link is touched
@property (nonatomic, copy) KILinkTapHandler linkTapHandler;

//超链接颜色
@property (nonatomic, strong) UIColor *linkColor;

//url链接对应的颜色，如果没有的话，默认和超链接颜色一样
@property (nonatomic, strong) UIColor *urlColor;

//url链接对应的颜色，如果没有的话，默认和超链接颜色一样
@property (nonatomic, strong) UIColor *hightlightColor;

//Label行间距
@property (nonatomic, assign) CGFloat   lineSpace;

//外部添加新的链接
@property (nonatomic, strong) NSArray    *externalLinks;

@end

//额外添加的超链接实体
@interface HyperlinkEntity : NSObject

@property (nonatomic, assign) NSRange       linkRange;
@property (nonatomic, assign) KILinkType    linkType;
@property (nonatomic, strong) NSString      *linkText;



@end

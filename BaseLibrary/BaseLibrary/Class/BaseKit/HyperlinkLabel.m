//
//  HyperlinkLabel.m
//  BaseLibrary
//
//  Created by enuola on 15/8/2.
//  Copyright (c) 2015年 enuola. All rights reserved.
//

#import "HyperlinkLabel.h"
#import <CoreText/CoreText.h>

@interface HyperlinkLabel ()

// Dictionary of detected links and their ranges in the text
@property (nonatomic, copy) NSArray *linkRanges;

// State used to trag if the user has dragged during a touch
@property (nonatomic, assign) BOOL isTouchMoved;


// During a touch, range of text that is displayed as selected
@property (nonatomic, assign) NSRange selectedRange;


@end

@implementation HyperlinkLabel

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTextSystem];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupTextSystem];
    }
    return self;
}

- (void)setupTextSystem
{
    if(!self.linkColor){
        self.linkColor = [UIColor redColor];
    }
    if(!self.urlColor){
        self.urlColor = [UIColor grayColor];
    }
    if (!self.hightlightColor) {
        self.hightlightColor = self.backgroundColor;
    }
    
    //默认打开所有链接
    self.linkDetectionTypes |= KILinkDetectionTypeURL;
    self.linkDetectionTypes |= KILinkDetectionTypeUserHandle;
    self.linkDetectionTypes |= KILinkDetectionTypeHashtag;
    self.linkDetectionTypes |= KILinkDetectionTypeExternal;
    
    self.selectedRange = NSMakeRange(NSNotFound, 0);
    self.userInteractionEnabled = YES;
    
    __weak typeof(self) weakSelf = self;
    self.linkTapHandler = ^(HyperlinkEntity *linkEntity) {
        
        [weakSelf removeHighlightLinks];
        NSString *linkTypeName = nil;
        switch (linkEntity.linkType)
        {
            case KILinkTypeUserHandle:
                linkTypeName = @"KILinkTypeUserHandle";
                break;
                
            case KILinkTypeHashtag:
                linkTypeName = @"KILinkTypeHashtag";
                break;
                
            case KILinkTypeURL:
                linkTypeName = @"KILinkTypeURL";
                break;
                
            case KILinkTypeExternal:
                linkTypeName = @"kILinkTypeExternal";
                break;
                
            default:
                linkTypeName = @"unknow";
                break;
        }
        
        NSLog(@"Default handler for label: %@, %@, %@", linkTypeName, linkEntity.linkText, NSStringFromRange(linkEntity.linkRange));
    };
}

- (void)setText:(NSString *)text
{
    // Pass the text to the super class first
    [super setText:text];
    
    // Update our text store with an attributed string based on the original
    // label text properties.
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self attributesFromProperties]];
    [self updateAttributedTextWithAttributedString:attributedText];
}

- (NSDictionary *)attributesFromProperties
{
    // Setup colour attributes
    UIColor *colour = self.textColor;
    if (!self.isEnabled)
    {
        colour = [UIColor lightGrayColor];
    }
    else if (self.isHighlighted)
    {
        colour = self.highlightedTextColor;
    }
    
    // Setup paragraph attributes
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = self.textAlignment;
    paragraph.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraph.lineSpacing = self.lineSpace;
    
    // Create the dictionary
    NSDictionary *attributes = @{
                                 NSFontAttributeName : self.font,
                                 NSForegroundColorAttributeName : colour,
                                 NSParagraphStyleAttributeName : paragraph };
    return attributes;
}

- (void)updateAttributedTextWithAttributedString:(NSAttributedString *)attributedString
{
    if (attributedString.length != 0)
    {
        self.linkRanges = [self getRangesForLinks:attributedString];
        attributedString = [self addLinkAttributesToAttributedString:attributedString linkRanges:self.linkRanges];
        [self setAttributedText:attributedString];
    }
    else
    {
        self.linkRanges = nil;
    }
}

- (NSAttributedString *)addLinkAttributesToAttributedString:(NSAttributedString *)string linkRanges:(NSArray *)linkRanges
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    // Tint colour used to hilight non-url links
    NSDictionary *attributes = @{NSForegroundColorAttributeName : self.linkColor};
    
    for (HyperlinkEntity *linkEntity in linkRanges)
    {
        NSRange range = linkEntity.linkRange;
        
        // Add an URL attribute if this is a URL
        if (linkEntity.linkType == KILinkTypeURL)
        {
            // Add a link attribute using the stored link
            NSDictionary *urlAttributes = @{NSForegroundColorAttributeName : self.urlColor};
            [attributedString addAttributes:urlAttributes range:range];
        }
        else{
            // Use our tint colour to hilight the link
            [attributedString addAttributes:attributes range:range];
        }
    }
    
    return attributedString;
}

// Returns array of ranges for all special words, user handles, hashtags and urls
- (NSArray *)getRangesForLinks:(NSAttributedString *)text
{
    NSMutableArray *rangesForLinks = [[NSMutableArray alloc] init];
    
    if (self.linkDetectionTypes & KILinkDetectionTypeExternal)
    {
        [rangesForLinks addObjectsFromArray:self.externalLinks];
    }
    
    if (self.linkDetectionTypes & KILinkDetectionTypeUserHandle)
    {
        [rangesForLinks addObjectsFromArray:[self getRangesForUserHandles:text.string]];
    }
    
    if (self.linkDetectionTypes & KILinkDetectionTypeHashtag)
    {
        [rangesForLinks addObjectsFromArray:[self getRangesForHashtags:text.string]];
    }
    
    if (self.linkDetectionTypes & KILinkDetectionTypeURL)
    {
        [rangesForLinks addObjectsFromArray:[self getRangesForURLs:self.attributedText]];
    }
    
    return rangesForLinks;
}

- (NSArray *)getRangesForUserHandles:(NSString *)text
{
    NSMutableArray *rangesForUserHandles = [[NSMutableArray alloc] init];
    
    // Setup a regular expression for user handles and hashtags
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"@.*?\\s"
                                                                      options:0
                                                                        error:&error];
    
    // Run the expression and get matches
    NSArray *matches = [regex matchesInString:text
                                      options:0
                                        range:NSMakeRange(0, text.length)];
    
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        if(matchRange.length > 2){
            NSRange textRange = NSMakeRange([match range].location+1, [match range].length-1);
            NSString *matchString = [text substringWithRange:textRange];
            
            HyperlinkEntity *linkEntity = [[HyperlinkEntity alloc] init];
            linkEntity.linkType = KILinkTypeUserHandle;
            linkEntity.linkRange = matchRange;
            linkEntity.linkText = matchString;
            
            [rangesForUserHandles addObject:linkEntity];
        }
    }
    
    return rangesForUserHandles;
}

- (NSArray *)getRangesForHashtags:(NSString *)text
{
    NSMutableArray *rangesForHashtags = [[NSMutableArray alloc] init];
    
    // Setup a regular expression for user handles and hashtags
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"#[^#]+#"
                                                                      options:0
                                                                        error:&error];
    
    // Run the expression and get matches
    NSArray *matches = [regex matchesInString:text
                                      options:0
                                        range:NSMakeRange(0, text.length)];
    
    // Add all our ranges to the result
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSRange textRange = NSMakeRange([match range].location+1, [match range].length-2);
        NSString *matchString = [text substringWithRange:textRange];
        
        HyperlinkEntity *linkEntity = [[HyperlinkEntity alloc] init];
        linkEntity.linkType = KILinkTypeHashtag;
        linkEntity.linkRange = matchRange;
        linkEntity.linkText = matchString;
        
        [rangesForHashtags addObject:linkEntity];
    }
    
    return rangesForHashtags;
}


- (NSArray *)getRangesForURLs:(NSAttributedString *)text
{
    NSMutableArray *rangesForURLs = [[NSMutableArray alloc] init];;
    
    // Use a data detector to find urls in the text
    NSError *error = nil;
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    
    NSString *plainText = text.string;
    
    NSArray *matches = [detector matchesInString:plainText
                                         options:0
                                           range:NSMakeRange(0, text.length)];
    
    // Add a range entry for every url we found
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        
        // If there's a link embedded in the attributes, use that instead of the raw text
        NSString *realURL = [text attribute:NSLinkAttributeName
                                    atIndex:matchRange.location
                             effectiveRange:nil];
        if (realURL == nil)
        {
            realURL = [plainText substringWithRange:matchRange];
        }
        
        if ([match resultType] == NSTextCheckingTypeLink)
        {
            HyperlinkEntity *linkEntity = [[HyperlinkEntity alloc] init];
            linkEntity.linkType = KILinkTypeURL;
            linkEntity.linkRange = matchRange;
            linkEntity.linkText = realURL;
            
            [rangesForURLs addObject:linkEntity];
        }
    }
    
    return rangesForURLs;
}

#pragma mark Util Tools Methods

- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    
    NSMutableAttributedString* optimizedAttributedText = [self.attributedText mutableCopy];
    
    [self.attributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        
        NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
        if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        }
        
        [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
        [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        
    }];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = CGRectMake(0, 0, self.frame.size.width, 1000);  //这里的高要设置足够大
    //    CGRect textRect = [self textRect];
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    //////
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(framesetter);
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    if (numberOfLines == 0) {
        CFRelease(framesetter);
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(framesetter);
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

#pragma mark --

- (CGRect)textRect {
    
    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    textRect.origin.y = (self.bounds.size.height - textRect.size.height)/2;
    
    if (self.textAlignment == NSTextAlignmentCenter) {
        textRect.origin.x = (self.bounds.size.width - textRect.size.width)/2;
    }
    if (self.textAlignment == NSTextAlignmentRight) {
        textRect.origin.x = self.bounds.size.width - textRect.size.width;
    }
    
    return textRect;
}

#pragma mark --

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouchMoved = NO;
    UITouch *touch = [touches anyObject];
    CFIndex index = [self characterIndexAtPoint:[touch locationInView:self]];
    HyperlinkEntity *linkEntity = [self highlightLinksWithIndex:index];
    if(!linkEntity){
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    self.isTouchMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    [self removeHighlightLinks];
    if(self.isTouchMoved){
        return;
    }
    UITouch *touch = [touches anyObject];
    CFIndex index = [self characterIndexAtPoint:[touch locationInView:self]];
    HyperlinkEntity *linkEntity = [self highlightLinksWithIndex:index];
    if(linkEntity){
        //执行点击事件
        self.linkTapHandler(linkEntity);
    }
    else
    {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self removeHighlightLinks];
    [super touchesCancelled:touches withEvent:event];
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

#pragma mark - Hightlight Links Util Methods

- (HyperlinkEntity *)highlightLinksWithIndex:(CFIndex)index {
    
    HyperlinkEntity *hyperLinkEntity = nil;
    
    NSMutableAttributedString *attributedString =[[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    for (HyperlinkEntity *linkEntity in self.linkRanges)
    {
        NSRange matchRange = linkEntity.linkRange;
        
        if ([self isIndex:index inRange:matchRange]) {
            [attributedString addAttribute:NSBackgroundColorAttributeName value:self.hightlightColor range:matchRange];
            
            self.selectedRange = matchRange;
            hyperLinkEntity = linkEntity;
            break;
        }
    }
    if(self.selectedRange.location != NSNotFound){
        [self setAttributedText:attributedString];
    }
    
    return hyperLinkEntity;
}

- (void)removeHighlightLinks
{
    if (self.selectedRange.location != NSNotFound) {
        
        //remove highlight from previously selected word
        NSMutableAttributedString* attributedString = [self.attributedText mutableCopy];
        [attributedString removeAttribute:NSBackgroundColorAttributeName range:self.selectedRange];
        self.attributedText = attributedString;
        
        self.selectedRange = NSMakeRange(NSNotFound, 0);
    }
}

@end

@implementation HyperlinkEntity

@end
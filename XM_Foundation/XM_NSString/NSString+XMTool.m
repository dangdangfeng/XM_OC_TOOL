//
//  NSString+XMTool.m
//  艺库
//
//  Created by zhangmingwei on 2019/7/10.
//  Copyright © 2019 YiKuNetwork. All rights reserved.
//

#import "NSString+XMTool.h"
#import <CommonCrypto/CommonDigest.h>
// 解析域名用的
#include <netdb.h>
#include <arpa/inet.h>

@implementation NSString (XMTool)

/// 格式化空字符串
+ (NSString *)nullToStringXM:(NSString *)string {
    NSString *lastStr = [NSString stringWithFormat:@"%@",string]; // 防止string为其他类型，比如NSNumber类型
    if (lastStr == nil) {
        return @"";
    }
    if ([lastStr isKindOfClass:[[NSNull null] class]]) {
        return @"";
    }
    if ([lastStr isEqualToString:@""]) {
        return @"";
    }
    if ([lastStr isEqualToString:@"<null>"]) {
        return @"";
    }
    if ([lastStr isEqualToString:@"null"]) {
        return @"";
    }
    if ([lastStr isEqualToString:@"(null)"]) {
        return @"";
    }
    return lastStr;
}
/// 根据字符串和字体大小获取frame
+ (CGRect)getSizeWithStrWidth:(NSString *)str font:(UIFont *)font width:(CGFloat)width {
    return [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil];
}

#pragma mark - 截取两个特殊字符串中间的字符串。
- (NSString *)rangeWithStartString:(NSString *)startString withEndString:(NSString *)endString {
    NSRange startRange = [self rangeOfString:startString];
    NSRange endRange = [self rangeOfString:endString];
    if (startRange.length== 0 || endRange.length == 0) {
        return @"";
    }
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    NSString *result = [self substringWithRange:range];
    return result;
}

#pragma mark - 去除两端空格
+ (NSString *)removeTrimmingBlank:(NSString *)string{
    ///去除两端空格
    ///sender 是输入框里面的text。
    NSString *temp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return temp;
    
}

#pragma mark - 去除所有空格
+(NSString *)removeAllBlank:(NSString *)string{
    ///去所有的空格。
    ///string 是输入框里面的text。
    NSString *resultString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return resultString;
}

/// 项目中通用的md5获取方法，ok，能用
- (NSString*)md5String {
    if (self == nil || [self length] == 0) {
        return @"";
    }
    const char *value = [self UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

- (id)jsonvalue {
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    if (!data) {
        NSLog(@"XM_OC: 解析json字符串出错！");
        return nil;
    }
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"XM_OC: 解析json字符串出错！");
    }
    return result;
}

#pragma mark ====去掉float类型数据后面的 无效的 0 ==========必须是有两个小数的时候才能用。=======.2f=======
+(NSString *)clipZero:(NSString *)string{
    if (!string) {
        return nil;
    }
    if ([string rangeOfString:@"."].location == NSNotFound) {
        return string;
    }
    
    for (int i = 0; i < 2; ++i) {
        if ([string hasSuffix:@"0"]) {
            string = [string substringToIndex:string.length - 1];
        }
    }
    if ([string hasSuffix:@"."]) {
        string = [string substringToIndex:string.length - 1];
    }
    return string;
}

#pragma mark - 获取当前时间的时间戳 的 字符串
+ (NSString *)getCurrentTimeStampStr {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}


/// 获取当前时间的字符串 @"yyyy-MM-dd hh:mm:ss"
+ (NSString *)getCurrentTimeStr {
    NSDate *timeS = [[NSDate alloc] init];
    NSString *t = [timeS dateStrWithFormat:@"yyyy-MM-dd hh:mm:ss"];
    return t;
}

 /*
 [[[self.signTV rac_textSignal] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id x) {
 wSelf.signTV.text = [NSString textViewLimtWithMaxLength:40 textView:wSelf.signTV];
 }];
 */
/// textFild 限制字数的方法
+ (NSString *)textFieldLimtWithMaxLength:(int)maxTextLength textField:(UITextField *)textField {
    NSString *toBeString = textField.text;
    NSString *resultString = textField.text;//业务逻辑
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            //业务逻辑
            if (toBeString.length > maxTextLength) {
                textField.text = [toBeString substringToIndex:maxTextLength];
                resultString = [textField.text substringToIndex:maxTextLength];
            } else {
                resultString = textField.text;
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else {
        //业务逻辑
        if (toBeString.length > maxTextLength) {
            textField.text = [toBeString substringToIndex:maxTextLength];
            resultString = [textField.text substringToIndex:maxTextLength];
        } else {
            resultString = textField.text;
        }
    }
    return resultString;
}

/*
 [[[self.signTV rac_textSignal] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id x) {
 wSelf.signTV.text = [NSString textViewLimtWithMaxLength:40 textView:wSelf.signTV];
 }];
 */
/// textView 限制字数的方法
+ (NSString *)textViewLimtWithMaxLength:(int)maxTextLength textView:(UITextView *)textView {
    NSString *toBeString = textView.text;
    NSString *resultString = textView.text;//业务逻辑
    //业务逻辑
    if (toBeString.length > maxTextLength) {
        textView.text = [toBeString substringToIndex:maxTextLength];
        resultString = [textView.text substringToIndex:maxTextLength];
    } else {
        resultString = textView.text;
    }
    return resultString;
}

+ (NSString *)quKongGeAndEnder:(NSString *)sender {
    /// 去除两端空格和回车
    NSString *text = [sender stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return text;
}

/*
 邮箱隐藏规则，
 1. 字符>5 位就隐藏@符中间的4位字符 例如：zhaoweiyu@speedx.com 隐藏后 zha****yu@speedx.com
 2. 字符=5位隐藏@后前4位     例如：weiyu@speedx.com 隐藏后 w****@speedx.com
 3. 字符<=4位就隐藏@符号前的全部字符 例如：eiyu@speedx.com  隐藏后 ****@speedx.com
 */
#pragma mark - 手机、邮箱添加 * 显示
+ (NSString *)getStarString:(NSString *)oldString {
    NSString *newString = nil;
    if ([NSString isEmptyString:oldString]) {
        return @"";
    }
    if ([oldString containsString:@"@"]) { // 邮箱
        NSString *leftString = [oldString componentsSeparatedByString:@"@"][0];
        if (leftString.length > 4) { // @符号前长度大于4个字符
            if (leftString.length == 5) {
                newString = [NSString stringWithFormat:@"%@****%@",[leftString substringToIndex:leftString.length - 4],[oldString substringFromIndex:[oldString rangeOfString:@"@"].location]];
            } else { // 大于5的情况
                newString = [NSString stringWithFormat:@"%@****%@",[leftString substringToIndex:(leftString.length - 3)/2],[oldString substringFromIndex:(leftString.length - 3)/2 + 4]];
            }
        } else { // @符号前长度小于4个字符
            NSString *star = @"*";
            if (leftString.length == 2) {
                star = @"**";
            } else if (leftString.length == 3) {
                star = @"***";
            } else if (leftString.length == 4) {
                star = @"****";
            }
            newString = [NSString stringWithFormat:@"%@%@",star,[oldString substringFromIndex:[oldString rangeOfString:@"@"].location]];
        }
    } else { // 手机号
        if (oldString.length > 7) {
            newString = [NSString stringWithFormat:@"%@****%@",[oldString substringToIndex:oldString.length - 8],[oldString substringFromIndex:oldString.length - 4]];
        } else {
            newString = oldString;
        }
    }
    return newString;
}

///根据域名获取ip地址 - 可以用于控制APP的开关某一个入口，比接口方式速度快的多
+ (NSString*)getIPWithHostName:(const NSString*)hostName {
    const char *hostN= [hostName UTF8String];
    struct hostent* phot;
    @try {
        phot = gethostbyname(hostN);
    } @catch (NSException *exception) {
        return nil;
    }
    struct in_addr ip_addr;
    if (phot == NULL) {
        NSLog(@"获取失败");
        return nil;
    }
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0}; inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    NSLog(@"ip=====%@",strIPAddress);
    return strIPAddress;
}

/// 获取电话号码
+ (NSString *)getPhoneNumber:(NSString *)phoneNumber {
    NSString *lastStr = @"";
    if ([NSString isEmptyString:phoneNumber]) {
        return lastStr;
    } else {
        lastStr = [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
        lastStr = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return  lastStr;
}

/**
 返回需要的视频图片
 
 @param videoUrlStr 网络的视频图片
 @return
 */
+ (NSString *)getVideoUrlString:(NSString *)videoUrlStr {
    if ([videoUrlStr containsString:@"/offset/1/w/"]) {
        NSString *lastStr = [videoUrlStr stringByReplacingOccurrencesOfString:@"/offset/1/w/" withString:@"/offset/0/w/"];
        return lastStr;
    } else {
        return videoUrlStr;
    }
}

/*
 根据字符串的长度、字体大小来自适应获取字符串占用的控件大小
 */
- (CGSize)getcontentsizeWithfont:(UIFont *)font constrainedtosize:(CGSize)std_size linemode:(NSLineBreakMode)lineBreakMode
{
    CGSize size = CGSizeZero;
    if (self == nil || self.length == 0)
    {
        return size;
    }
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        size = [self boundingRectWithSize:std_size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        
        size = [self sizeWithFont:font constrainedToSize:std_size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return size;
}
/// 根据 @"yyyy-MM-dd HH:mm:ss"格式的字符串返回 ： 刚刚，几分钟前，几天前的字符串
+ (NSString *)compareCurrentTime:(NSString *)str {
    //把字符串转为NSdate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *timeDate = [dateFormatter dateFromString:str];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:timeDate];
    long temp = 0;
    NSString *result;
    if (timeInterval/60 < 1)
    {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if ((temp = timeInterval/60) <60) {
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
    }
    else if ((temp = temp/60) <24) {
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    else if ((temp = temp/24) <30) {
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    else if ((temp = temp/30) <12) {
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    return  result;
}

/**
 *  utf8编码
 *
 *  @param UTF8String 编码string
 *
 *  @return 返回的编码内容
 */
- (NSString *)UTF8StringEncoding:(NSString *)UTF8String {
    
    return [UTF8String  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "]];
}

+ (NSString *)al_firstCharOfName:(NSString *)aChinenseName {
    NSMutableString * first = [[NSMutableString alloc] initWithString:[aChinenseName substringWithRange:NSMakeRange(0, 1)]];
    CFRange range = CFRangeMake(0, 1);
    
    // 汉字转换为拼音,并去除音调
    if (!CFStringTransform((__bridge CFMutableStringRef)first, &range, kCFStringTransformMandarinLatin, NO) ||
        !CFStringTransform((__bridge CFMutableStringRef)first, &range, kCFStringTransformStripDiacritics, NO)) {
        return @"";
    }
    NSString *result;
    result = [first substringWithRange:NSMakeRange(0, 1)].uppercaseString;
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Z]+$" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *resultNew = [regex firstMatchInString:result options:0 range:NSMakeRange(0, [result length])];
    if (!resultNew) {
        result = @"#";
    }
    
    return result;
}

/// 根据String 转 date  "2012-5-4"  --> Date
+ (NSDate *)getDateFromStrYMD:(NSString *)timeStr {
    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    dateF.dateFormat = @"yyyy-MM-dd";
    dateF.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    return [dateF dateFromString:timeStr];
}

/// 获取两端不同颜色的字符串
+ (NSAttributedString *)getAttributeStr:(NSString *)str1 color1:(UIColor *)color1 font1:(UIFont *)font1 str2:(NSString *)str2 color2:(UIColor *)color2 font2:(UIFont *)font2 {
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:str1 attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone),NSForegroundColorAttributeName : color1,NSFontAttributeName:font1}];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:str2 attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone),NSForegroundColorAttributeName : color2,NSFontAttributeName:font2}];
    
    NSMutableAttributedString *lastStr = [[NSMutableAttributedString alloc] init];
    [lastStr appendAttributedString:attrStr1];
    [lastStr appendAttributedString:attrStr2];
    
    return lastStr;
}

/// 字符串添加图片    ---  "图标 + 带颜色的文字"
+ (NSMutableAttributedString *)getImgAttributeWithImg:(UIImage *)img str:(NSString *)str color:(UIColor *)color font:(UIFont *)font {
    //初始化
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    //空格间隙
    NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
    //图片
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = img;
    attachment.bounds = CGRectMake(0, -3, 16, 16);
    NSAttributedString *imageAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
    //图片
    [attributedString appendAttributedString:imageAttachment];
    //空格间隙
    [attributedString appendAttributedString:spaceString];
    //文字
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange textRange = NSMakeRange(0, str.length);
    //行间距
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineSpacing = 5;
    [textString addAttribute:NSParagraphStyleAttributeName value:style range:textRange];
    //文字颜色
    [textString addAttribute:NSForegroundColorAttributeName value:color range:textRange];
    //字体
    [textString addAttribute:NSFontAttributeName value:font range:textRange];
    
    [attributedString appendAttributedString:textString];
    
    return attributedString;
}

/// 字符串添加图片 带删除线的    ---  "图标 + 带颜色的文字 带删除线"
+ (NSMutableAttributedString *)getImgAttributeWithImgStrikeLine:(UIImage *)img str:(NSString *)str color:(UIColor *)color font:(UIFont *)font {
    //初始化
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    //空格间隙
    NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
    //图片
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = img;
    attachment.bounds = CGRectMake(0, -3, 16, 16);
    NSAttributedString *imageAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
    //空格间隙
    [attributedString appendAttributedString:spaceString];
    //图片
    [attributedString appendAttributedString:imageAttachment];
    //空格间隙
    [attributedString appendAttributedString:spaceString];
    //文字
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange textRange = NSMakeRange(0, str.length);
    //行间距
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineSpacing = 5;
    [textString addAttribute:NSParagraphStyleAttributeName value:style range:textRange];
    //文字颜色
    [textString addAttribute:NSForegroundColorAttributeName value:color range:textRange];
    //字体
    [textString addAttribute:NSFontAttributeName value:font range:textRange];
    [attributedString appendAttributedString:textString];
    
    /// 删除线
    [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, attributedString.length)];

    return attributedString;
}


/// html转码 - 后台返回富文本html，iOS转换为webView能加载的html字符串 （例如： &lt;转成 <，注意本来就是<p>的标签的话，调用本方法会失去样式效果，变为text文本格式了）
+ (NSString *)getWebViewHtmlStr:(NSString *)htmlStr {
    NSData *lastData = [htmlStr dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithData:lastData options:options documentAttributes:nil error:nil];
    return contentText.string;
}


@end
